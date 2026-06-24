/**
 * Server-side XP validation constants — MUST mirror Dart [XpLedgerConstants].
 * The server does NOT verify client HMAC; it re-validates amount independently.
 */

export const XP_SOURCES = [
  "dailyTask",
  "pomodoro",
  "focusSession",
  "game",
  "diagnostic",
  "recovery",
  "streakBonus",
  "other",
] as const;

export type XpSource = (typeof XP_SOURCES)[number];

export const DAILY_CAPS: Record<XpSource, number> = {
  dailyTask: 60,
  pomodoro: 50,
  focusSession: 120,
  game: 100,
  diagnostic: 40,
  recovery: 40,
  streakBonus: 30,
  other: 1_000_000_000,
};

/** Max future drift allowed vs server clock. */
export const CLOCK_FUTURE_TOLERANCE_MS = 5 * 60 * 1000;

/** Oldest entry the server will accept (backfill window). */
export const BACKFILL_WINDOW_MS = 7 * 24 * 60 * 60 * 1000;

export function utcDayKey(iso: string): string {
  const d = new Date(iso);
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/** Mirrors Dart [XpLedgerConstants.maxPlausibleGameXp]. */
export function maxPlausibleGameXp(refId: string | null | undefined): number {
  if (!refId) return DAILY_CAPS.game;
  const gameId = refId.split(":")[0];
  switch (gameId) {
    case "pattern_match":
      return 8;
    case "number_memory":
      return 36; // (20-2)*2
    case "color_word":
      return 6;
    case "n_back":
      return 36; // 12 * 3
    case "speed_sort":
      return 15;
    case "crossword":
      return 25;
    default:
      return DAILY_CAPS.game;
  }
}

export function maxPlausibleForSource(
  source: XpSource,
  refId: string | null | undefined,
): number {
  switch (source) {
    case "game":
      return maxPlausibleGameXp(refId);
    case "focusSession":
      return 30;
    case "pomodoro":
      return 5;
    case "diagnostic":
      return 10;
    case "dailyTask":
      return 16; // mental * 3 stars
    default:
      return DAILY_CAPS[source];
  }
}
