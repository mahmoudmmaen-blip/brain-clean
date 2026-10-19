# Brain Clean Product Operating System — Baseline Authority

**Document:** `docs/BC_POS_BASELINE_AUTHORITY.md`  
**Phase:** 0.1 — Baseline Reconciliation & Freeze  
**Product:** Brain Clean V2  
**Status target:** `BASELINE_AUTHORITY_ESTABLISHED`

This is the authoritative Phase 0 baseline for all future UX, UI, refactoring, and feature work.  
Everything after this document must reference it.

---

## 1. Workspace

| Field | Value |
|---|---|
| Authoritative workspace | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2` |
| Repository root | Must contain `brain-clean-v2`; must **not** end in `brain_clean_mobile` |
| Primary branch | `v2/product-rebuild` |
| HEAD before Phase 0.1 | `7b77a36ac58e89dba17b1b0b5e8fe674acc91745` |
| HEAD subject before Phase 0.1 | `fix(startup): launch canonical V2 shell in V2 releases` |

See also: `docs/ROOT_BUILD_AUTHORITY.md`.

---

## 2. Product identity

| Field | Value |
|---|---|
| Dart package name | `brain_clean_mobile` |
| Android `applicationId` | `com.brainclean.mobile` |
| Android `namespace` | `com.brainclean.mobile` |
| Version (pubspec) | `2.0.1+18` |
| versionName | `2.0.1` |
| versionCode | `18` |
| In-app display version | `AppConfig.appVersion` = `2.0.1` |
| Launcher label | `Brain Clean` |
| MaterialApp title | `Brain Clean` |
| MainActivity | `android/app/src/main/kotlin/com/brainclean/mobile/MainActivity.kt` |
| Canonical entrypoint | `lib/main.dart` |

---

## 3. Canonical product surface

| Field | Value |
|---|---|
| Canonical app | **Root V2 only** |
| Gate | `--dart-define=V2_ENABLED=true` → `V2FeatureBoundary` / `StartupDestination` |
| Cold start (V2 on) | Splash → `/v2/home` |
| Canonical shell | Four tabs: **Today · Plan · Progress · Profile** |
| Shell implementation | `lib/features/v2_shell/` |

Nested tree `brain_clean_mobile/` is **legacy reference only** and is **non-authoritative** for product and Play work.

---

## 4. Build authority

| Allowed | Forbidden |
|---|---|
| `flutter run` / `flutter build` from repo root | Any build/run from `brain_clean_mobile/` |
| Root `pubspec.yaml` + root `android/` | Nested pubspec / nested android for Play |
| Root `lib/main.dart` | Nested `brain_clean_mobile/lib/main.dart` as product entry |

Shared `applicationId` between root and nested apps is **dangerous**. Wrong cwd can ship Legacy UI under the Play identity.

### Exact release template (root only)

```bat
cd C:\Users\FUTURE\Documents\GitHub\brain-clean-v2
flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

### Exact local V2 verification template (root only)

```bat
cd C:\Users\FUTURE\Documents\GitHub\brain-clean-v2
flutter run -d emulator-5554 --dart-define=V2_ENABLED=true
```

### Preflight command sequence

```powershell
git rev-parse --show-toplevel
git branch --show-current
Select-String -Path pubspec.yaml -Pattern '^version:'
Select-String -Path android\app\build.gradle* -Pattern 'applicationId|namespace'
```

---

## 5. Release state (facts — not fixed in Phase 0.1)

| Fact | Status |
|---|---|
| Google Play Production | **Not** published / pending Play access |
| Closed Testing `2.0.1+18` | **Active but NOT V2-qualified** (store build exposed Legacy startup defect) |
| Local startup correction | Present at `7b77a36` (routes V2-enabled cold starts to four-tab shell) |
| Next store binary | Requires intentional **versionCode > 18** + Play-installed V2 visual verification |
| AAB rebuild | Not part of this baseline phase |

Do **not** claim Production readiness.  
Do **not** claim Closed Test version 18 is V2-qualified.

---

## 6. Do-not-touch list during UI refinement

Do not modify in ordinary UI/polish slices:

- `brain_clean_mobile/**` (entire nested legacy app)
- Recovery Score / Brain Check scoring engines and contracted formulas
- RevenueCat product / entitlement / offering IDs
- Android signing (`android/key.properties`, `*.jks`, Gradle signing blocks)
- `applicationId` / `namespace`
- `lib/core/v2/v2_feature_boundary.dart` and `lib/core/routing/startup_destination.dart` unless an approved startup slice
- Frozen product contracts: `docs/BRAIN_CLEAN_V2_*_CONTRACT_V1.md`
- Hive adapters / persistence schema without a migration slice
- Generated `*.g.dart` / `*.freezed.dart` without intentional regeneration

---

## 7. Phase 0.1 reconciliation notes

| Issue | Resolution in 0.1 |
|---|---|
| Dirty generated l10n | Classified as CRLF/LF drift only; content matched HEAD/ARB; restored clean |
| Nested legacy ambiguity | Hardened in `ROOT_BUILD_AUTHORITY.md` + this document |
| Launcher label | `brain_clean_mobile` → `Brain Clean` (label only) |
| Documentation authority drift | This document becomes Phase 0 source of truth |
| Store version 18 qualification | Documented as release debt only (no build/upload) |

---

## 8. Authority statement

**Canonical product for all future work:** root Brain Clean V2 on branch `v2/product-rebuild`, four-tab shell, package `com.brainclean.mobile`.

**UI refinement may begin** only against root V2 surfaces after this baseline is committed, and must not use the nested legacy app.

**Store / Production work** remains a separate release gate requiring a new versionCode and Play verification.
