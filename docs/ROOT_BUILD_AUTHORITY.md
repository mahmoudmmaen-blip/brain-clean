# Root Build Authority — Brain Clean V2

**Purpose:** Prevent shipping the nested legacy Flutter app to Google Play.

---

## Authoritative Play release project

Google Play release builds **must** be run only from the repository root:

```
C:\Users\FUTURE\Documents\GitHub\brain-clean-v2
```

| Authority | Path |
|---|---|
| Authoritative `pubspec.yaml` | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\pubspec.yaml` |
| Authoritative Android project | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\android` |
| Authoritative Dart entrypoint | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\lib\main.dart` |

Canonical release template (from root only):

```bat
flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

---

## Never build Play releases from the nested tree

**Do not** run Play release builds from:

```
brain_clean_mobile/
```

That folder is a **legacy reference** Flutter application. It is not the V2 product surface shipped from this branch.

Risks of building from the wrong folder:

- Both projects currently share Android `applicationId` `com.brainclean.mobile`
- Uploading a nested/legacy AAB can replace or confuse the Play package identity
- Nested UI is the old five-tab shell (Home / Exercises / Safa / Journey / More)
- Nested displayed version is `1.2.3`, not the root V2 release identity

---

## Verification before upload

Confirm cwd is repository root, then verify:

1. `pubspec.yaml` version matches the intended release (e.g. `2.0.1+18` or later)
2. Build command includes `--dart-define=V2_ENABLED=true`
3. Store-installed smoke shows the **four-tab** V2 shell: Today · Plan · Progress · Profile
4. In-app version display shows the root `AppConfig.appVersion` (must match the published name)
