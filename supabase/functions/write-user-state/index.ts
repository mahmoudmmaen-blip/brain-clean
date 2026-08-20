/**
 * write-user-state — JWT-gated upserts for progress / journey tables.
 *
 * user_id is taken from the verified JWT, never from the client body.
 */
import {
  createServiceClient,
  jsonResponse,
  requireAuthenticatedUser,
} from "../_shared/jwt.ts";

const TABLES: Record<string, ReadonlySet<string>> = {
  user_progress: new Set([
    "start_date",
    "deductions",
    "lapse_count",
    "slip_count",
    "baseline_json",
    "state_json",
  ]),
  focus_journey: new Set([
    "journey_json",
    "current_day",
    "current_step",
  ]),
  user_diagnostics: new Set([
    "session_json",
    "bc_score",
    "committed_at",
  ]),
  detox_protocol: new Set([
    "boredom_befriended",
    "delayed_gratification_count",
    "body_activated",
  ]),
  daily_snapshots: new Set([
    "date",
    "bcs_value",
  ]),
  emotion_logs: new Set([
    "timestamp",
    "emotion_label",
    "category",
    "recovery_impact",
  ]),
};

function pickAllowlisted(
  table: string,
  incoming: Record<string, unknown>,
): Record<string, unknown> | null {
  const allowed = TABLES[table];
  if (!allowed) return null;
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(incoming)) {
    if (key === "user_id" || key === "id") continue;
    if (!allowed.has(key)) continue;
    out[key] = value;
  }
  return out;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return jsonResponse({ ok: true });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const caller = await requireAuthenticatedUser(req);
    if (caller instanceof Response) return caller;

    const raw: unknown = await req.json();
    if (raw == null || typeof raw !== "object" || Array.isArray(raw)) {
      return jsonResponse({ error: "Invalid payload" }, 400);
    }
    const body = raw as Record<string, unknown>;
    const table = typeof body.table === "string" ? body.table : "";
    const row = body.row;
    if (!table || row == null || typeof row !== "object" || Array.isArray(row)) {
      return jsonResponse({ error: "Invalid payload" }, 400);
    }

    const filtered = pickAllowlisted(table, row as Record<string, unknown>);
    if (filtered == null) {
      return jsonResponse({ error: "Unknown table" }, 400);
    }

    const admin = createServiceClient();
    const rowToWrite: Record<string, unknown> = {
      user_id: caller.userId,
      ...filtered,
    };
    if (table !== "daily_snapshots" && table !== "emotion_logs") {
      rowToWrite.updated_at = new Date().toISOString();
    }

    const { error } = await admin.from(table).upsert(rowToWrite);

    if (error) {
      console.error("write-user-state upsert failed");
      return jsonResponse({ error: "Write failed" }, 500);
    }

    return jsonResponse({ ok: true, table });
  } catch {
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
