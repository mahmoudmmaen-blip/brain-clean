# Root Build Authority — Brain Clean V2

**Purpose:** Prevent shipping the nested legacy Flutter app to Google Play.
**Canonical product:** Root V2 app only.

---

## Authoritative workspace and paths

Google Play release builds and local product verification **must** run only from the repository root:

```
C:\Users\FUTURE\Documents\GitHub\brain-clean-v2
```

| Authority | Path |
|---|---|
| Authoritative workspace | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2` |
| Authoritative `pubspec.yaml` | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\pubspec.yaml` |
| Authoritative Android project | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\android` |
| Authoritative Dart entrypoint | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\lib\main.dart` |

**Repo root check:** `git rev-parse --show-toplevel` must end with `brain-clean-v2` and must **not** end with `brain_clean_mobile`.

---

## Canonical V2 product shell

Four tabs only (Build Spec NAV-SHELL):

**Today · Plan · Progress · Profile**

Release cold start (when `V2_ENABLED=true`): Splash → `/v2/home` via `StartupDestination`.

---

## Canonical commands (ROOT ONLY)

```bat
cd C:\Users\FUTURE\Documents\GitHub\brain-clean-v2

flutter run -d emulator-5554 --dart-define=V2_ENABLED=true

flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

---

## NEVER use the nested legacy tree

**Never build** Play releases from `brain_clean_mobile/`.
**Never** run `flutter run`, `flutter build`, or Play release commands from:

```
brain_clean_mobile/
```

That folder is a **legacy reference only**. It is not the V2 product surface.

Risks of building from the wrong folder:

- Both projects currently share Android `applicationId` `com.brainclean.mobile` — **dangerous**
- A nested/legacy AAB can replace or confuse the Play package identity
- Nested UI is the old five-tab shell (Home / Exercises / Safa / Journey / More)
- Nested displayed version is `1.2.3`, not the root V2 release identity

Do **not** delete the nested tree in baseline phases; treat it as non-authoritative quarantine.

---

## Preflight before any build or UI slice

```powershell
git rev-parse --show-toplevel
git branch --show-current
Select-String -Path pubspec.yaml -Pattern '^version:'
Select-String -Path android\app\build.gradle* -Pattern 'applicationId|namespace'
```

Expected:

- toplevel path contains `brain-clean-v2` and does **not** end in `brain_clean_mobile`
- branch: `v2/product-rebuild` (unless an approved follow-on branch)
- root `applicationId` / `namespace`: `com.brainclean.mobile`

---

## Verification before upload

1. Cwd is repository root (not nested)
2. `pubspec.yaml` version matches the intended release (`2.0.1+18` or a later intentional bump)
3. Build includes `--dart-define=V2_ENABLED=true`
4. Store-installed smoke shows four-tab V2: Today · Plan · Progress · Profile
5. In-app version matches root `AppConfig.appVersion`
6. Closed Testing `2.0.1+18` is **not** V2-qualified; a new versionCode **> 18** is required for re-qualification
