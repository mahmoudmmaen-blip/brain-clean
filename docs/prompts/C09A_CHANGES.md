# C09A — Changes

## Files / folders changed
### Deleted folders
- `ai-pipeline/`, `worker/`, `.continue/`
- `web/`, `linux/`, `macos/`, `windows/`
- `supabase/`

### Supabase / network dead code
- Removed `supabase_flutter` from `pubspec.yaml` (+ lockfile via `pub get`)
- Deleted `lib/core/network/supabase_client.dart` (and empty `lib/core/network/`)
- Deleted `lib/core/security/secure_remote_write.dart`, `lib/core/security/authenticated_session.dart`
- Deleted `lib/core/services/connectivity_service.dart` (+ `.g.dart`) — Supabase-only online gate
- `lib/main.dart` — removed Supabase init
- `lib/core/config/app_config.dart` — removed Supabase / XP HMAC config surface
- `lib/core/security/secure_write_policy.dart` — local-only policy docs (no JWT/cloud map)
- Removed unused Safa ARB keys (`homeSafa*`, `v2Safa*`) + regenerated l10n

### Archived docs → `docs/archive-v2/`
- `BRAIN_CLEAN_MASTER.md`, `BC_POS_BASELINE_AUTHORITY.md`, `FINAL_RELEASE_STATUS.md`, `PRODUCTION_DAY_CHECKLIST.md`, `CURSOR_PROMPTS.md`, `RELEASE_NOTES_2.0.1.md`, `ROOT_BUILD_AUTHORITY.md`, `VERSION_HISTORY.md`, `KNOWN_ISSUES_AND_DEBT.md`, `BACKUP_AND_RECOVERY_CHECKLIST.md`, `MAINTENANCE_GUIDE.md`
- (These lived under `docs/` already, not repo root.)

### Queue / prompt
- `docs/prompts/C09A_cleanup.md`, `docs/prompts/C09A_CHANGES.md`
- `docs/prompts/QUEUE_ORDER.md` — C09A → REVIEW

## Not done / why
- Build — task says Build: no.
- Did not touch `lib/v3/`, signing, RevenueCat ids, `assets/content/`, package name.
- Store SDKs that still talk to Play/RevenueCat (`purchases_flutter`, etc.) remain — required for Pro; no Supabase/http cloud sync imports left in `lib/`.

## Deviations
- Also removed `connectivity_service` (not listed) because it imported Supabase and would not analyze after deletion.
- Legacy docs were under `docs/` (not repo root); archived to `docs/archive-v2/` as specified.

## Analyze
```
flutter analyze
No issues found! (ran in 17.3s)
```

## Tests
```
flutter test --timeout 60s
00:18 +166: All tests passed!
```

## git log -1 --stat
```
ec28746 v3: remove dead supabase code, unused platforms, legacy docs
109 files changed, 5362 insertions(+), 11654 deletions(-)
```
