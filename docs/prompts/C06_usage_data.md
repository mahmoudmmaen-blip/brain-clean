# C06 — Real screen-time data (opt-in, on-device)

Build: **no**
Commit message: `v3: opt-in real screen-time data`
PLAN item 1. Depends on C03 (SOS win) and C05 (Progress slot).

## Android side (no new pub package)
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />` (+ `xmlns:tools` if missing).
- MethodChannel `brainclean/usage` in `MainActivity.kt`:
  - `hasAccess()` → AppOpsManager `OPSTR_GET_USAGE_STATS` == MODE_ALLOWED.
  - `openSettings()` → `Settings.ACTION_USAGE_ACCESS_SETTINGS`.
  - `dailyTotals(days: Int)` → list of {date, minutes} for the last N local days, using `UsageStatsManager.queryEvents` (ACTIVITY_RESUMED/PAUSED pairs) summed per day, excluding this app and the default launcher. Return quickly; never block UI.
- Dart: `lib/v3/data/usage_data_source.dart` (interface + channel impl + fake for tests) and providers in `lib/v3/application/usage_providers.dart`. Store nothing on any server. Cache the last 30 days in the v3 box.

## Asking (max 2 times per install, flags in v3 box)
- Ask #1: first time the Progress tab opens (after Day 1). Ask #2: after the first SOS win (urge drop ≥ 2), only if #1 was declined. Never again after that (a «تفعيل» row stays in Settings, C07).
- Sheet copy (ARB AR+EN):
  «لنعرض لك ساعات استخدامك الحقيقية بدلًا من التقدير، نحتاج إذن «الوصول إلى بيانات الاستخدام» من إعدادات الموبايل.»
  «بياناتك تبقى على جهازك فقط، ولا تُرسَل إلى أي مكان.»
  Buttons: «فتح الإعدادات» / «لاحقًا». Re-check access on app resume.

## Using it
- Progress `UsageSummaryCard`: yesterday's hours, 7-day average, and «من A إلى B» (first 7 days avg vs last 7 days avg) once ≥ 3 days of data. Label «تقريبي».
- Day-7 paywall chip «ساعات الموبايل: من A إلى B» (C01 hook) when available.
- Without access: everything keeps working with self-reported hours; no nagging.

## Tests — `test/v3/usage_data_test.dart` (fake data source)
ask #1 on first Progress open only; ask #2 only after declined #1 + SOS win; never a 3rd time; card hidden without access; averages and «من A إلى B» computed correctly; paywall chip appears only with data.

## Note for Mahmoud (write it in CHANGES)
Store listing must mention screen-time tracking (docs/store/STORE_LISTING.md already updated). Data Safety: data stays on device → "not collected".
