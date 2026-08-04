# Brain Clean V2 — Phase 10.3 Device & Store Qualification Report

**Document ID:** `BRAIN_CLEAN_V2_PHASE_10_3_DEVICE_STORE_QUALIFICATION_REPORT`  
**File:** `docs/BRAIN_CLEAN_V2_PHASE_10_3_DEVICE_STORE_QUALIFICATION_REPORT.md`  
**Status:** `PHASE_10_3_PARTIAL_DEVICE_QUALIFICATION`  
**Date:** 2026-08-04  
**Baseline HEAD (pre):** `d5d10a05438dcac418f374bd55845023d771d9f6`  
**Authorities:** Production Monetization & Privacy Contract V1; Phase 10.2 wiring report; Premium / Reports contracts  

---

## 1. Device and OS (no personal identifiers)

| Field | Observed |
|---|---|
| Device | Android Emulator `emulator-5554` (`sdk gphone64 x86 64`) |
| OS | Android 15 (API 35) |
| Physical Play device | **Not connected** |
| `adb` (PATH) | Not available globally; used Android SDK `platform-tools\adb.exe` |
| Flutter | 3.41.7 stable / Dart 3.11.5 |

## 2. Installation source

| Field | Observed |
|---|---|
| Artifact | Local **debug** APK (`flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`) |
| Install | `adb install -r` success on `emulator-5554` |
| Package identity | `com.example.brain_clean_mobile` (unchanged) |
| Google Play test track | **Not used** |
| License tester account | **Not used / not available in this session** |
| Signing / identity changes | **None** |
| Release APK / AAB | **Not built** |

**Classification:** Debug-device application behavior only.  
**Not qualified in this session:** Google Play Billing purchase sheets; sandbox purchase/restore via Play.

## 3. Test-account classification

- No Play license-tester account exercised.
- No tester email recorded.

## 4. Key-handling method

| Step | Result |
|---|---|
| Interactive `Read-Host` in agent shell | **Blocked** (`REVENUECAT_ANDROID_KEY_INPUT=NON_INTERACTIVE`) |
| Env pre-set key | Absent (`REVENUECAT_ANDROID_KEY_PRESENT=NO`) |
| Format validation | `REVENUECAT_ANDROID_KEY_FORMAT=INVALID` (empty / unavailable) |
| `.env` created/modified | **No** |
| Key printed / committed / logged | **No** |
| Post-run clear | `REVENUECAT_ANDROID_KEY_CLEARED=YES` |
| iOS key | Not set (no iOS device qualification) |

Valid-key RevenueCat initialization and store offerings were therefore **not device-observed**.

## 5. Automated baseline (before device)

| Check | Result |
|---|---|
| `flutter pub get` | exit **0** |
| `flutter analyze` | exit **0** — No issues found |
| `flutter test` | exit **0** — **+554** All tests passed |
| Failed / skipped | None observed |

## 6. Missing-key behavior (device-observed)

Debug APK installed **without** RevenueCat dart-define.

Observed:

- App launches; no crash during onboarding → home.
- Free V1 home usable (quote, recovery challenge, focus entry, accountability).
- Emotion/Pro entry opens **Brain Clean Pro** paywall.
- Paywall shows Arabic status **«المتجر غير متاح»** (Store unavailable).
- **Restore** control remains visible (**«استعادة الاشتراك»**).
- No store packages / prices rendered.
- Pro themes remain **locked** in Settings after paywall/restore attempt (no Hive-only Premium unlock observed).
- Force-stop + relaunch reaches app again without crash (splash → resume path observed).

## 7. RevenueCat initialization (valid key)

**NOT_TESTED / BLOCKED** — no public Android SDK key available in a non-interactive qualification shell; no valid-key debug rerun performed.

## 8. Offering / products

| Product / concern | Result |
|---|---|
| Current offering | **NOT_TESTED** (requires valid key + store) |
| `brainclean_monthly` | **NOT_TESTED** |
| `brainclean_yearly` | **NOT_TESTED** |
| `brainclean_lifetime` | **NOT_TESTED** |
| Localized price / period / trial | **NOT_TESTED** |
| Missing-key empty offering UI | **PASS** (store unavailable; no fake plans) |

Boundary note (evidence-based): local debug install of `com.example.brain_clean_mobile` on an AVD **cannot** truthfully prove Play product activation or test-track billing. Likely external blockers for full purchase qualification include at least: Play console product linkage, license tester, and a Play-distributed (or otherwise billing-capable) install — **not isolated further without a valid-key + Play session**.

## 9–11. Purchase / cancel / pending

| Scenario | Result |
|---|---|
| Purchase sheet open | **BLOCKED** (no Play billing session) |
| Sandbox purchase success | **BLOCKED** |
| Purchase cancel | **BLOCKED** |
| Purchase pending | **NOT_TESTED** |

## 12. Restore

| Scenario | Result |
|---|---|
| Restore control visible (missing key) | **PASS** |
| Restore activates Premium without store | **PASS** (did not unlock Pro themes) |
| Restore success with entitlement | **BLOCKED** |
| Nothing-to-restore (entitled account contrast) | **NOT_TESTED** |
| Idempotent restore under RC | **AUTOMATED_ONLY** |
| Reinstall restore | **NOT_TESTED** |

## 13. Restart / offline

| Scenario | Result |
|---|---|
| Force-stop relaunch (missing key / Free) | **PASS** (app relaunches; Free core preserved) |
| Offline cached entitlement | **NOT_TESTED** (no verified entitlement) |
| Offline unknown | **AUTOMATED_ONLY** / **NOT_TESTED** on device |
| Network restore refresh | **NOT_TESTED** |

## 14. Entitlement / Reports archive

| Scenario | Result |
|---|---|
| `Brain Clean` entitlement activation | **BLOCKED** |
| V2 Reports Free depth on device | **BLOCKED** — `V2FeatureBoundary.enableBrainProfileRoutes` defaults **false**; no `V2_ENABLED` dart-define wire in app |
| V2 Reports Premium unlock | **BLOCKED** |
| Free proof unchanged under missing key | **PASS** for V1 Free core; V2 Reports **NOT_TESTED** |
| Expiration / relock | **NOT_TESTED** / **unverified** |

## 15. Premium UI / accessibility

| Item | Result |
|---|---|
| V1 paywall store unavailable | **PASS** (device) |
| V1 restore visible | **PASS** |
| V2 PRE-01 / plans / success | **BLOCKED** (V2 flag off) |
| Arabic + RTL | **PASS** (onboarding, home, paywall, settings) |
| English locale full switch | **NOT_TESTED** (language control interaction not confirmed) |
| Text scale 2.0 / 320dp / TalkBack | **AUTOMATED_ONLY** (suite) / **NOT_TESTED** on device |
| No “remove ads” on observed paywall | **PASS** (observed copy) |
| Hardcoded store price on missing-key paywall | **PASS** (none shown) |

## 16. Safa / privacy

| Item | Result |
|---|---|
| In-app Settings → Privacy Policy row present | **PASS** |
| Privacy `onTap` navigates to document | **FAIL (pre-existing)** — `settings_screen.dart` uses empty `onTap: () {}` |
| Tracked privacy HTML EN/AR Safa disclosure | **PASS** (file review of `docs/privacy-policy/index.html`) |
| Device Safa consent before network | **BLOCKED** (V2 Safa route gated off) |
| No NVIDIA / no client Claude key claims in privacy HTML | **PASS** (file review) |
| Ads on Safa | **NOT_APPLICABLE** / ads deferred; Safa not opened on device |

No sensitive personal content sent during testing.

## 17. Security results

| Check | Result |
|---|---|
| No RC key in tracked sources (pattern scan) | `TRACKED_SECRET_PATTERN_HITS=0` |
| No key in agent output / this report | **PASS** |
| Env cleared | `REVENUECAT_ANDROID_KEY_CLEARED=YES` |
| `.env` ignored | Confirmed via `git check-ignore` (preflight-era) |
| No release artifact produced | **PASS** |
| No new ads/UMP/ad IDs | **PASS** (no code change this phase) |

## 18. Qualification matrix

| # | Item | Status |
|---|---|---|
| 1 | Device detection | **PASS** (emulator) |
| 2 | V2 flag ON | **BLOCKED** (default false; no dart-define) |
| 3 | Missing-key state | **PASS** |
| 4 | Valid-key initialization | **BLOCKED** |
| 5 | Current offering | **BLOCKED** |
| 6 | Monthly package | **BLOCKED** |
| 7 | Annual package | **BLOCKED** |
| 8 | Lifetime package | **BLOCKED** |
| 9 | Localized price | **BLOCKED** |
| 10 | Trial/intro offer | **NOT_TESTED** |
| 11 | Purchase-sheet open | **BLOCKED** |
| 12 | Purchase success | **BLOCKED** |
| 13 | Purchase cancellation | **BLOCKED** |
| 14 | Purchase pending | **NOT_TESTED** |
| 15 | Entitlement activation | **BLOCKED** |
| 16 | Reports archive unlock | **BLOCKED** |
| 17 | Restart hydration | **PARTIAL** (Free restart PASS; entitled hydration NOT_TESTED) |
| 18 | Offline cached state | **NOT_TESTED** |
| 19 | Offline unknown state | **AUTOMATED_ONLY** |
| 20 | Restore success | **BLOCKED** |
| 21 | Nothing to restore | **NOT_TESTED** |
| 22 | Restore idempotency | **AUTOMATED_ONLY** |
| 23 | Reinstall restore | **NOT_TESTED** |
| 24 | Expiration/relock | **NOT_TESTED** (explicitly unverified) |
| 25 | Free core preservation | **PASS** |
| 26 | No recovery mutation | **PASS** (no recovery surfaces mutated in session) |
| 27 | Arabic UI | **PASS** |
| 28 | English UI | **NOT_TESTED** (full locale) |
| 29 | RTL/LTR | **PASS** (RTL observed) |
| 30 | Text scale 2.0 | **AUTOMATED_ONLY** |
| 31 | TalkBack | **NOT_TESTED** |
| 32 | Safa disclosure (device) | **BLOCKED** |
| 33 | Privacy-page disclosure (device render) | **FAIL** (noop tile) / **PASS** (tracked HTML) |
| 34 | Security/key handling | **PASS** |
| 35 | No ads | **PASS** |
| 36 | No UMP | **PASS** |
| 37 | No release artifact | **PASS** |

## 19. Observed defects and fixes

| Defect | Severity | Action |
|---|---|---|
| Settings Privacy Policy `onTap` is empty | Pre-existing UX; privacy document not opened on device | **Not fixed** in Phase 10.3 (out of RevenueCat purchase/qualification wire scope; no product redesign) |
| V2 surfaces require mutable test flag; no safe dart-define for device ON | External to Play billing but blocks V2 Reports/Safa device QA | Documented only |
| Emulator + local debug + `com.example.*` not Play billing-capable | External | Documented only |

**Production code changed in Phase 10.3:** none.

## 20. External configuration blockers

1. Non-interactive agent shell cannot collect RevenueCat Android public SDK key safely via `Read-Host`.
2. No Google Play closed-test / license-tester session.
3. Local debug install is not a Play test-track install.
4. ApplicationId remains example package (store listing / products not proven linked).
5. V2 feature gate defaults OFF for device builds.

## 21. Unverified scenarios

- Valid-key RC configure / offerings / packages / prices  
- Sandbox purchase success / cancel / pending  
- Entitlement activation + Reports depth unlock  
- Entitled restart / offline cache vs unknown  
- Restore success / reinstall restore  
- Expiration relock  
- TalkBack / textScale on device  
- Full English locale pass  
- In-app rendered privacy Safa section  
- Device Safa consent path  

## 22. Google Play / RevenueCat dashboard actions still required

- Confirm Android public SDK key injection via CI/`--dart-define` on a physical or Play-capable tester build  
- Link `brainclean_monthly` / `brainclean_yearly` / `brainclean_lifetime` to Play products  
- Confirm entitlement id `Brain Clean`  
- Install from Play test track with license tester  
- Execute monthly sandbox purchase + cancel + restore checklist  
- Optional: enable V2 gate for device QA of Premium/Reports/Safa surfaces  

## 23. Final Production Release Gate readiness

**Not ready.** Phase 10.3 did **not** produce store-purchase evidence. Automated Phase 10.2 wiring remains green; device/store sandbox remains open debt.

## 24. Post-run validation

| Check | Result |
|---|---|
| `flutter analyze` | exit **0** — No issues found |
| `flutter test` | exit **0** — **+554** All tests passed |
| `git status` before commit | report file only (docs) |
| Secrets staged | None |
| Release APK/AAB | None created beyond local debug APK under `build/` (untracked build output) |

## 25. Exact next task

**Device–store re-qualification on a Play test-track build** with terminal-local (non-chat) Android public SDK key injection, license tester account, and V2 surfaces explicitly enabled for QA — then decide Final Production Release Gate eligibility.

---

**End of Phase 10.3 report.**
