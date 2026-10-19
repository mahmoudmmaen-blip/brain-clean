# C08 — Changes

## Files changed
- `lib/v3/domain/notification_plan.dart` — max-2/day planner (daily / evening / clarity)
- `lib/v3/application/notification_scheduler.dart` — schedule via `AppNotificationService`
- `lib/core/services/app_notification_service.dart` — clarity payload + reminders channel
- `lib/v3/ui/migration/migration_screen.dart` — one-time pre-V3 migration → delete legacy boxes
- `lib/core/constants/hive_meta_keys.dart` — `v3MigrationCompleted`
- `lib/features/splash/presentation/splash_screen.dart` — migration gate + reschedule on start
- `lib/v3/routing/v3_routes.dart` / `v3_startup.dart` / `v3_router.dart` — `/migration`
- `lib/v3/ui/today/today_screen.dart` — after Day 30 UI + restart (DayProgress only)
- `lib/v3/ui/settings/settings_screen.dart` — reschedule on reminder/evening change
- `lib/v3/ui/session/session_player_screen.dart` — medium haptic + reschedule on complete
- `lib/v3/domain/western_digits.dart` — Western digits helpers
- `lib/v3/ui/common/v3_motion.dart` — reduce-motion aware haptics/duration
- `lib/v3/ui/shell/v3_shell_keys.dart` — tab keys (extracted)
- Deleted `lib/v3/ui/placeholders/v3_simple_placeholder.dart`, `lib/v3/ui/shell/v3_tab_placeholder.dart`
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated)
- `test/v3/notifications_polish_test.dart`
- `docs/prompts/QUEUE_ORDER.md` — C08 → REVIEW

## Not done / why
- Build — task says Build: no.
- `supabase_flutter` kept — still imported under `lib/core/network` and security helpers.
- Exhaustive polish on every V3 screen (every IconButton/animation) — applied to high-traffic surfaces (Today, Session, Clarity, Settings, Progress bars); remaining screens already mostly compliant.

## Copy audit (banned words)
- `assets/content/*`: only allowed negation in clarity_check (`ليس تشخيصًا طبيًا`). False positive `لتلفت` in program.json.
- Active V3 ARB: `v3NotMedical` uses علاج in negation («ليس علاجًا طبيًا»).
- Many V2-legacy ARB keys still contain تشخيص / علاج / intelligence / treat (disclaimers or unused V2 copy). Not rewritten in C08 (out of V3 UI path). Zero new banned claims introduced.

## Deviations
- Clarity re-check notification shares the daily reminder time slot (replaces daily copy on days 7/14/21/30).
- `V3ShellKeys` kept in `v3_shell_keys.dart` after deleting tab placeholder.

## Analyze
```
flutter analyze
No issues found! (ran in 7.1s)
```

## Tests
```
flutter test --timeout 60s test/v3/notifications_polish_test.dart
00:01 +7: All tests passed!

flutter test --timeout 60s
00:17 +166: All tests passed!
```

## git log -1 --stat
```
43e0943 v3: notifications, migration, after-program, polish and cleanup
30 files changed, 1169 insertions(+), 121 deletions(-)
```
