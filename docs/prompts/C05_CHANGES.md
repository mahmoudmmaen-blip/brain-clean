# C05 — Changes

## Files changed
- `lib/v3/ui/program/program_screen.dart` — Program tab: 4 week sections, day tiles (done / today / future / Pro lock)
- `lib/v3/ui/program/program_day_review_screen.dart` — read-only day review (lesson, practice, saved inputs)
- `lib/v3/ui/progress/progress_screen.dart` — Progress tab: clarity chart, phone hours, calendar, stats, mood chart, empty state
- `lib/v3/ui/progress/usage_summary_card.dart` — empty slot for C06 real usage (renders nothing)
- `lib/v3/domain/program_day_tile.dart` — tile state helper
- `lib/v3/domain/progress_calendar.dart` — calendar cell states + Sat/Mon week start
- `lib/v3/domain/progress_stats.dart` — days practiced, streaks, challenges, focus, urges, clarity/hours
- `lib/v3/domain/program_engine.dart` — `bestStreak`
- `lib/v3/routing/v3_router.dart` / `v3_routes.dart` — wire Program/Progress screens + `/program/day/:n`
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated) — Program/Progress copy
- `test/v3/program_progress_test.dart` — C05 coverage
- `docs/prompts/QUEUE_ORDER.md` — C05 → REVIEW
- `docs/prompts/C05_CHANGES.md` — this file

## Not done / why
- Build — task says Build: no.
- Real usage hours on Progress — reserved for C06 via `UsageSummaryCard` (shrink).

## Deviations
- Progress body uses `SingleChildScrollView` + `Column` (not `ListView`) so charts/stats/calendar all mount for tests and RTL layout.
- Calendar week headers start Sat (AR) / Mon (else); day 1 sits in column 0 (no calendar-date alignment to profile `createdAt`).

## Analyze
```
flutter analyze
No issues found! (ran in 17.3s)
```

## Tests
```
flutter test --timeout 60s test/v3/program_progress_test.dart
00:02 +9: All tests passed!

flutter test --timeout 60s
00:17 +141: All tests passed!
```

## git log -1 --stat
```
commit ca78fb7
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Sun Oct 18 19:20:37 2026 +0300

    v3: program tab and progress tab

 docs/prompts/C05_CHANGES.md                      |  69 ++
 docs/prompts/C05_program_progress.md             |  24 +
 docs/prompts/QUEUE_ORDER.md                      |   4 +-
 lib/core/l10n/app_ar.arb                         |  42 +-
 lib/core/l10n/app_en.arb                         |  42 +-
 lib/core/l10n/app_localizations.dart             | 108 ++++
 lib/core/l10n/app_localizations_ar.dart          |  62 +++
 lib/core/l10n/app_localizations_en.dart          |  63 +++
 lib/v3/domain/program_day_tile.dart              |  41 ++
 lib/v3/domain/program_engine.dart                |  38 +-
 lib/v3/domain/progress_calendar.dart             |  75 +++
 lib/v3/domain/progress_stats.dart                |  87 ++++
 lib/v3/routing/v3_router.dart                    |  25 +-
 lib/v3/routing/v3_routes.dart                    |   2 +
 lib/v3/ui/program/program_day_review_screen.dart | 211 ++++++++
 lib/v3/ui/program/program_screen.dart            | 247 +++++++++
 lib/v3/ui/progress/progress_screen.dart          | 635 +++++++++++++++++++++++
 lib/v3/ui/progress/usage_summary_card.dart       |  13 +
 test/v3/program_progress_test.dart               | 435 ++++++++++++++++
 19 files changed, 2181 insertions(+), 15 deletions(-)
```
