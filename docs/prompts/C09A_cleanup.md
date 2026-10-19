# C09A — Pre-release cleanup (dead code + dead files)

Build: **no**
Commit message: `v3: remove dead supabase code, unused platforms, legacy docs`
Source: Kimi repo review 2026-10-19. Required before C09 release.

## Delete folders (not referenced by V3)
- `ai-pipeline/`, `worker/`, `.continue/`
- `web/`, `linux/`, `macos/`, `windows/` (Android-only app; keep `ios/`)
- `supabase/` (server config from V2 — V3 is offline-first)

## Remove dead Supabase code (careful — code, not just files)
- Remove `supabase_flutter` from `pubspec.yaml` (+ `pub get`)
- Delete `lib/core/network/supabase_client.dart`, `lib/core/security/secure_remote_write.dart`, `lib/core/security/authenticated_session.dart`
- Fix every import/reference (check `lib/main.dart`, `lib/core/config/app_config.dart`, `lib/core/services/connectivity_service.dart`) — remove init calls, keep the app booting offline
- Remove Safa-only strings from ARB if nothing else uses them

## Archive legacy docs (move, don't delete)
- Move V2-era root docs (`BRAIN_CLEAN_MASTER.md`, `BC_POS_BASELINE_AUTHORITY.md`, `FINAL_RELEASE_STATUS.md`, `PRODUCTION_DAY_CHECKLIST.md`, `CURSOR_PROMPTS.md`, `RELEASE_NOTES_2.0.1.md`, `ROOT_BUILD_AUTHORITY.md`, `VERSION_HISTORY.md`, `KNOWN_ISSUES_AND_DEBT.md`, `BACKUP_AND_RECOVERY_CHECKLIST.md`, `MAINTENANCE_GUIDE.md`) to `docs/archive-v2/`
- Keep: `docs/v3/`, `docs/prompts/`, `docs/store/`, `docs/privacy-policy/`, `docs/RUNNER_SETUP.md`

## Gates
- `flutter analyze` = 0 issues
- `flutter test` = all green (delete/adjust tests that tested deleted supabase code)
- App still boots offline; no network imports remain in lib/

## No-touch
- package name `com.brainclean.mobile`, signing files, RevenueCat ids, `assets/content/`, `lib/v3/`
