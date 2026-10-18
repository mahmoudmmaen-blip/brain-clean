# C04 — Changes

## Files changed
- `assets/content/goal_tips.json` — moved from `docs/prompts/content/`; weekly tips per goal
- `docs/prompts/content/goal_tips.json` — removed (moved)
- `pubspec.yaml` — register `goal_tips.json` asset
- `lib/v3/content/goal_tips_content.dart` — parse + `mapProfileGoal` (`browse` → `less_scroll`)
- `lib/v3/content/content_bundle.dart` / `content_repository.dart` / `content.dart` — load tips; `goalTip(goal, week)`
- `lib/v3/ui/today/today_screen.dart` — days-practiced hero, pinned SOS, fixed evening slot states, goal tip card, hierarchy reorder
- `lib/v3/ui/tools/tools_screen.dart` — hide brain games section (files under `lib/features/games/` kept)
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated) — evening slot locked / open / done copy
- `test/v3/today_tools_test.dart` — C04 coverage
- `test/v3/sos_and_tools_test.dart` — games section assertion updated (hidden)
- `docs/prompts/QUEUE_ORDER.md` — C04 → REVIEW
- `docs/prompts/C04_CHANGES.md` — this file

## Not done / why
- Build — task says Build: no.
- Deleting `lib/features/games/` — task says keep for later cleanup.

## Deviations
- Spec §4.5 still listed SOS in the scroll stack and evening only after 18:00 + day done; PLAN / C04 win: SOS pinned above bottom nav, evening slot always present with three states (no day-done gate).
- Spec §4.10 still lists brain games; PLAN item 12 / C04 hide them from Tools.

## Analyze
```
flutter analyze
No issues found! (ran in 28.1s)
```

## Tests
```
flutter test --timeout 60s test/v3/today_tools_test.dart
00:02 +9: All tests passed!

flutter test --timeout 60s
00:12 +132: All tests passed!
```

## git log -1 --stat
```
commit b08be9b69e621ebc8648006c22f5c0805e5c25d8
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Sun Oct 18 19:03:16 2026 +0300

    v3: today hierarchy, days practiced, goal tips, hide brain games

 assets/content/goal_tips.json           |  30 +++
 docs/prompts/C04_CHANGES.md             |  67 ++++
 docs/prompts/C04_today_tools.md         |  27 ++
 docs/prompts/QUEUE_ORDER.md             |   4 +-
 lib/core/l10n/app_ar.arb                |   3 +
 lib/core/l10n/app_en.arb                |   3 +
 lib/core/l10n/app_localizations.dart    |  18 ++
 lib/core/l10n/app_localizations_ar.dart |   9 +
 lib/core/l10n/app_localizations_en.dart |   9 +
 lib/v3/content/content.dart             |   1 +
 lib/v3/content/content_bundle.dart      |   3 +
 lib/v3/content/content_repository.dart  |  22 +-
 lib/v3/content/goal_tips_content.dart   |  79 ++++++
 lib/v3/ui/today/today_screen.dart       | 420 ++++++++++++++++++++++----------
 lib/v3/ui/tools/tools_screen.dart       |  71 ------
 pubspec.yaml                            |   1 +
 test/v3/sos_and_tools_test.dart         |  18 +-
 test/v3/today_tools_test.dart           | 236 ++++++++++++++++++
 18 files changed, 803 insertions(+), 218 deletions(-)
```
