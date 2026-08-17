# Brain Clean V2 — Phase 10.4 Internal Test Release Report

**Document ID:** `BRAIN_CLEAN_V2_PHASE_10_4_INTERNAL_TEST_RELEASE_REPORT`  
**File:** `docs/BRAIN_CLEAN_V2_PHASE_10_4_INTERNAL_TEST_RELEASE_REPORT.md`  
**Status:** `V2_INTERNAL_TEST_AAB_READY_WITH_DEVICE_DEBT`  
**Date:** 2026-08-04  
**Branch:** `v2/product-rebuild`  
**Base HEAD:** `0512c97d4b79a65060ad17c3c4c798624d5ce528`

---

## 1. Version

| | Value |
|---|---|
| Before | `1.0.0+1` |
| After | `2.0.0+17` |
| `AppConfig.appVersion` | `2.0.0` |
| Play highest known versionCode | 16 → **17 OK** |

## 2. Package identity

| Field | Observed |
|---|---|
| `applicationId` / namespace | `com.example.brain_clean_mobile` |
| Manifest package | `com.example.brain_clean_mobile` |
| `applicationIdSuffix` | None |
| Matches Phase 10.3 log package | Yes |
| Nested legacy package (`com.brainclean.mobile`) | Unchanged; **not** used for this AAB |

**Note:** Console ownership of `com.example.brain_clean_mobile` must be confirmed by the operator before Play upload. This phase did not rename packages.

## 3. Signing verification (no secrets)

| Field | Observed |
|---|---|
| `android/key.properties` present | **No** |
| Release signing config | Falls back to **existing debug signing** (with warning) |
| New keystore created | **No** |
| Play-upload ready signature | **No** — debug-signed AAB must **not** be uploaded until the approved release keystore/`key.properties` is configured locally |

## 4. V2 release enablement

- Flag: compile-time `bool.fromEnvironment('V2_ENABLED', defaultValue: false)` via `V2FeatureBoundary.compileTimeV2Enabled`
- Runtime test override preserved (`enableBrainProfileRoutes` setter / `clearRuntimeOverride`)
- Release AAB built with `--dart-define=V2_ENABLED=true` (embedded at build time)
- Unit tests without define keep compile-time default **false**
- Four-tab shell remains Today / Plan / Progress / Profile when V2 ON

## 5. RevenueCat key handling

| Step | Result |
|---|---|
| Interactive `Read-Host` | Unavailable (non-interactive agent shell) |
| Env key at build | Absent → `REVENUECAT_ANDROID_KEY_FORMAT=INVALID` |
| AAB RC dart-define | **Not embedded** this build |
| `.env` / source writes | None |
| Cleared after | `REVENUECAT_ANDROID_KEY_CLEARED=YES` |

Consequence: store purchase path in this AAB remains **store unavailable** until a rebuild with a valid public Android SDK key dart-define.

## 6. RevenueCat logging repair

- `AppConfig.configPresenceLabel` now returns only `configured` / `unavailable` (no length, no prefix)
- `AppConfig.revenueCatInitLogLine` emits only:
  - `RevenueCat initialization succeeded`
  - `RevenueCat configuration unavailable`
- `RevenueCatSubscriptionService` uses those lines only
- Regression covered in `test/monetization_wiring_test.dart` + `test/v2_release_startup_test.dart`

Observed Phase 10.3 / physical log strings (`PurchasesService: configured (set(len=…,prefix=goog…))` and `AdsService: Mobile Ads initialized`) originate from **nested** `brain_clean_mobile` sources, not the root V2 `lib/` startup path. Root V2 does not depend on `google_mobile_ads`.

## 7. Notification R8 root cause and repair

| Item | Detail |
|---|---|
| Root cause | R8 stripped Gson `TypeToken` generic Signature metadata used by `flutter_local_notifications` scheduled-notification persistence |
| Plugin version | `flutter_local_notifications` ^17.0.0 → resolved **17.2.4** |
| Repair | Enabled minify/shrink on release; added `android/app/proguard-rules.pro` with Signature / TypeToken / plugin keeps (plugin example–aligned) |
| Runtime TypeToken proof on device | **Still required** (debt) |

## 8. Ads-deferred enforcement

- Root `pubspec.yaml`: no `google_mobile_ads`
- Root `lib/main.dart` / `lib/**`: no AdsService / MobileAds init
- Automated assertion in `v2_release_startup_test.dart`
- Nested legacy ads code untouched

## 9. Supabase duplicate classification

- Root `main` calls `SupabaseConfig.initialize()` **once**
- Root has **no** `SupabaseAuthService` / anonymous sign-in
- Duplicate `anonymous sign-in failed` log lines are **not** present in root V2 startup; classified as nested/legacy or multi-process — **no root code change**

## 10. Automated validation

| Check | Result |
|---|---|
| `flutter pub get` | exit 0 |
| `flutter analyze` | exit 0 — No issues found |
| `flutter test` | exit 0 — **+566** |
| Focused release/startup + monetization | green |

## 11. AAB artifact

| Field | Value |
|---|---|
| Path | `build/app/outputs/bundle/release/app-release.aab` |
| Size | 51,105,420 bytes (~48.7 MB) |
| SHA-256 | `6F3A78A3D8BD27E5C48FBD89CE24B31A9956D8C595D00EB0947FE3A96E0EA236` |
| applicationId | `com.example.brain_clean_mobile` |
| versionName | `2.0.0` |
| versionCode | `17` |
| minSdk | 24 |
| targetSdk | 36 |
| ABIs | `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64` |
| Release APK | Not created |
| AAB count | 1 |
| Staged in git | **No** |
| V2_ENABLED baked | Yes (`true`) |
| RC key baked | **No** |
| Signing | Debug fallback |

## 12. Local release smoke

Not completed on a connected Play device in this phase (no release keystore install path; prior emulator used local debug). Runtime verification of V2 tabs, notifications under R8, and Premium remains **required** after a properly signed rebuild/install.

## 13. Security checks

| Check | Result |
|---|---|
| Root tracked RC/Claude/private-key patterns | No production secrets |
| Nested test fixture `goog_…` placeholder | Present only under nested tests (ignored for upload) |
| `key.properties` tracked | 0 |
| `.env` tracked | 0 |
| AAB staged | No |
| Key cleared | YES |

## 14. Exact Google Play upload checklist

1. Place approved `android/key.properties` + keystore (gitignored).  
2. Rebuild AAB with:
   - `--dart-define=V2_ENABLED=true`
   - `--dart-define=REVENUECAT_ANDROID_API_KEY=…` (terminal-only; never chat/docs)  
3. Confirm output is **release-keystore signed** (not debug).  
4. Confirm Play Console app id matches `com.example.brain_clean_mobile` **or** stop and reconcile identity.  
5. Upload Internal Testing only (manual).  
6. Add license testers.  
7. Re-run Phase **10.3R** store sandbox purchase/restore on the Play-installed build.

**Do not upload the debug-signed AAB produced in this phase.**

## 15. Remaining debt

- Release keystore signing  
- RevenueCat public SDK key dart-define rebuild  
- Play Console package confirmation  
- Device smoke: V2 four-tab, notifications under R8, Premium/Reports/Safa  
- Phase 10.3R Play billing requalification  

## 16. Final Production Release Gate

**Must not begin.** Internal Testing upload may begin **only after** a release-signed, RC-keyed rebuild.

---

**End of Phase 10.4 report.**
