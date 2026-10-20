# C09 — Changes

## Files changed
- `docs/v3/RELEASE_CHECKLIST.md` — manual device checklist covering C01–C08 (onboarding/trial, day 4–5 content, SOS bored/night, share, review, usage ask, paywall day 7, trial-ending, backup, AR/EN, light/dark, text scale, after-30, notifications).
- `docs/prompts/C09_CHANGES.md` — this file.
- `docs/prompts/QUEUE_ORDER.md` — C09 → REVIEW.

## Version (already set; verified)
- `pubspec.yaml` — `3.0.0+37`
- `lib/core/config/app_config.dart` — `AppConfig.appVersion = '3.0.0'`

## Release AAB
- Path: `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\build\app\outputs\bundle\release\app-release.aab`
- Size: **52.47 MB** (55,016,799 bytes)
- Built via `.\build_release.ps1` (RevenueCat Android key from `.env` dart-define).

## Not done / why
- Manual Play Console upload / Internal app sharing — Mahmoud.
- Device walkthrough of `RELEASE_CHECKLIST.md` — Mahmoud.
- Did not start C10.

## Deviations
- First `build_release.ps1` failed on corrupted Gradle transform `metadata.bin` after disk cleanup; wiped `~\.gradle\caches` + daemons and rebuilt successfully (~21 min).

## Analyze
```
flutter analyze
No issues found! (ran in 117.5s)
```

## Tests
```
flutter test --timeout 60s
00:19 +166: All tests passed!
```

## git log -1 --stat
```
4f4180c v3: release 3.0.0 (+37)
 docs/prompts/C09_CHANGES.md  | 40 +++++++++++++++++++
 docs/prompts/QUEUE_ORDER.md  | 14 +++----
 docs/v3/RELEASE_CHECKLIST.md | 92 ++++++++++++++++++++++++++++++--------------
 3 files changed, 111 insertions(+), 35 deletions(-)
```
