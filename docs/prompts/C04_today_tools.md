# C04 — Today hierarchy + "days practiced" + goal tips + hide games

Build: **no**
Commit message: `v3: today hierarchy, days practiced, goal tips, hide brain games`
Spec: §4.5, §4.10 + PLAN items 7, 9, 12 (games).

## 1. Today screen (`lib/v3/ui/today/today_screen.dart`)
Order, top → bottom:
1. Header: greeting + gear (→ /settings).
2. Hero metric: «X أيام تدريب» (count of completed days) + small «اليوم X من 30» bar; streak shown small next to it (not the hero).
3. Hero day card with ONE primary button (start/continue today's session). Pro-locked state → «افتح بقية البرنامج» → `/paywall?source=locked_day`.
4. SOS: a persistent, always-visible button (e.g. pinned above the bottom nav), not a card lost in the scroll.
5. Evening check-in: a FIXED slot that is always present and changes state: before 18:00 «مراجعة المساء تفتح بعد 6 مساءً», after 18:00 «كيف كان يومك؟» (opens sheet), done → summary «✓ سجّلت مراجعتك».
6. Below: challenge card, goal tip card (below), small Clarity card.
- Missed days: the next day simply waits; never show shame copy.

## 2. Goal tips
- Move `docs/prompts/content/goal_tips.json` → `assets/content/goal_tips.json`; register in pubspec.
- ContentRepository `goalTip(goal, week)` (fallback goal `less_scroll`, fallback locale `en`). Map JSON ids (focus, sleep, less_scroll, calm) to existing `UserProfile.goal` values without renaming stored values.
- Card on Today: icon + tip (max 2 lines). week = ((currentDay − 1) ~/ 7) + 1, capped at 4. Hidden after Day 30.
- Integrity test: 4 goals × weeks 1..4, each ar + en.

## 3. Tools
- Hide the brain games section from the Tools tab (remove the section + its imports from `tools_screen.dart`; do NOT delete `lib/features/games/` files — later cleanup).

## Tests — `test/v3/today_tools_test.dart`
hero shows days practiced count from seeded data; exactly one primary button in the hero card; SOS button visible without scrolling (small screen 360×640); evening slot state at 10:00 / 19:00 / done; goal tip for each goal/week; no games section in Tools.
