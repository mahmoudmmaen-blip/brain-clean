/**
 * verify-xp — server-authoritative XP validation (Phase B).
 *
 * Security model (honest):
 * - Does NOT verify client HMAC (key cannot be shared safely).
 * - Authority = authenticated JWT + server-side rules (idempotency, caps, plausibility, clock).
 * - Client HMAC remains local tamper-evidence only.
 */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  BACKFILL_WINDOW_MS,
  CLOCK_FUTURE_TOLERANCE_MS,
  DAILY_CAPS,
  XP_SOURCES,
  type XpSource,
  maxPlausibleForSource,
  utcDayKey,
} from "./xp_constants.ts";

/// Comma-separated browser origins allowed to call this function.
const ALLOWED_ORIGINS = (Deno.env.get("ALLOWED_ORIGINS") ?? "")
  .split(",")
  .map((o) => o.trim())
  .filter((o) => o.length > 0);

/// Upper bound on entries accepted per request.
const MAX_ENTRIES_PER_REQUEST = 200;

function corsHeaders(req: Request): Record<string, string> {
  const origin = req.headers.get("Origin");
  const headers: Record<string, string> = {
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    headers["Access-Control-Allow-Origin"] = origin;
  }
  return headers;
}

interface ClientEntry {
  id: string;
  source: string;
  refId?: string | null;
  amount: number;
  createdAtUtc: string;
}

interface Verdict {
  id: string;
  status: "accepted" | "rejected";
  reason?: string;
}

function jsonResponse(req: Request, body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(req), "Content-Type": "application/json" },
  });
}

function isValidSource(s: string): s is XpSource {
  return (XP_SOURCES as readonly string[]).includes(s);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(req) });
  }
  if (req.method !== "POST") {
    return jsonResponse(req, { error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return jsonResponse(req, { error: "Missing or invalid Authorization" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return jsonResponse(req, { error: "Unauthorized" }, 401);
    }
    const userId = userData.user.id;

    const admin = createClient(supabaseUrl, serviceRoleKey);

    let payload: unknown = await req.json();
    const entries: ClientEntry[] = Array.isArray(payload)
      ? payload
      : (payload as { entries?: ClientEntry[] })?.entries ?? [];

    if (!Array.isArray(entries) || entries.length === 0) {
      return jsonResponse(req, {
        verdicts: [],
        serverTotalXp: await sumAccepted(admin, userId),
      });
    }

    if (entries.length > MAX_ENTRIES_PER_REQUEST) {
      return jsonResponse(req, { error: "Too many entries" }, 413);
    }

    const serverNow = Date.now();
    const verdicts: Verdict[] = [];

    for (const entry of entries) {
      const verdict = await processEntry(admin, userId, entry, serverNow);
      verdicts.push(verdict);
    }

    const serverTotalXp = await sumAccepted(admin, userId);
    return jsonResponse(req, { verdicts, serverTotalXp });
  } catch (e) {
    console.error("verify-xp error:", e);
    return jsonResponse(req, { error: "Internal error" }, 500);
  }
});

async function sumAccepted(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<number> {
  const { data, error } = await admin
    .from("xp_ledger")
    .select("amount")
    .eq("user_id", userId)
    .eq("status", "accepted");
  if (error) throw error;
  return (data ?? []).reduce((sum, row) => sum + (row.amount as number), 0);
}

async function processEntry(
  admin: ReturnType<typeof createClient>,
  userId: string,
  entry: ClientEntry,
  serverNow: number,
): Promise<Verdict> {
  const { id, source, refId, amount, createdAtUtc } = entry;

  if (!id || !source || amount == null || !createdAtUtc) {
    return { id: id ?? "unknown", status: "rejected", reason: "invalid_payload" };
  }

  // Idempotency: prior verdict by primary key, scoped to the caller so a
  // guessed id belonging to another user never returns a verdict.
  const { data: existing } = await admin
    .from("xp_ledger")
    .select("status, reject_reason")
    .eq("id", id)
    .eq("user_id", userId)
    .maybeSingle();

  if (existing) {
    return {
      id,
      status: existing.status as "accepted" | "rejected",
      reason: existing.reject_reason ?? "already_processed",
    };
  }

  if (!isValidSource(source)) {
    await persist(admin, userId, entry, "rejected", "invalid_source");
    return { id, status: "rejected", reason: "invalid_source" };
  }

  const createdMs = new Date(createdAtUtc).getTime();
  if (Number.isNaN(createdMs)) {
    await persist(admin, userId, entry, "rejected", "invalid_timestamp");
    return { id, status: "rejected", reason: "invalid_timestamp" };
  }

  if (createdMs > serverNow + CLOCK_FUTURE_TOLERANCE_MS) {
    await persist(admin, userId, entry, "rejected", "clock_future");
    return { id, status: "rejected", reason: "clock_future" };
  }

  if (createdMs < serverNow - BACKFILL_WINDOW_MS) {
    await persist(admin, userId, entry, "rejected", "clock_too_old");
    return { id, status: "rejected", reason: "clock_too_old" };
  }

  if (!Number.isInteger(amount) || amount <= 0) {
    await persist(admin, userId, entry, "rejected", "invalid_amount");
    return { id, status: "rejected", reason: "invalid_amount" };
  }

  const maxPlausible = maxPlausibleForSource(source, refId ?? null);
  if (amount > maxPlausible) {
    await persist(admin, userId, entry, "rejected", "implausible_amount");
    return { id, status: "rejected", reason: "implausible_amount" };
  }

  // ref_id uniqueness per (user, source).
  if (refId) {
    const { data: dup } = await admin
      .from("xp_ledger")
      .select("id")
      .eq("user_id", userId)
      .eq("source", source)
      .eq("ref_id", refId)
      .eq("status", "accepted")
      .maybeSingle();

    if (dup) {
      await persist(admin, userId, entry, "rejected", "duplicate_ref");
      return { id, status: "rejected", reason: "duplicate_ref" };
    }
  }

  const dayKey = utcDayKey(createdAtUtc);
  const dayStart = new Date(`${dayKey}T00:00:00.000Z`).toISOString();
  const dayEnd = new Date(`${dayKey}T23:59:59.999Z`).toISOString();

  const { data: dayRows } = await admin
    .from("xp_ledger")
    .select("amount")
    .eq("user_id", userId)
    .eq("source", source)
    .eq("status", "accepted")
    .gte("created_at_utc", dayStart)
    .lte("created_at_utc", dayEnd);

  const dayTotal = (dayRows ?? []).reduce((s, r) => s + (r.amount as number), 0);
  const cap = DAILY_CAPS[source];
  if (dayTotal + amount > cap) {
    await persist(admin, userId, entry, "rejected", "daily_cap_exceeded");
    return { id, status: "rejected", reason: "daily_cap_exceeded" };
  }

  await persist(admin, userId, entry, "accepted", null);
  return { id, status: "accepted" };
}

async function persist(
  admin: ReturnType<typeof createClient>,
  userId: string,
  entry: ClientEntry,
  status: "accepted" | "rejected",
  rejectReason: string | null,
): Promise<void> {
  const { error } = await admin.from("xp_ledger").insert({
    id: entry.id,
    user_id: userId,
    source: entry.source,
    ref_id: entry.refId ?? null,
    amount: entry.amount,
    created_at_utc: entry.createdAtUtc,
    status,
    reject_reason: rejectReason,
  });

  if (error) {
    // Race on id or unique ref — treat as idempotent read-back.
    if (error.code === "23505") {
      return;
    }
    throw error;
  }
}
