# Brain Clean V2 — Production Monetization and Privacy Contract V1

**Document ID:** `BRAIN_CLEAN_V2_PRODUCTION_MONETIZATION_PRIVACY_CONTRACT_V1`  
**File:** `docs/BRAIN_CLEAN_V2_PRODUCTION_MONETIZATION_PRIVACY_CONTRACT_V1.md`  
**Status:** APPROVED FOR IMPLEMENTATION GOVERNANCE — CONTRACT FREEZE  
**Phase:** 10.1 (audit + freeze only; no RevenueCat wiring, ads wiring, privacy-doc edits, or release builds in this phase)  
**Date:** 2026-08-03  
**Role:** Production Monetization and Privacy Governance Board  
**Audited HEAD baseline:** `9e89ec38b96477778b305ad08b26d8f832f7c4f2`

---

## 1. Status and authority

### 1.1 Binding authorities (tracked)

| Authority | Role |
|---|---|
| `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md` | G2 ads exclusions; G9 Premium naming; G13 consent preserve |
| `docs/BRAIN_CLEAN_V2_PREMIUM_CONTRACT_V1.md` | Free core; entitlement `"Brain Clean"`; store products; offline honesty |
| `docs/BRAIN_CLEAN_V2_REPORTS_CONTRACT_V1.md` | Free archive depth = latest + previous |
| `docs/BRAIN_CLEAN_V2_SAFA_CONTRACT_V1.md` | Safa AI/network / Free safety / no Premium-only crisis |
| `docs/BRAIN_CLEAN_V2_SLICE_9_CLOSEOUT_REPORT.md` | Production blockers inventory |
| `lib/features/v2_premium/domain/premium_identifiers.dart` | Canonical entitlement + store product strings |
| `lib/features/pro/**` | Current root subscription interface / local adapter / RC stub |
| `lib/core/config/app_config.dart` | Approved secret resolution pattern |
| Nested `brain_clean_mobile/` ads & RC (reference only) | Not the root V2 production path until ported under this contract |

### 1.2 Precedence

1. This contract freezes **production monetization + privacy implementation rules** for Phase 10+.  
2. Premium Contract Free-safety bans and Reports Free depth cannot be weakened.  
3. Master / nested RC product & entitlement strings are authoritative for **existing purchases**.  
4. Root `LocalSubscriptionService` is **not** a production store.  
5. Nested tree must not silently become the root runtime without an explicit provider-selection change under this contract.

### 1.3 Non-goals of Phase 10.1

This document does **not** authorize:

- Wiring `purchases_flutter`  
- Real API keys or platform config edits  
- Ads implementation / AdMob units  
- Privacy policy HTML/MD edits  
- UMP UI changes  
- Premium / Reports / Safa / recovery feature behavior changes  

---

## 2. Current production blockers

| ID | Blocker | Evidence at closeout HEAD |
|---|---|---|
| B1 | Root `RevenueCatSubscriptionService` is an unwired `UnimplementedError` stub | `lib/features/pro/data/revenuecat_subscription_service.dart` |
| B2 | Provider always selects `LocalSubscriptionService` | `subscription_service_provider.dart` |
| B3 | Local stub product IDs + hardcoded USD | `pro_monthly` / `pro_annual` / `pro_lifetime` · `$4.99` / `$29.99` / `$79.99` |
| B4 | Root `pubspec.yaml` has **no** `purchases_flutter` / `google_mobile_ads` | Dependency audit |
| B5 | No root `Purchases.configure` | Root `lib/` |
| B6 | Local `restorePurchases` does not query a store | Hive invalidate only |
| B7 | Hive `isProUser` can grant local Premium without store proof | `LocalSubscriptionService.purchase` |
| B8 | Ads/UMP exist only in nested tree; root V2 renders **no** ads | Root ads search empty |
| B9 | Public privacy claims “no advertising SDKs” while nested AdMob exists | `docs/privacy-policy/index.html` conflict vs nested tree |
| B10 | Safa shipping disclosure / Terms accuracy still owed relative to V2 release bar | Slice 9 closeout + SAF contract |
| B11 | Device store sheets / sandbox restore unverified | Device debt |

---

## 3. Authoritative subscription architecture

### 3.1 Production

| Rule | Freeze |
|---|---|
| Authoritative source | **RevenueCat** (store CustomerInfo + Offerings) |
| Entitlement truth | Store entitlement active in CustomerInfo |
| Prices / trials / intro | Store offerings only |
| Hardcoded production prices | **Forbidden** |
| Fabricated Premium | **Forbidden** |
| Hive-only purchase activation | **Forbidden in production** |

### 3.2 Local development / automated tests

| Rule | Freeze |
|---|---|
| Deterministic local / fake adapter | Allowed |
| Selection | Explicit test/dev configuration only |
| Silent production selection of local adapter | **Forbidden** |
| Local purchase masquerading as real store receipt | **Forbidden** |
| Local stub plan IDs (`pro_*`) | Test/dev only — never sent to real store APIs |

### 3.3 Offline

| Rule | Freeze |
|---|---|
| Last **verified** cached entitlement | May be shown honestly as cached |
| Unknown entitlement offline | Must **not** be guessed as Premium |
| Free core | Always accessible |
| User evidence | Never deleted on entitlement loss / expiry / offline |

### 3.4 Provider-selection rule (authoritative)

```
IF compile/runtime flavor is test OR explicit DEV_SUBSCRIPTION_ADAPTER=local
  → Local / fake SubscriptionService (deterministic)
ELSE IF AppConfig has valid platform RevenueCat public SDK key
     AND purchases_flutter is linked
     AND RevenueCat initialize succeeded or is in progress
  → RevenueCatSubscriptionService (production)
ELSE
  → Store-unavailable production path:
       isEntitled = false (unless previously verified cache says entitled — honest cache phase only)
       offerings = []
       purchase disabled / store_unavailable UI
       Free core remains usable
       DO NOT fall back to LocalSubscriptionService.purchase() → setProUser(true)
```

**Critical:** Missing RC configuration must **not** fall through to Hive grant. That is the current silent defect to eliminate during implementation.

---

## 4. Entitlement and product IDs

### 4.1 Frozen production identifiers (exact)

| Kind | Exact value |
|---|---|
| Entitlement | `Brain Clean` |
| Monthly product | `brainclean_monthly` |
| Yearly product | `brainclean_yearly` |
| Lifetime product | `brainclean_lifetime` |

Case and spelling are frozen from `PremiumIdentifiers` + Premium Contract §8 + Master alignment.

### 4.2 Additive entitlement (optional)

If RevenueCat CustomerInfo also exposes entitlement id `pro`, acceptance may be **additive** (Premium if `"Brain Clean"` **OR** `"pro"` is active).  
Do **not** rename `"Brain Clean"` or strand existing purchasers.

### 4.3 Legacy local IDs (non-production)

| Stub ID | Status |
|---|---|
| `pro_monthly` | Dev/test mapping only |
| `pro_annual` | Dev/test mapping only |
| `pro_lifetime` | Dev/test mapping only |

These must never be used as App Store / Play product identifiers.

### 4.4 Lifetime / missing packages

- Lifetime appears in UI **only** when the current store offering exposes a package for `brainclean_lifetime`.  
- Missing package must **not** block purchase of other valid packages.  
- Empty current offering → `no_offering` / `store_unavailable` honesty (Premium Contract phases).

### 4.5 Identifier conflict check

Production store IDs (`brainclean_*` + entitlement `"Brain Clean"`) are consistent across Premium Contract, PremiumIdentifiers, and Master-documented IDs.  
Local `pro_*` are explicitly labeled stubs — **not** a rename of store products.  

**Verdict:** No `MONETIZATION_IDENTIFIER_CONFLICT`. Implementation must stop mapping production UI purchases to `pro_*`.

---

## 5. Configuration and secrets

### 5.1 Supply pattern (approved)

Preference order (matches `AppConfig`):

1. `--dart-define` / `String.fromEnvironment` (release-safe)  
2. Local dotenv fallback for developer machines  
3. Placeholder / missing → treated as **absent**

### 5.2 Key names (freeze)

| Platform | Define / env key |
|---|---|
| Android | `REVENUECAT_ANDROID_API_KEY` (preferred) |
| iOS | `REVENUECAT_IOS_API_KEY` (preferred) |
| Legacy single slot | `REVENUECAT_API_KEY` may be used **only** when resolved for the **current platform** and documented as transitional |

Android and iOS **require separate public SDK keys** in production.  
Public SDK keys are not secret-like Claude secrets, but must still **never** be committed as real values.

### 5.3 Hard rules

- No real key in Git  
- No key printed in logs, exceptions, analytics, or reports  
- No real key in `.env.example` (placeholders only)  
- Missing/placeholder key → honest `store_unavailable` · Free core · **no Premium grant**  
- No reuse of Claude / Supabase / AdMob credentials for RevenueCat  
- `.env` remains gitignored  
- CI/release injects defines without logging values  

### 5.4 Phase 10.1 action

This freeze **does not** collect or request real keys.

---

## 6. Initialization

| Rule | Freeze |
|---|---|
| Configure once | Single `Purchases.configure` per process |
| Widget rebuild | Must not reconfigure |
| Purchase before init | **Forbidden** — queue or show unavailable |
| App user | Follow current anonymous / non-switch architecture; account switching unsupported unless separately authorized |
| Startup failure | Free core continues; Premium shows store_unavailable / offline_unknown |
| Observability | Typed phase (`loading`, `store_unavailable`, `offeringReady`, …) |
| Restore | Remains available when store later becomes reachable |
| Logs | Redact App User IDs if product policy requires; never log SDK keys |

**Startup vs lazy:** Production may lazy-init on first Premium surface open **or** early after app start — but must remain **single-shot**, non-blocking for Free core, and must complete before purchase/restore invokes store APIs.

---

## 7. Offerings

| Rule | Freeze |
|---|---|
| Source | `Purchases.getOfferings()` current offering |
| Package selection | Map store packages to frozen `brainclean_*` product IDs |
| Price string | Store-localized only |
| Trial / intro | Show only when store package metadata confirms |
| Lifetime row | Only if present in offering |
| Partial packages | Show only valid packages |
| Empty / error | `no_offering` or `store_unavailable` · restore still visible |

---

## 8. Purchase

Exact production flow:

1. Ensure initialized  
2. Load current offering  
3. User selects package (valid product ID)  
4. Re-validate package still in offering  
5. Invoke store purchase **once**  
6. Read returned CustomerInfo  
7. Verify entitlement (`Brain Clean` and optional additive `pro`)  
8. Update typed Premium state  
9. Invalidate consumers (Reports archive gate; ad visibility **only if ads active**)  
10. **Do not** mutate Score / Profile / Plan / Session / Progress / Weekly Review / Reports source data  

Cancellation / pending / failure / CustomerInfo without entitlement → **Premium remains inactive**.

---

## 9. Restore

| Rule | Freeze |
|---|---|
| Accessibility | Always from Premium manage / locked Reports archive / explicit restore route |
| Idempotent | Yes |
| Local fake activation | **Forbidden** |
| Success | Entitlement verified from CustomerInfo |
| Nothing to restore | Honest message · Free core preserved |
| Failure | Honest error · no data deletion · source route preserved |
| Duplicate entitlement | Harmless — still single Premium truth |

---

## 10. Offline / cache

| State | Behavior |
|---|---|
| Online + entitled | Full Premium depth |
| Online + not entitled | Free core + Free archive depth |
| Offline + last verified entitled | `offline_cached_entitlement` · honest labeling |
| Offline + never verified / unknown | `offline_unknown` · **not** Premium |
| Expired (online) | Relock deeper archive / future ads only · evidence retained |

Cache must come from last **store-verified** CustomerInfo snapshot — not from Hive `isProUser` grant.

---

## 11. Legacy local-state reconciliation

### 11.1 Current defect

`HiveMetaKeys.isProUser` / `LocalSubscriptionService.purchase` can activate Premium without a store.

### 11.2 Frozen production precedence

| Priority | Source |
|---|---|
| 1 (wins) | RevenueCat verified entitlement |
| 2 | Verified offline cache of (1) |
| 3 | Never: Hive `isProUser` alone |

### 11.3 What happens to Hive `isProUser`

| Mode | Treatment |
|---|---|
| Production | **Not an entitlement truth.** May be updated as a **derived mirror** of verified RC entitlement for legacy V1 screens, or ignored by V2 Premium. Must **not** independently grant Premium. |
| Test / local adapter | May remain the local adapter’s storage |
| Migration | Non-destructive. Do **not** wipe evidence. Do **not** auto-clear historical sessions. |
| Existing real purchasers | Regain Premium only via restore / CustomerInfo — not via leftover Hive flags |

**Decision:** Hive `isProUser` becomes **legacy mirror / test-only**, never production authority.

---

## 12. Reports archive access

Unchanged from Premium + Reports contracts:

- Free: latest + previous (`depth = 2`)  
- Premium: deeper archive  
- Expiration: relocks deeper only  
- Content values never differ by entitlement  
- Store unavailable: locked deeper archive explains honestly; restore CTA remains

---

## 13. Ads source audit

| Finding | Status at HEAD |
|---|---|
| Root `google_mobile_ads` | **Not installed** |
| Root ad widgets / UMP | **Absent** |
| Nested AdMob + UMP ConsentInformation | Present under `brain_clean_mobile/` only |
| Root V2 surfaces rendering ads | **None** |
| Build Spec G2 | Assumes Free banners may exist where allowed |
| Premium Contract | “Ads removed only if architecture active”; root debt documented |
| Public privacy “no advertising SDKs” | Conflicts with nested AdMob presence |

---

## 14. Ads release policy

### 14.1 Frozen decision for the next production cut of **root V2**

**Decision A — Ads deferred for root V2 release.**

Rationale: root V2 does not render ads; inventing placements to justify Premium would violate Premium Contract § truthfulness and this board’s “never invent ads” rule.

| Implication | Freeze |
|---|---|
| Root V2 ships without ads | Yes |
| Premium must **not** claim “remove ads” | Yes |
| Revenue framing | Premium = post-proof Continuity / archive depth (and already-shipped Free-core rules) |
| Nested unused ad code | Remains inactive until a future ads contract ports a safe Free banner system into root under Build Spec G2 |
| Build Spec G2 exclusions | Still binding if/when ads are later activated |

### 14.2 Mandatory ad-free surfaces (now and later)

Onboarding · Brain Check · Profile reveal · Today · Daily Session · Weekly Review · Reports content · Premium purchase/restore · Safa · SOS/urgent · Privacy/consent

### 14.3 Decision B rejection for this release

Decision B (active Free banners) is **not** available for root V2 because no active root placement exists.

---

## 15. UMP / consent

Because ads are **deferred** for root V2:

- No ad/UMP release implementation is required for this root V2 monetization gate.  
- Nested UMP code remains reference material only.  
- Privacy consistency still requires public docs to stop claiming false SDK facts when nested AdMob exists, and to stay accurate about root V2 behavior.  
- If a later ads contract activates banners, UMP must ship **before** any personalized ad request (consent before request; non-personalized path; privacy options entry; no ads on excluded surfaces; test IDs separate).

---

## 16. Premium copy truthfulness

| Rule | Freeze |
|---|---|
| Ad-removal claims | **Forbidden** while Decision A holds |
| Plans when offerings empty | Do not promise specific prices/plans |
| Hardcoded discounts | Forbidden |
| Trial chip | Only if store confirms |
| Lifetime row | Only if store exposes package |
| Legacy “Pro” in new V2 copy | Forbidden |
| Evidence after expiry | Remains available |

Existing `v2Premium*` copy (as of Slice 9) does **not** promise ad removal — preserve that truth. Do not add ad-removal strings in Phase 10 implementation under Decision A.

---

## 17. Safa privacy disclosure

### 17.1 Minimum production disclosure (EN + AR)

Must state clearly (in-app and privacy documents):

1. Safa may send the user’s typed message to an AI-backed service over the network.  
2. Only typed text and **explicitly selected** context are sent.  
3. No automatic Brain Check / Profile / Score / Weekly Review / Reports history transfer.  
4. Safa is not medical, emergency, or crisis care.  
5. Local offline fallback remains available.  
6. User may decline and continue using the app.  
7. No raw conversation archive by default.  
8. Processing uses the approved **Supabase Edge** boundary (`safa-chat`); model runs server-side.  
9. No NVIDIA path.  
10. No direct client Claude secret.

### 17.2 Documents requiring update during **implementation** (not this freeze)

| File | Required adjustment |
|---|---|
| `docs/privacy-policy/index.html` | Confirm Safa V2 consent accuracy; align ads statements with Decision A (root has no ads) without false nested claims |
| `brain_clean_mobile/PRIVACY_POLICY.md` | Same truthfulness when that tree is still published |
| `brain_clean_mobile/PRIVACY_POLICY_AR.md` | Arabic parity |
| In-app SAF-01 privacy/consent copy | Already contracted; ensure parity with privacy docs at ship |

SAF-01 in-app consent remains mandatory before first network send (Safa Contract).

---

## 18. Routing / failure states

| Condition | Behavior |
|---|---|
| Missing RC key | Premium `store_unavailable` · Free core OK |
| Init failure | Same · restore still shown for later |
| Premium routes | Contextual only · not a tab · no app-launch paywall |
| Locked Reports archive + no store | Honest message · Restore CTA |
| Repeated automatic paywall | Forbidden |
| Purchase from SOS / Safa / Session | Forbidden |
| Feature flag OFF | V1 preserved |
| Invalid / cancelled purchase | No Premium |
| App restart | Rehydrate from verified RC / verified cache only |

---

## 19. Data safety

Premium / store operations must never write:

- Brain Check answers  
- Recovery Score internals  
- Brain Profile packs  
- Recovery Plan  
- Daily Session / reflections  
- Progress snapshots  
- Weekly Review / WeeklyArtifact source content  

They may only change: entitlement view-state, archive **visibility**, and (if ads later activate) ad visibility.

---

## 20. Accessibility

Premium store-unavailable / offline / restore / purchase phases must remain:

- 320 logical-pixel usable  
- Text scale 2.0  
- ≥48 dp targets  
- RTL / LTR  
- Announced loading / errors  
- No color-only state  

Device store sheet a11y is covered in §21.

---

## 21. Device / store verification

Before production release claiming Real Premium:

| Checklist | Required |
|---|---|
| Sandbox / license-tester purchase monthly | Pass |
| Sandbox purchase annual | Pass |
| Lifetime purchase **if** offered | Pass or N/A |
| Cancel / fail / pending honesty | Pass |
| Restore success + idempotent re-restore | Pass |
| Nothing-to-restore | Pass |
| Offline cached entitlement labeling | Pass |
| Offline unknown not granted | Pass |
| App restart entitlement hydration | Pass |
| Reports deeper archive unlock/relock | Pass |
| No Premium grant from Hive alone | Pass |
| EN / AR Premium UI | Pass |
| Real device store sheets | Pass |

---

## 22. Test vectors

Default mutation expectation: **no recovery-data mutation**.  
Default ads expectation under Decision A: **no ads rendered**.

| # | Name | Configuration | Adapter | Store state | UI | Entitlement | Archive | Ads | Mutation | Security/logs |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Missing Android RC key | Android; Android key empty | Prod path | Unconfigured | store_unavailable | false | Free depth | none | none | no key printed |
| 2 | Missing iOS RC key | iOS; iOS key empty | Prod path | Unconfigured | store_unavailable | false | Free depth | none | none | no key printed |
| 3 | Valid initialization | Valid platform key | RC | Init OK | loading→ready | from CI | Free until entitled | none | none | configure once |
| 4 | Duplicate init prevented | Second configure attempt | RC | Already init | unchanged | unchanged | unchanged | none | none | no crash |
| 5 | Initialization failure | SDK throws | RC fail | Failed | store_unavailable | false/cache | Free/cached | none | none | redacted error |
| 6 | Free core during init fail | Same | RC fail | Failed | Today usable | false | Free | none | none | n/a |
| 7 | Valid entitlement | CI has Brain Clean | RC | Entitled | Premium active | true | Deep | none | none | n/a |
| 8 | No entitlement | CI empty | RC | Not entitled | Free | false | Free | none | none | n/a |
| 9 | Expired entitlement | Was entitled | RC | Expired | Free depth | false | Free only | none | none | evidence kept |
| 10 | Cached active offline | Last verified true | RC cache | Offline | offline_cached | true (cached) | Deep labeled | none | none | honest label |
| 11 | Unknown entitlement offline | Never verified | RC | Offline | offline_unknown | false | Free | none | none | no guess |
| 12 | Monthly offering | Package monthly | RC | Offering | Monthly row + store price | — | — | none | none | n/a |
| 13 | Annual offering | Package yearly | RC | Offering | Annual row | — | — | none | none | n/a |
| 14 | Lifetime present | Package lifetime | RC | Offering | Lifetime row | — | — | none | none | n/a |
| 15 | Lifetime absent | No lifetime package | RC | Offering | No lifetime row | — | — | none | none | n/a |
| 16 | Missing current offering | null current | RC | Empty | no_offering | false | Free | none | none | n/a |
| 17 | Partial packages | Only monthly | RC | Partial | Monthly only | — | — | none | none | n/a |
| 18 | Localized price | Store locale | RC | Offering | Localized string | — | — | none | none | no hardcode $ |
| 19 | Trial confirmed | Store intro | RC | Offering | Trial label | — | — | none | none | n/a |
| 20 | Trial absent | No intro | RC | Offering | No trial claim | — | — | none | none | n/a |
| 21 | Purchase success | User buys | RC | Entitled | success | true | Deep unlock | none | none | n/a |
| 22 | Purchase cancel | User cancels | RC | Unchanged | cancelled | false | Free | none | none | n/a |
| 23 | Purchase pending | Store pending | RC | Pending | pending | false until active | Free | none | none | n/a |
| 24 | Purchase failure | Store error | RC | Error | failed | false | Free | none | none | no secret |
| 25 | CustomerInfo w/o entitlement | Success API, no ent | RC | Not entitled | no Premium | false | Free | none | none | n/a |
| 26 | Restore success | Prior purchase | RC | Entitled | restored | true | Deep | none | none | n/a |
| 27 | Restore idempotent | Restore twice | RC | Entitled | still entitled | true | Deep | none | none | n/a |
| 28 | Nothing to restore | Clean account | RC | Empty | nothing_to_restore | false | Free | none | none | n/a |
| 29 | Restore failure | Network/error | RC | Fail | restore failed | unchanged | unchanged | none | none | no wipe |
| 30 | Existing purchase preserved | Legacy Brain Clean | RC | Entitled | Premium | true | Deep | none | none | no repurchase force |
| 31 | Hive cannot grant prod Premium | isProUser true, RC false | Prod RC | Not entitled | Free | false | Free | none | none | Hive ignored |
| 32 | Test adapter in tests | DEV/test flag | Local | Sim | deterministic | per test | per test | none | none | isolated |
| 33 | Prod never silent local | Release flavor | Must be RC path | — | no Hive purchase | — | — | none | none | assert selection |
| 34 | Purchase unlocks Reports archive | After success | RC | Entitled | deeper visible | true | Deep | none | none | n/a |
| 35 | Expiry relocks deeper only | Entitlement ends | RC | Expired | Free depth | false | Free | none | none | evidence kept |
| 36 | Free evidence remains | Always | Any | Any | latest+prev | n/a | Free | none | none | n/a |
| 37 | No recovery mutation | Purchase/restore | Any | Any | n/a | n/a | n/a | none | **none** | n/a |
| 38 | Ad policy Decision A | Root V2 | Any | Any | no ad widgets | n/a | n/a | **absent** | none | n/a |
| 39 | Premium copy matches policy | Copy audit | Any | Any | no “remove ads” | n/a | n/a | absent | none | n/a |
| 40 | No ad in excluded surfaces | Nav all sacred | Any | Any | no banners | n/a | n/a | absent | none | n/a |
| 41 | UMP N/A this release | Decision A | — | — | no UMP ad gate required | — | — | absent | none | privacy docs later |
| 42 | Ads absent if deferred | Root screens | Any | Any | 0 ad SDK calls | — | — | absent | none | n/a |
| 43 | Safa disclosure EN | Privacy/update | — | — | EN text present | — | — | — | none | no secrets |
| 44 | Safa disclosure AR | Privacy/update | — | — | AR text present | — | — | — | none | no secrets |
| 45 | No raw Safa text analytics | Safa send | Any | Any | — | — | — | — | none | no message logs |
| 46 | No production keys in Git | Repo scan | — | — | — | — | — | — | none | `.env` ignored |
| 47 | `.env` ignored | git check | — | — | — | — | — | — | none | pass |
| 48 | No secret printed | RC errors | RC | Fail | user-safe | — | — | — | none | redacted |
| 49 | Feature flag OFF | Flag false | Any | Any | V1 home | V1 rules | V1 | V1 | none | V2 gated |
| 50 | Restart hydration | Kill/reopen | RC | Prior entitle | entitled | true | Deep | none | none | from verified cache/RC |
| 51 | Store unavailable UI | No key | Prod | Unconfigured | honest | false | Free | none | none | n/a |
| 52 | Reports lock + unavailable store | No key | Prod | Unconfigured | lock + restore CTA | false | Free | none | none | n/a |
| 53 | Restore from locked archive | Entitled elsewhere | RC | Restored | unlock | true | Deep | none | none | n/a |
| 54 | 320-width Premium UI | a11y | Any | Any | usable | — | — | none | none | n/a |
| 55 | Text scale 2.0 | a11y | Any | Any | usable | — | — | none | none | n/a |
| 56 | RTL / LTR | ar/en | Any | Any | mirrored | — | — | none | none | n/a |
| 57 | Real-device store sheet | Device | RC | Live sheet | OS UI | — | — | none | none | checklist |
| 58 | Sandbox purchase | Device | RC | Sandbox | success path | true | Deep | none | none | checklist |
| 59 | Sandbox restore | Device | RC | Sandbox | restore path | true | Deep | none | none | checklist |
| 60 | Release blocker reporting | Gate review | — | — | blockers listed | — | — | — | none | no secrets in report |

**Vector count:** 60

---

## 23. Release blockers

Must be cleared before claiming production monetization readiness:

1. Root production adapter = RevenueCat (not Local Hive grant)  
2. `purchases_flutter` linked in root app  
3. Platform public SDK keys injected (not in Git)  
4. Entitlement `"Brain Clean"` verified on device  
5. Products `brainclean_*` resolved from offerings (lifetime optional if absent)  
6. Purchase / cancel / pending / fail honesty  
7. Restore success / nothing / fail honesty  
8. Hive cannot grant Premium in production  
9. Premium copy does not claim ad removal under Decision A  
10. Privacy docs updated for Safa + truthful ads statement  
11. Device sandbox checklists §21 pass  
12. Full automated suite remains green  

---

## 24. Superseding policy

| Conflict | Winner |
|---|---|
| Local Hive `isProUser` vs RC entitlement | **RC verified entitlement** |
| Stub `pro_*` vs `brainclean_*` | **`brainclean_*` in production** |
| Silent Local fallback on missing RC key | **Forbidden** → store_unavailable |
| Build Spec Free banners vs root no ads | **Decision A deferred ads** for this cut |
| “Ads removed” Premium copy vs Decision A | **No ad-removal claims** |
| Nested AdMob vs root privacy “no ads” | Docs must distinguish; root ships Decision A |
| Future ads contract vs Decision A | Later contract may activate banners under G2; cannot invent ads now |
| Additive `"pro"` entitlement | Allowed; cannot replace `"Brain Clean"` |
| This contract vs Phase 10.1 scope | Freeze only; implementation is a later authorized slice |

---

## Audit appendix — contradictions and nonblocking debt

| ID | Item | Severity |
|---|---|---|
| C1 | Root always selects LocalSubscriptionService | **Blocking for production** — repaired in implementation |
| C2 | Privacy “no advertising SDKs” vs nested AdMob | **Documentation repair** at ship |
| C3 | Build Spec assumes Free banners; root has none | **Reconciled** by Decision A |
| C4 | Single `REVENUECAT_API_KEY` vs preferred platform keys | Nonblocking if transitional mapping is explicit |
| C5 | Nested RC / ads tree vs root V2 path | Nonblocking architecture debt — do not dual-live without port |
| C6 | Premium Contract optional additive `"pro"` | Compatible |
| C7 | Emotion Oasis / legacy Pro paywall | Out of this freeze; V1 retain |
| C8 | V2 feature flag default OFF | Release decision; not a monetization ID conflict |

**No identifier conflict blocks this freeze.**

---

**End of Production Monetization and Privacy Contract V1.**
