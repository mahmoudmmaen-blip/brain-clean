# Backup and Recovery Checklist

Use this checklist to pause Brain Clean V2 safely and restore it later on a Windows machine **without relying on chat history**.

**Never copy secret values into Git, screenshots shared publicly, or this document.**

---

## A. Git repository backup

- [ ] Confirm workspace: `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2`
- [ ] Confirm branch: `v2/product-rebuild`
- [ ] Record closure HEAD: `425147e6f8c5cc2a45c93af9c99a046608ba3969`
- [ ] Confirm clean tree: `git status --short` empty for tracked files
- [ ] Mirror / clone backup of the repository to an encrypted offline or private backup location
- [ ] Store the branch name + full commit hash with the backup catalog

---

## B. Signing secrets (local only)

- [ ] Confirm local exists: `android/key.properties` (gitignored)
- [ ] Confirm local exists: upload keystore JKS (example path pattern under `android/app/*.jks`, gitignored)
- [ ] Confirm ignore rules: `git check-ignore -v` on both files succeeds
- [ ] Confirm **not** tracked: `git ls-files` does not list `key.properties` or `*.jks`
- [ ] Copy keystore + `key.properties` to an **encrypted** offline backup (password manager / encrypted disk)
- [ ] Store keystore passwords only in the password manager — never in Git

Placeholders only in notes:

```
storeFile=<PATH_TO_UPLOAD_KEYSTORE>
keyAlias=<UPLOAD_KEY_ALIAS>
```

---

## C. Monetization / store configuration (dashboard, not Git)

Record configuration **names** and IDs as dashboard bookmarks; never paste secret API keys into Git:

- [ ] RevenueCat project for Android package `com.brainclean.mobile`
- [ ] Public SDK key storage location (CI/secret store): `<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>`
- [ ] Entitlement identifier(s) as configured in dashboard
- [ ] Offering identifier(s) as configured in dashboard
- [ ] Product identifiers for Monthly / Annual (Play Console + RevenueCat linked)
- [ ] Google Play Console app: package `com.brainclean.mobile`
- [ ] Closed Testing track notes for `2.0.1+18`
- [ ] Closed-test tester opt-in count (store “≥12” evidence kept in operator notes — **do not commit tester emails**)
- [ ] Privacy policy URL used in Play listing / Data Safety
- [ ] Store listing assets and screenshots (export zip offline)
- [ ] AAB metadata: version name `2.0.1`, version code `18`, package `com.brainclean.mobile`

---

## D. Build command template (no real key)

Document the **shape** of a release build command. Substitute secrets at build time only:

```bat
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

Confirm before building:

- [ ] `pubspec.yaml` version is intentional
- [ ] `applicationId` / `namespace` remain `com.brainclean.mobile`
- [ ] Release signing resolves via gitignored `android/key.properties`

---

## E. Restoration on a new Windows machine

1. Install Flutter stable, Android SDK, JDK 17, Git.
2. Restore repository at branch `v2/product-rebuild` and verify `git rev-parse HEAD`.
3. Restore **encrypted** `key.properties` + upload keystore into the expected local Android paths (still gitignored).
4. Run `flutter pub get`.
5. Confirm ignore: `git check-ignore -v` for secrets.
6. Inject RevenueCat public SDK key via dart-define / CI secret — never commit it.
7. Build a smoke AAB only after version bump rules are understood.
8. Re-read `docs/BRAIN_CLEAN_V2_FINAL_HANDOFF.md` before any Play upload.

---

## F. What this checklist never stores

- Signing passwords
- Private keys / certificate PEMs
- RevenueCat secret keys
- Real AdMob application IDs (ads deferred on V2 root)
- Tester personal emails
- Customer identifiers / receipts
