# C01 — Changes

## Files changed
- `lib/features/pro/domain/subscription_plan.dart` — `trialConfirmed` / `trialDays` / `trialLabel` on plan model
- `lib/features/pro/domain/trial_period.dart` — ISO-8601 / unit+value → days parser
- `lib/features/pro/domain/purchases_sdk_port.dart` — `trialDays` on `StorePackageRef`
- `lib/features/pro/data/purchases_flutter_sdk_port.dart` — read Google `defaultOption.freePhase.billingPeriod`
- `lib/features/pro/data/revenuecat_subscription_service.dart` — pass trial fields through
- `lib/features/v2_premium/domain/premium_offering.dart` — `trialDays`
- `lib/features/v2_premium/data/subscription_premium_store_port.dart` — pass through store trial (no longer force `false`)
- `lib/v3/ui/paywall/v3_paywall_screen.dart` — full C01 layout (close after 2s, personal header, 3 benefits, yearly primary + trial CTA, pinned bottom bar)
- `lib/v3/ui/paywall/paywall_price_math.dart` — savings % + monthly equivalent amount
- `lib/v3/ui/paywall/paywall_personal_stats.dart` — day/urge/clarity chips from local v3 state
- `lib/core/l10n/app_en.arb`, `app_ar.arb` + generated localizations — new paywall copy (3 benefits, trial, chips)
- `test/v3/paywall_test.dart` — C01 coverage with fake store port
- `docs/prompts/QUEUE_ORDER.md` — C01 → REVIEW
- `docs/prompts/C01_CHANGES.md` — this file

## Not done / why
- Real phone-hours chip («ساعات الموبايل: من A إلى B») — requires usage-stats opt-in from C06; hidden until that data exists (no fake hours).
- Play Console / RevenueCat yearly trial offer config — Mahmoud checklist (not code).
- Build — task says Build: no.

## Deviations
- Purchase success navigates with `context.go(/today)` after `purchased` phase (spec allows pop or Today). Widget tests accept either left-paywall or subscribed manage UI because GoRouter stack quirks under `UncontrolledProviderScope` made strict pop flaky.
- Spec §4.13 still listed 4 benefits / exercise library; PLAN_AFTER_REVIEW + C01 override to exactly 3 benefits (no SOS, no exercise library).

## Analyze
```
flutter analyze
No issues found! (ran in 58.6s)
```

## Tests
```
flutter test --timeout 60s test/v3/paywall_test.dart
00:01 +15: All tests passed!

flutter test --timeout 60s
00:09 +95: All tests passed!
```

## git log -1 --stat
```
commit a9411b40c2aa0c42bfa0650ed2796de4665825c3
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Sun Oct 18 11:06:46 2026 +0300

    v3: paywall with real purchase, 14-day yearly trial, personal day-7 header

 docs/prompts/C01_CHANGES.md                        |  44 ++
 docs/prompts/C01_paywall.md                        |  40 +
 docs/prompts/QUEUE_ORDER.md                        |  25 +
 docs/prompts/RULES.md                              |  41 ++
 lib/core/l10n/app_ar.arb                           | 162 ++--
 lib/core/l10n/app_en.arb                           | 163 ++--
 lib/core/l10n/app_localizations.dart               | 126 +++-
 lib/core/l10n/app_localizations_ar.dart            |  82 ++-
 lib/core/l10n/app_localizations_en.dart            |  82 ++-
 .../pro/data/purchases_flutter_sdk_port.dart       |  20 +-
 .../pro/data/revenuecat_subscription_service.dart  |   3 +
 lib/features/pro/domain/purchases_sdk_port.dart    |   2 +
 lib/features/pro/domain/subscription_plan.dart     |  14 +-
 lib/features/pro/domain/trial_period.dart          |  48 ++
 .../data/subscription_premium_store_port.dart      |   8 +-
 .../v2_premium/domain/premium_offering.dart        |   4 +
 lib/v3/ui/paywall/paywall_personal_stats.dart      |  69 ++
 lib/v3/ui/paywall/paywall_price_math.dart          |  91 +++
 lib/v3/ui/paywall/v3_paywall_screen.dart           | 818 +++++++++++++++++++--
 test/v3/paywall_test.dart                          | 493 +++++++++++++
 20 files changed, 2156 insertions(+), 179 deletions(-)
```
