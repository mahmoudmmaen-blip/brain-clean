# Brain Clean V2 — Final Release Status

**Document:** `docs/FINAL_RELEASE_STATUS.md`  
**Product:** Brain Clean V2  
**Date stamped at closure HEAD:** `425147e6f8c5cc2a45c93af9c99a046608ba3969`  
**Authority:** Release Closure Engineer  

---

## Current state (canonical)

| Classification | Status |
|---|---|
| Development | **DEVELOPMENT_COMPLETE** |
| Google Play Closed Testing | **CLOSED_TEST_ACTIVE_NOT_V2_QUALIFIED** |
| Google Play Production | **PRODUCTION_PENDING_GOOGLE_PLAY** |

**This application is not in Production.**  
Do not claim production publication, production approval, or public store availability under Production track.

**Do not claim Closed Testing `2.0.1+18` is V2-qualified.** Version 18 store installs exposed a startup defect (Legacy `/home` despite `V2_ENABLED=true`). Startup correction is implemented locally; a new store version and Play-installed V2 verification remain required.

---

## Identity

| Field | Value |
|---|---|
| Branch | `v2/product-rebuild` |
| HEAD (closure baseline) | `425147e6f8c5cc2a45c93af9c99a046608ba3969` |
| HEAD subject | `build(android): bump closed test release to 2.0.1+18` |
| Version name | `2.0.1` |
| Version code | `18` |
| pubspec | `2.0.1+18` |
| Android `applicationId` | `com.brainclean.mobile` |
| Android `namespace` | `com.brainclean.mobile` |

---

## Google Play track status

| Track | Version | Status |
|---|---|---|
| Internal Testing | `2.0.0+17` | Prepared / historically used for V2 internal validation |
| Closed Testing | `2.0.1+18` | **Active — NOT V2-qualified** (startup → Legacy `/home` on store install; local startup correction pending new upload) |
| Production | — | **Not created** — production-access waiting period still active; Production approval **not** granted |

---

## Exact conditions required before Production

All of the following must be true before a Production release is created:

1. Google Play **Apply for production** / production-access waiting period completes and access is granted.
2. Closed Testing requirements remain satisfied (including tester opt-in duration rules as Play displays them).
3. Android Vitals and pre-launch report reviewed with no unresolved launch blockers.
4. Data Safety, App Access, Ads declaration, Content Rating, and privacy-policy URL remain accurate.
5. Subscriptions remain active in Play Console; RevenueCat entitlement and offering remain correct.
6. Approved signed bundle for `2.0.1+18` (or a later intentionally bumped version) is selected for Production.
7. Operator performs Production install validation, purchase, and restore after review approval.
8. Only after Production approval/availability: create an annotated production Git tag (not before).

---

## Final completion definition

| Layer | Definition of done |
|---|---|
| **Development** | V2 product surfaces implemented and integrated on `v2/product-rebuild`; automated suite green at last release engineering gates; package aligned with Play `com.brainclean.mobile`. |
| **Closed Testing** | Track active for package `com.brainclean.mobile`, but **`2.0.1+18` is not V2-qualified** until a corrected build is uploaded and Play-verified. |
| **Production** | Play Production track live with reviewed, installable build — **not yet achieved**. |

---

## What must not be changed while waiting

While paused for Google Play production access:

- Do **not** change Android package identity (`com.brainclean.mobile`).
- Do **not** rotate or replace the approved upload keystore without a deliberate Play key process.
- Do **not** commit `key.properties`, `*.jks`, `.env` secrets, AABs, or RevenueCat private keys.
- Do **not** silently lower version codes or reuse version code **18** for a different binary.
- Do **not** push unreviewed production code as “hotfixes” without a new release gate.
- Do **not** create a production Git tag before Production approval.
- Do **not** invent Production claims in store listing copy.

Version bumps after `2.0.1+18` require a new intentional release slice.

---

## Honest outstanding blockers (Production)

| Blocker | Classification |
|---|---|
| Google Play production-access waiting period still active | **Release blocker** |
| Production approval not granted | **Release blocker** |
| Production release not created | **Release blocker** |
| Full store-installed V2 runtime qualification (Play installer path) still required — version 18 is **not** V2-qualified after the startup defect | **Release readiness gap** |
| Local startup correction lands cold start on `/v2/home` when V2 enabled; requires new versionCode + Play visual verification | **Release readiness gap** |

These are **external Play / qualification** gates, not a claim that development is incomplete.

---

## Final project status summary

Brain Clean V2 development on branch `v2/product-rebuild` remains the development baseline; Closed Testing **`2.0.1+18` must not be treated as V2-qualified** after the version-18 startup defect. A local startup correction routes V2-enabled cold starts to the four-tab shell; a **new store version** is required before re-qualification.

**Production remains pending Google Play.**

**Closure verdict:** `DEVELOPMENT_CLOSED_PRODUCTION_PENDING` (with **startup re-qualification required**)
