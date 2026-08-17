import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHmac } from "https://deno.land/std@0.177.0/node/crypto.ts";

const HMAC_SECRET = Deno.env.get("XP_HMAC_SECRET") ?? "";
const MAX_ENTRIES_PER_REQUEST = 200;

interface XpEntry {
  id: string;
  source: string;
  ref_id?: string;
  amount: number;
  created_at_utc: string;
  device_id: string;
  signature: string;
}

function verifySignature(entry: XpEntry, secret: string): boolean {
  const payload = `${entry.id}|${entry.source}|${entry.ref_id ?? ""}|${entry.amount}|${entry.created_at_utc}|${entry.device_id}`;
  const expected = createHmac("sha256", secret).update(payload).digest("hex");
  return entry.signature === expected;
}

const DAILY_LIMITS: Record<string, number> = {
  focusSession: 120,
  dailyCheckIn: 50,
  challengeDay: 80,
  cognitiveTest: 60,
};

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

    // Service-role writes are only allowed on behalf of an authenticated caller.
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }
    const userClient = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const supabase = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { entries, device_id } = await req.json() as { entries: XpEntry[]; device_id: string };

    if (!entries || !Array.isArray(entries) || entries.length === 0) {
      return new Response(JSON.stringify({ error: "No entries" }), { status: 400 });
    }

    if (entries.length > MAX_ENTRIES_PER_REQUEST) {
      return new Response(JSON.stringify({ error: "Too many entries" }), { status: 413 });
    }

    if (typeof device_id !== "string" || device_id.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Invalid device_id" }), { status: 400 });
    }

    if (HMAC_SECRET.length === 0) {
      return new Response(JSON.stringify({ error: "Server not configured" }), { status: 503 });
    }

    const results: Record<string, "verified" | "rejected"> = {};
    let verifiedTotal = 0;

    for (const entry of entries) {
      // 1. Verify HMAC signature
      if (!verifySignature(entry, HMAC_SECRET)) {
        results[entry.id] = "rejected";
        continue;
      }

      // 2. Check daily limit per source
      const today = new Date().toISOString().slice(0, 10);
      const { data: todayRows } = await supabase
        .from("xp_ledger")
        .select("amount")
        .eq("device_id", device_id)
        .eq("source", entry.source)
        .eq("sync_state", "verified")
        .gte("created_at_utc", `${today}T00:00:00Z`);

      const todayTotal = (todayRows ?? []).reduce((sum, r) => sum + r.amount, 0);
      const limit = DAILY_LIMITS[entry.source] ?? 200;

      if (todayTotal + entry.amount > limit) {
        results[entry.id] = "rejected";
        continue;
      }

      // 3. Upsert into DB
      const { error } = await supabase.from("xp_ledger").upsert({
        id: entry.id,
        source: entry.source,
        ref_id: entry.ref_id,
        amount: entry.amount,
        created_at_utc: entry.created_at_utc,
        device_id: device_id,
        signature: entry.signature,
        sync_state: "verified",
      });

      if (error) {
        results[entry.id] = "rejected";
      } else {
        results[entry.id] = "verified";
        verifiedTotal += entry.amount;
      }
    }

    return new Response(JSON.stringify({ results, verified_total: verifiedTotal }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (_err) {
    // Internal details are never echoed back to the client.
    return new Response(JSON.stringify({ error: "Internal error" }), { status: 500 });
  }
});
