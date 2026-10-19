# Known Issues and Debt — Closure Snapshot

**Snapshot HEAD:** `425147e6f8c5cc2a45c93af9c99a046608ba3969`  
**Rule:** Do not invent problems. Do not keep superseded Slice 9 “RevenueCat unwired” claims as current — Phase 10 monetization wiring later landed.

---

## 1. Release blockers (before Production publication)

| Item | Notes |
|---|---|
| Google Play production-access waiting period | Still active per operator; Production approval not granted |
| Production release not created | No V2 Production track live |
| Store-installed V2 runtime qualification | **Not satisfied by version 18** — store install showed Legacy startup; local startup correction exists; new store version + Play visual verify still required |
| Nested `brain_clean_mobile/` mistaken Play build | Same `applicationId` as root — see `docs/ROOT_BUILD_AUTHORITY.md`; never build Play releases from the nested tree |

These block **Production publication**, not the claim that development baseline exists.

---

## 2. Nonblocking debt (documented, not inventing new bugs)

| Item | Source / honesty |
|---|---|
| Ads deferred on V2 root | Phase 10.2 / 10.4: no `google_mobile_ads` on root V2; ads policy deferred until a future ads contract |
| Nested `brain_clean_mobile/` tree | Parallel/legacy nested project risk; **root only** is the Play release path (`docs/ROOT_BUILD_AUTHORITY.md`) |
| Version 18 Closed Test not V2-qualified | Startup defect (Legacy `/home`); corrected locally; new versionCode upload still required |
| Local startup correction pending store proof | Splash/biometric now use `StartupDestination` → `/v2/home` when V2 enabled; device/Play smoke still required |
| Notification R8 / TypeToken runtime proof | Phase 10.4 recorded ProGuard keep for Gson TypeToken; **device runtime proof under R8** still called out as required when qualifying Play builds |
| Supabase offline behavior | Root initializes Supabase config once; no anonymous auth service on root V2 path — treat network features as optional; do not assume offline sync |
| Temporary first-time journey boundary screens | Earlier journey slices intentionally retained as gates |
| Dual legacy Pro vs V2 Premium naming surfaces | Historical V1 Pro paywall may still exist in legacy routes; V2 uses Premium contracts |
| Missing dedicated Build Spec “SOS” screen ID (Safa path explicit) | Nonblocking catalog gap; Free safety path exists via Safa contract implementation |

---

## 3. Future enhancements (explicitly not done)

- Full production ads + UMP regional certification program
- Automatic Recovery Plan adaptation from WeeklyReviewSignal (signal stored; adaptation requires separate approved contract)
- Longitudinal Reports archive Premium depth expansions beyond frozen contracts
- Dedicated additional V2 deep-link polish beyond existing gated routes
- iOS store release engineering for V2 (this closure pack centers Android Play wait)

---

## 4. Explicitly deferred features

- Root V2 **advertising** implementation (`google_mobile_ads` intentionally absent on V2 root release surface)
- Production Git tag / GitHub Release (forbidden until Production approval)
- Any package rename away from `com.brainclean.mobile`

---

## 5. Resolved relative to older audits (do not re-open as current)

| Older claim | Current reality at closure |
|---|---|
| Slice 9: “RevenueCat remains unwired” | Superseded by Phase 10 monetization wiring commits culminating in production dart-define configuration |
| Internal package `com.example.brain_clean_mobile` | Reconciled to `com.brainclean.mobile` (`803cdca`) before Closed Testing `2.0.1+18` |

---

## 6. Test-suite status reminder

Automated `flutter analyze` / `flutter test` green at release engineering gates does **not** replace Play-installer purchase/restore qualification or Android Vitals monitoring after Production.
