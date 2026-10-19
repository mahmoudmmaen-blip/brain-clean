# C07 — Settings + Graduation + Letter + Backup

Build: **no**
Commit message: `v3: settings, graduation, letter, encrypted backup`
Spec: §4.12, §4.14, §4.15 + PLAN item 12.

## Settings — `lib/v3/ui/settings/settings_screen.dart` (replace `/settings` placeholder)
Rows, nothing else:
- Name (optional, edit), reminder time, evening check-in toggle
- Language AR/EN and theme dark/light (apply immediately)
- Biometric app lock (reuse `lib/core/security/biometric_gate.dart`)
- «بيانات الاستخدام الحقيقية»: status + «تفعيل» (opens usage settings, C06)
- Premium: «مشترك ✓» + «إدارة الاشتراك», or «اشترك» (→ `/paywall?source=settings`); «استعادة المشتريات»
- «نسخة احتياطية»: «تصدير» / «استيراد» (below)
- «رسالتي» → `/letter` (hidden if empty)
- Privacy policy (external browser), Contact (mailto from existing config/ARB)
- «إعادة ضبط كل البيانات» → confirm → clear v3 box → `/welcome` (Pro not affected)
- App version from `AppConfig.appVersion`
After it works: if nothing imports `lib/features/settings/settings_screen.dart`, delete that ONE file.

## Backup
- Export: serialize the whole v3 box to JSON, encrypt with AES-GCM using a key derived (PBKDF2, random salt, ≥100k iterations) from a 6+ character passphrase the user types twice; write `brainclean-backup-YYYYMMDD.bcb` to temp and open the share sheet (`share_plus`). Use existing crypto helpers if present, else add `cryptography` package.
- Import: pick file (share-target not required; use `file_picker`), ask passphrase, decrypt, validate version, confirm «سيستبدل هذا بياناتك الحالية», replace box, restart to `/today`. Wrong passphrase → friendly error, nothing changed.
- No server, nothing leaves the device unless the user shares the file.

## Graduation — `/graduation`
Clarity from first to latest («من X إلى Y»), hours before → after (real if C06 data, else self-report), days practiced, the saved letter, «اكتب قواعدك» (opens `ex_maintenance_plan` if rules empty), share (C03 card, `dayMilestone(30)`), «ماذا بعد؟» → `/today`.

## Letter — `/letter`
Read-only `UserInputs.futureLetter`, comfortable typography; ask the name here if empty (optional field, saved to profile).

## Tests — `test/v3/settings_graduation_test.dart`
reset clears data, Pro stays; language switch; letter row hidden when empty; export→import round trip restores identical data; wrong passphrase leaves data unchanged; graduation shows seeded before/after.
