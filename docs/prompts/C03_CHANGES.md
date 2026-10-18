# C03 — Changes

## Files changed
- `assets/content/program.json` — swap day content 4↔9 (notif audit early) and 5↔8 (home screen early); adjust day-5 “this week” wording
- `assets/content/exercises.json` — `ex_notif_audit`, `ex_home_screen` → tier `free`
- `assets/content/sos.json` — bored flow starts with `suggest_replacement` (duration 5); grounding text optional second step
- `lib/v3/domain/sos_night.dart` — 23:00–05:00 window + sleep-first ordering
- `lib/v3/domain/in_app_review_gate.dart` — SOS-win / once / paywall-day rules
- `lib/v3/application/in_app_review_service.dart` — Play + fake review service; `maybeRequestInAppReview`
- `lib/v3/application/sos_now_provider.dart` — injectable clock for night SOS
- `lib/v3/ui/sos/sos_hub_screen.dart` — night: sleep first + highlight + dim palette
- `lib/v3/ui/sos/sos_flow_screen.dart` — bored pick-to-end + optional grounding; after-rate one-tap; big «من X إلى Y» + Share; review on SOS win; night dim
- `lib/v3/ui/share/share_card.dart` — RepaintBoundary PNG share (`sosWin` / `dayMilestone`)
- `lib/v3/ui/session/session_player_screen.dart` — «شارك إنجازك» on days 7/14/30; review after Day 3; mark paywall date on Day 7
- `lib/v3/ui/paywall/v3_paywall_screen.dart` — records `lastPaywallShownDate`
- `lib/v3/data/v3_storage_keys.dart` / `v3_app_state.dart` / `v3_state_repository.dart` — review + paywall-date flags
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated) — share / or-try-this copy
- `pubspec.yaml` — `in_app_review`
- `test/v3/content_sos_share_test.dart` — C03 coverage
- `test/v3/sos_and_tools_test.dart` — bored first-step update
- `docs/prompts/QUEUE_ORDER.md` — C03 → REVIEW
- `docs/prompts/C03_CHANGES.md` — this file

## Not done / why
- Build — task says Build: no.
- Real Play In-App Review dialog — only shown on device when `isAvailable()`; fake service covers tests.

## Deviations
- PLAN item 2 said pause-breath / attention-anchor become Pro; C03 keeps them `free` (allowed on Pro days) per task file.
- Day-5 home-screen lesson “this week redesign” line rewritten so week-1 copy stays coherent after the swap.

## Analyze
```
flutter analyze
No issues found! (ran in 146.2s)
```

## Tests
```
flutter test --timeout 60s test/v3/content_sos_share_test.dart
00:01 +11: All tests passed!

flutter test --timeout 60s
00:10 +123: All tests passed!
```

## git log -1 --stat
```
commit eef7fd56cb3971edcebc1ab3630b1f7803df0f89
Author: Mahmoud <mahmoud.mma.en@gmail.com>
Date:   Sun Oct 18 15:57:14 2026 +0300

    v3: week-1 early wins, SOS v2, share card, in-app review

 assets/content/exercises.json                 |  2239 +--
 assets/content/program.json                   |  2236 +--
 assets/content/sos.json                       |     8 +-
 docs/prompts/C03_CHANGES.md                   |    48 +
 docs/prompts/C03_content_sos_share.md         |    27 +
 docs/prompts/QUEUE_ORDER.md                   |     4 +-
 lib/v3/ui/share/share_card.dart               |   186 +
 lib/v3/ui/sos/sos_flow_screen.dart            |   252 +-
 test/v3/content_sos_share_test.dart           |   228 +
 29 files changed, 24941 insertions(+), 23773 deletions(-)
```
