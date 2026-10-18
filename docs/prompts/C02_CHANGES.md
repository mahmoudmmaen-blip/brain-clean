# C02 — Changes

## Files changed
- `lib/v3/domain/clarity_question_order.dart` — re-check shuffle seeded by check date; baseline keeps file order
- `lib/v3/domain/screen_time_reframe.dart` — Y = round(hours × 365 / 24)
- `lib/v3/domain/trial_offer_gate.dart` — when to show one-time `/offer`
- `lib/v3/domain/trial_status.dart` — trial-ending window + once-per-trial key
- `lib/v3/application/clarity_check_session_provider.dart` — stores ordered questions
- `lib/v3/application/trial_status_provider.dart` — `trialStatusProvider` (+ injectable now)
- `lib/v3/data/v3_storage_keys.dart` / `v3_app_state.dart` / `v3_state_repository.dart` — `trialOfferShown`, `trialEndingNoticeKey`
- `lib/v3/ui/onboarding/setup_screen.dart` — name field removed
- `lib/v3/ui/onboarding/clarity_check_screen.dart` — screen-time first (unchanged order) + recheck shuffle
- `lib/v3/ui/onboarding/result_plan_screen.dart` — reframe card; routes to `/offer` or Day 1
- `lib/v3/ui/paywall/trial_offer_screen.dart` — one-time yearly trial offer
- `lib/v3/ui/today/trial_ending_sheet.dart` + `today_screen.dart` — once-per-trial bottom sheet
- `lib/v3/routing/v3_routes.dart` / `v3_router.dart` — `/offer`
- `lib/features/pro/domain/purchases_sdk_port.dart` — `isTrialPeriod` / `expirationDate` on snapshot
- `lib/features/pro/data/purchases_flutter_sdk_port.dart` — read RC `PeriodType.trial` + expiration
- `lib/features/pro/domain/subscription_service.dart` (+ RC / local / unavailable) — `loadCustomerSnapshot()`
- `lib/core/l10n/app_en.arb` / `app_ar.arb` + generated localizations — reframe, offer, ending copy
- `test/v3/onboarding_trial_test.dart` — C02 coverage
- `docs/prompts/QUEUE_ORDER.md` — C02 → REVIEW
- `docs/prompts/C02_CHANGES.md` — this file

## Not done / why
- Play Console / RevenueCat yearly 14-day trial config — Mahmoud (not code).
- Name field in Settings/letter — later tasks (C07 / letter).
- Build — task says Build: no.

## Deviations
- Spec §4.3 still lists optional name on Setup; PLAN_AFTER_REVIEW + C02 remove it (name later in letter/Settings).
- Trial-ending charge line uses yearly store price when available; falls back to "—" if offerings fail offline.

## Analyze
```
flutter analyze
No issues found! (ran in 4.9s)
```

## Tests
```
flutter test --timeout 60s test/v3/onboarding_trial_test.dart
00:01 +16: All tests passed!

flutter test --timeout 60s
00:12 +111: All tests passed!
```

## git log -1 --stat
```
commit d0a3ef9b0a03b260b2fe19b9fb7fbf698218fbc9
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Sun Oct 18 12:27:31 2026 +0300

    v3: onboarding v2, one-time trial offer, trial-ending notice

 docs/prompts/C02_CHANGES.md                        |  50 ++
 docs/prompts/C02_onboarding_trial.md               |  23 +
 docs/prompts/QUEUE_ORDER.md                        |   4 +-
 lib/core/l10n/app_ar.arb                           |  32 +
 lib/core/l10n/app_en.arb                           |  32 +
 .../clarity_check_session_provider.dart            |  19 +
 lib/v3/application/trial_status_provider.dart      |  48 ++
 lib/v3/ui/paywall/trial_offer_screen.dart          | 265 +++++++++
 lib/v3/ui/today/trial_ending_sheet.dart            | 164 ++++++
 test/v3/onboarding_trial_test.dart                 | 650 +++++++++++++++++++++
 34 files changed, 1722 insertions(+), 32 deletions(-)
```
