# C06 — Changes

## Files changed
- `android/app/src/main/AndroidManifest.xml` — `PACKAGE_USAGE_STATS` (+ `xmlns:tools`)
- `android/app/src/main/kotlin/com/brainclean/mobile/UsageStatsHelper.kt` — AppOps check, settings intent, `queryEvents` daily totals
- `android/app/src/main/kotlin/com/brainclean/mobile/MainActivity.kt` — MethodChannel `brainclean/usage`
- `lib/v3/data/usage_day_total.dart` — day total model
- `lib/v3/data/usage_ask_flags.dart` — ask gate (max 2)
- `lib/v3/data/usage_data_source.dart` — channel + fake source
- `lib/v3/domain/usage_math.dart` — yesterday / 7-day avg / من A إلى B
- `lib/v3/application/usage_providers.dart` — access, cache, ask notifier
- `lib/v3/data/v3_storage_keys.dart` / `v3_state_repository.dart` — ask flags + 30-day cache in v3 box
- `lib/v3/ui/progress/usage_access_sheet.dart` — opt-in sheet (ARB)
- `lib/v3/ui/progress/usage_summary_card.dart` — real hours card (hidden without access)
- `lib/v3/ui/progress/progress_screen.dart` — ask #1 on Progress open (after Day 1)
- `lib/v3/ui/sos/sos_flow_screen.dart` — ask #2 after first SOS win if #1 declined
- `lib/v3/ui/paywall/v3_paywall_screen.dart` — Day-7 hours chip from real usage from/to
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated) — sheet + card copy
- `test/v3/usage_data_test.dart` — ask gate, math, cache, card, paywall chip
- `docs/prompts/QUEUE_ORDER.md` — C06 → REVIEW
- `docs/prompts/C06_CHANGES.md` — this file

## Not done / why
- Build — task says Build: no.
- Settings «تفعيل» row — reserved for C07.
- Store listing / Play Data Safety form — Mahmoud: listing already mentions screen-time in `docs/store/STORE_LISTING.md`; Data Safety → data stays on device → "not collected".

## Deviations
- Usage totals computed in `UsageStatsHelper` (not inline in MainActivity) for clarity; channel API matches the task.
- Ask #1 gated to Progress after Day 1 (program day ≥ 1) so Day-0 onboarding is not interrupted.

## Analyze
```
flutter analyze
No issues found! (ran in 6.1s)
```

## Tests
```
flutter test --timeout 60s test/v3/usage_data_test.dart
00:01 +12: All tests passed!

flutter test --timeout 60s
00:27 +153: All tests passed!
```

## git log -1 --stat
```
commit 37f2192
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Mon Oct 19 11:37:57 2026 +0300

    v3: opt-in real screen-time data

 android/app/src/main/AndroidManifest.xml           |   3 +
 .../kotlin/com/brainclean/mobile/MainActivity.kt   |  19 ++
 .../com/brainclean/mobile/UsageStatsHelper.kt      | 164 ++++++++++++
 docs/prompts/C06_CHANGES.md                        |  50 ++++
 docs/prompts/QUEUE_ORDER.md                        |   6 +-
 lib/core/l10n/app_ar.arb                           |  25 +-
 lib/core/l10n/app_en.arb                           |  25 +-
 lib/core/l10n/app_localizations.dart               |  54 ++++
 lib/core/l10n/app_localizations_ar.dart            |  35 +++
 lib/core/l10n/app_localizations_en.dart            |  35 +++
 lib/v3/application/usage_providers.dart            |  85 +++++++
 lib/v3/data/usage_ask_flags.dart                   |   9 +
 lib/v3/data/usage_data_source.dart                 |  91 +++++++
 lib/v3/data/usage_day_total.dart                   |  24 ++
 lib/v3/data/v3_state_repository.dart               |  51 ++++
 lib/v3/data/v3_storage_keys.dart                   |   3 +
 lib/v3/domain/usage_math.dart                      |  81 ++++++
 lib/v3/ui/paywall/v3_paywall_screen.dart           |   5 +
 lib/v3/ui/progress/progress_screen.dart            |  29 ++-
 lib/v3/ui/progress/usage_access_sheet.dart         |  90 +++++++
 lib/v3/ui/progress/usage_summary_card.dart         | 109 +++++++-
 lib/v3/ui/sos/sos_flow_screen.dart                 |   9 +
 test/v3/usage_data_test.dart                       | 274 +++++++++++++++++++++
 23 files changed, 1260 insertions(+), 16 deletions(-)
```
