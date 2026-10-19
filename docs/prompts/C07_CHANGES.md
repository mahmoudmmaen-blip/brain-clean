# C07 — Changes

## Files changed
- `pubspec.yaml` / `pubspec.lock` — `cryptography`, `file_picker`
- `lib/v3/data/v3_backup_crypto.dart` — PBKDF2 (≥100k) + AES-GCM `.bcb` envelope
- `lib/v3/data/v3_backup_codec.dart` — box dump / payload versioning
- `lib/v3/application/v3_backup_service.dart` — export to temp + share sheet; import bytes
- `lib/v3/data/v3_state_repository.dart` — `dumpBox` / `replaceAll`
- `lib/v3/data/user_profile.dart` — `clearName` on `copyWith`
- `lib/v3/application/v3_onboarding_gate_provider.dart` — `markOnboardingIncomplete`
- `lib/v3/ui/settings/settings_screen.dart` — full Settings (name, reminder, evening, lang, theme dark/light, biometric, usage enable, premium, backup, letter, legal, reset, version)
- `lib/v3/ui/settings/backup_passphrase_sheet.dart` — passphrase UI
- `lib/v3/ui/letter/letter_screen.dart` — read-only letter + optional name
- `lib/v3/ui/graduation/graduation_screen.dart` — clarity/hours/days/letter/rules/share/whats-next
- `lib/v3/routing/v3_router.dart` — wire settings, letter, graduation
- `lib/core/l10n/app_en.arb` / `app_ar.arb` (+ generated)
- `test/v3/settings_graduation_test.dart` — C07 coverage
- `test/helpers/hive_test_fixtures.dart` — `InMemoryHiveBox.clear`
- `lib/features/settings/settings_screen.dart` — deleted (unreferenced legacy)
- `docs/prompts/QUEUE_ORDER.md` — C07 → REVIEW
- `docs/prompts/C07_CHANGES.md` — this file

## Not done / why
- Build — task says Build: no.
- Share-target import — not required; `file_picker` only.
- Multi-theme beyond dark/light — task asks dark/light only.

## Deviations
- Backup crypto lives in `v3_backup_crypto.dart` (no prior AES-GCM helper for files).
- Manage subscription opens Play subscriptions URL (same as paywall), not a new RC API.

## Analyze
```
flutter analyze
No issues found! (ran in 9.7s)
```

## Tests
```
flutter test --timeout 60s test/v3/settings_graduation_test.dart
00:04 +6: All tests passed!

flutter test --timeout 60s
00:17 +159: All tests passed!
```

## git log -1 --stat
```
550f786 v3: settings, graduation, letter, encrypted backup
24 files changed, 2372 insertions(+), 648 deletions(-)
```
