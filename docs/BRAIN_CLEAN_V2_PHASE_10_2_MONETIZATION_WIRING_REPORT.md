# Brain Clean V2 — Phase 10.2 Monetization Wiring Report

**Document ID:** `BRAIN_CLEAN_V2_PHASE_10_2_MONETIZATION_WIRING_REPORT`  
**File:** `docs/BRAIN_CLEAN_V2_PHASE_10_2_MONETIZATION_WIRING_REPORT.md`  
**Status:** PHASE 10.2 COMPLETE WITH DEVICE DEBT  
**Date:** 2026-08-03  
**Authority:** `docs/BRAIN_CLEAN_V2_PRODUCTION_MONETIZATION_PRIVACY_CONTRACT_V1.md`  
**Baseline HEAD:** `19e40f5aafa2bb899bde434a280ff50e61c23b0c`

---

## 1. Adapter architecture

| Adapter | When selected | Grants Premium how |
|---|---|---|
| `RevenueCatSubscriptionService` | Valid platform public SDK key present | CustomerInfo entitlement `"Brain Clean"` (additive `"pro"` accepted) |
| `StoreUnavailableSubscriptionService` | Missing/placeholder key | **Never** via Hive; may read store-verified mirror only |
| `LocalSubscriptionService` | Explicit `forceLocalSubscriptionAdapterProvider=true` (tests/dev) | Hive `isProUser` (fake only) |

Production never silently selects Local. Missing key never falls through to Hive purchase grant.

SDK isolation: `PurchasesSdkPort` + `PurchasesFlutterSdkPort` + `FakePurchasesSdkPort`.

## 2. Configuration method

- Prefer `REVENUECAT_ANDROID_API_KEY` / `REVENUECAT_IOS_API_KEY` via `--dart-define` / dotenv  
- Transitional fallback: `REVENUECAT_API_KEY`  
- Placeholders treated as missing (`AppConfig.isPlaceholderConfigValue`)  
- Test override: `revenueCatApiKeyOverrideProvider` (never used in production)  
- **No real keys committed**; presence logs use redacted `configPresenceLabel` only  

## 3. Entitlement / products

| Kind | Value |
|---|---|
| Entitlement | `Brain Clean` |
| Additive (optional) | `pro` |
| Products | `brainclean_monthly`, `brainclean_yearly`, `brainclean_lifetime` |
| Local stubs | `pro_*` confined to Local fake adapter |

## 4. Initialization

- Configure once via `PurchasesSdkPort.configure`  
- Lazy on first `ensureInitialized` / offerings load  
- Free core continues on failure  
- CustomerInfo update listener applied when configured  

## 5. Offerings

- Current offering packages mapped to production product IDs only  
- Unknown packages ignored  
- Lifetime omitted when not in offering  
- Store-localized `priceString` only  

## 6–7. Purchase / Restore

- Single in-flight guard  
- Outcomes: success / cancel / pending / fail / already / storeUnavailable  
- Premium activates **only** when entitlement active after CustomerInfo  
- Restore idempotent; nothing-to-restore honest  
- No recovery-data writes  

## 8. Offline / cache

- In-memory verified entitlement from CustomerInfo  
- Hive `storeVerifiedPremium` + mirror `isProUser` are **descriptive mirrors** after store verification  
- Offline unknown (no verified mirror) → Free  
- Store-unavailable adapter may show cached verified only  

## 9. Hive reconciliation

| Source | Production authority? |
|---|---|
| RevenueCat CustomerInfo | **Yes** |
| `storeVerifiedPremium` mirror | Cache / offline descriptive only |
| `isProUser` alone | **No** for RC / store-unavailable adapters |

## 10. Reports archive

- Still gated by `ReportsArchiveGate` + `isProUserProvider` → adapter `isPro`  
- Unlock after verified purchase/restore  
- Free depth unchanged (latest + previous)  

## 11. Ads deferred

- No `google_mobile_ads` added  
- No UMP  
- Premium copy audited — no ad-removal claims  
- Root still renders no ads  

## 12. Safa privacy update

Updated:

- `docs/privacy-policy/index.html` (EN + AR)  
- `brain_clean_mobile/PRIVACY_POLICY.md`  
- `brain_clean_mobile/PRIVACY_POLICY_AR.md`  

Covers typed-only context, Edge boundary, no NVIDIA/client Claude, non-medical, decline + local fallback, no default archive.

## 13. Security checks

- No real SDK keys in tracked sources (pattern review)  
- `.env` remains gitignored  
- Errors/exceptions do not embed keys  
- Test fakes use non-secret placeholder strings like `goog_test_public_sdk_key`  

## 14. Validation (local)

- `flutter pub get` → exit 0 (`purchases_flutter` ^8.10.1 → resolved 8.11.0)  
- `flutter analyze` → exit 0 (No issues found)  
- Focused: `test/monetization_wiring_test.dart`, premium, local subscription, color theme, paywall smoke → green  
- Full suite: `flutter test` → **+554** all passed  
- Secret-pattern review on tracked sources: no real RevenueCat SDK keys; nested legacy AdMob test IDs remain outside root V2  
- V1 paywall: empty-offering / store-unavailable no longer crashes (`plans.first` guard)  

## 15. Remaining real-device / store verification

| Item | Status |
|---|---|
| Inject real Android/iOS public SDK keys via CI/dart-define | Required |
| Sandbox purchase monthly/yearly/(lifetime) | Required |
| Sandbox restore + idempotent restore | Required |
| Offline cached entitlement labeling on device | Required |
| App restart entitlement hydration | Required |
| Play/App Store product linkage to `brainclean_*` | Required |
| Confirm live entitlement id `"Brain Clean"` | Required |

## 16. Remaining blockers (not Phase 10.2 code)

- Device/store sandbox QA  
- Release decision for V2 feature flag ON  
- Ads remain deferred until a future ads contract  
- Nested `brain_clean_mobile` AdMob tree still exists unused by root  

## 17. Exact next task

**Phase 10.3 / Device–store qualification:** run sandbox purchase + restore checklists with injected public SDK keys; record results; do not invent ads.

---

**End of Phase 10.2 report.**
