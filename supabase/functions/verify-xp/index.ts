/**
 * verify-xp — server-authoritative XP writes.
 *
 * Authority = verified user JWT (signature + claims + getUser) + server rules.
 * Client HMAC is local tamper-evidence only and is never trusted here.
 */
import {
  createServiceClient,
  jsonResponse,
  requireAuthenticatedUser,
} from "../_shared/jwt.ts";
import {
  BACKFILL_WINDOW_MS,
  CLOCK_FUTURE_TOLERANCE_MS,
  DAILY_CAPS,
  XP_SOURCES,
  type XpSource,
  maxPlausibleForSource,
  utcDayKey,
} from "./xp_constants.ts";

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

function isValidSource(s: string): s is XpSource {
  return (XP_SOURCES as readonly string[]).includes(s);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const caller = await requireAuthenticatedUser(req);
    if (caller instanceof Response) return caller;

    const admin = createServiceClient();
    const userId = caller.userId;

    const payload: unknown = await req.json();
    const entries: ClientEntry[] = Array.isArray(payload)
      ? payload
      : (payload as { entries?: ClientEntry[] })?.entries ?? [];

    if (!Array.isArray(entries) || entries.length === 0) {
      return jsonResponse({
        verdicts: [],
        serverTotalXp: await sumAccepted(admin, userId),
      });
    }

    if (entries.length > 50) {
      return jsonResponse({ error: "Too many entries" }, 413);
    }

    const serverNow = Date.now();
    const verdicts: Verdict[] = [];
    for (const entry of entries) {
      verdicts.push(await processEntry(admin, userId, entry, serverNow));
    }

    return jsonResponse({
      verdicts,
      serverTotalXp: await sumAccepted(admin, userId),
    });
  } catch (e) {
    console.error("verify-xp error");
    return jsonResponse({ error: "Internal error" }, 500);
  }
});

async function sumAccepted(
  admin: ReturnType<typeof createServiceClient>,
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
  admin: ReturnType<typeof createServiceClient>,
  userId: string,
  entry: ClientEntry,
  serverNow: number,
): Promise<Verdict> {
  const { id, source, refId, amount, createdAtUtc } = entry;

  if (!id || !source || amount == null || !createdAtUtc) {
    return { id: id ?? "unknown", status: "rejected", reason: "invalid_payload" };
  }

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
  admin: ReturnType<typeof createServiceClient>,
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

  if (error && error.code !== "23505") {
    throw error;
  }
}
