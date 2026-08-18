# Maintenance Guide — Brain Clean V2

Operational guide for reopening the repo after the development pause.

---

## 1. Required tools

| Tool | Notes (closure environment examples) |
|---|---|
| Flutter | Stable channel (closure machine reported Flutter 3.41.x / Dart 3.11.x) |
| Android SDK | With platform-tools, build-tools, and SDK 35/36 as project requires |
| JDK | 17 |
| Git | Local only for routine work; push is an explicit operator decision |
| Android Studio / VS Code | Optional IDE |

Do not assume identical versions forever — pin what you used for the last successful Closed Testing AAB.

---

## 2. Restore dependencies

```bat
cd C:\Users\FUTURE\Documents\GitHub\brain-clean-v2
git checkout v2/product-rebuild
git rev-parse HEAD
flutter pub get
flutter analyze
flutter test
```

---

## 3. Safe release-build procedure

1. Confirm branch + clean tree.
2. Confirm version bump is intentional (`pubspec.yaml` `x.y.z+CODE`).
3. Confirm package remains `com.brainclean.mobile`.
4. Confirm `android/key.properties` + keystore present and gitignored.
5. Build with V2 enabled and RevenueCat public key via dart-define (never commit the key).
6. Upload only the intended track (Closed Testing vs Production).
7. Record the bundle version code in `docs/VERSION_HISTORY.md` after successful console ingest.

---

## 4. Version bump rules

| Change | Version name | Version code |
|---|---|---|
| Closed Testing / Production binary change | Bump patch or minor as product requires | **Must increment** (never reuse 18 for a different binary) |
| Docs-only | No bump | No bump |
| Hotfix to store | New code | New code > last Play-accepted code |

Current Android binary in `pubspec.yaml`: **2.0.1+23**. Closed Testing `2.0.1+18` is historical and not V2-qualified.

---

## 5. Package / signing invariants

- `applicationId` = `com.brainclean.mobile`
- `namespace` = `com.brainclean.mobile`
- Reuse the **approved upload keystore** unless executing an official Play key-reset process
- Never commit keystore / `key.properties`

---

## 6. RevenueCat configuration procedure

1. Dashboard offerings/products remain linked to Play products for `com.brainclean.mobile`.
2. Build injects **public** SDK key via `--dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>`.
3. Verify entitlement after install from Play (not only local debug).
4. Do not log raw receipts or customer IDs in shared reports.

---

## 7. Produce a new AAB

```bat
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

Output path (Flutter default): `build/app/outputs/bundle/release/app-release.aab`  
Do not commit AABs.

---

## 8. Test through Google Play

1. Prefer Closed Testing or Internal track installs for billing truth.
2. Confirm installer package is Play (`com.android.vending`) before purchase conclusions.
3. Use license testers for sandbox purchases.
4. Document results without pasting receipts.

---

## 9. Verify installer source

On device, confirm Play-delivered installs before declaring store qualification complete. Local `adb install` / debug builds cannot fully prove Play billing.

---

## 10. Monthly / Annual / Restore tests

Checklist (sandbox / license tester):

- [ ] Monthly purchase succeeds and unlocks entitlement
- [ ] Annual purchase succeeds and unlocks entitlement
- [ ] Cancel mid-flow leaves Free state honest
- [ ] Restore restores entitlement on reinstall / second device account scenario as designed
- [ ] Free core features remain usable without purchase

---

## 11. Crashes and ANRs

1. Google Play Console → Android Vitals / Crashes & ANRs.
2. Reproduce on matching package + version code when possible.
3. Prefer redacted logs; never paste secrets.
4. Fix on a branch; bump version code for any store re-upload.

---

## 12. Emergency rollback

1. In Play Console, halt / rollback Production **only if Production exists** (it does not at closure).
2. For Closed Testing, pin testers to last known good version code.
3. Do not force-push Git history to “erase” a bad release; cut a fix-forward version.

---

## 13. Creating a new version code

1. Edit `pubspec.yaml` version (`name+code`).
2. Rebuild signed AAB.
3. Upload; wait for processing.
4. Update `CHANGELOG.md` + `docs/VERSION_HISTORY.md`.

---

## 14. Files that must never be committed

- `android/key.properties`
- `**/*.jks` / keystore binaries
- Real `.env` files with secrets
- Release AABs / APKs
- RevenueCat private / secret API keys
- Play service account JSON keys
- Unredacted purchase receipts / customer IDs
- Tester personal email lists

Allowed examples only: `*.env.example` without secrets.
