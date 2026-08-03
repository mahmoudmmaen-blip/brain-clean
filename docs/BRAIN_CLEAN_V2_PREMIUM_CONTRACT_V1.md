# Brain Clean V2 — Premium Contract V1

**Document ID:** `BRAIN_CLEAN_V2_PREMIUM_CONTRACT_V1`  
**File:** `docs/BRAIN_CLEAN_V2_PREMIUM_CONTRACT_V1.md`  
**Status:** APPROVED FOR IMPLEMENTATION GOVERNANCE — CONTRACT FREEZE  
**Slice:** 9.2A (contract only; no purchasing implementation in this slice)  
**Date:** 2026-08-03  
**Role:** Premium Governance Board  

---

## 1. Status and authority

### 1.1 Binding authorities (tracked)

| Authority | Role |
|---|---|
| `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md` | Primary V2 scope, PRE-01…PRE-03 IDs, G2/G3/G9/G13 |
| `docs/BRAIN_CLEAN_V2_REPORTS_CONTRACT_V1.md` | Free vs Premium archive depth (Reports) |
| `docs/BRAIN_CLEAN_V2_WEEKLY_REVIEW_CONTRACT_V1.md` | Weekly Review remains Free core |
| `docs/BRAIN_CLEAN_V2_RECOVERY_PLAN_CONTRACT_V1.md` | Premium must not change plan correctness |
| `docs/BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1.md` | Premium must not change Score |
| `docs/BRAIN_CLEAN_MASTER.md` | Existing RevenueCat product IDs + entitlement string |
| Existing `lib/features/pro/**` + `isProUserProvider` | Current entitlement consumer surface |
| Existing Reports archive gate | Depth already coded: Free depth = 2 |

### 1.2 Requested authorities not tracked in this workspace

The following were **requested** for Slice 9.2A and are **absent** from `docs/`:

- `docs/BRAIN_CLEAN_PREMIUM_BIBLE_V1.md`
- `docs/BRAIN_CLEAN_PREMIUM_ECONOMICS_BIBLE_V1.md`
- `docs/PREMIUM_MASTER_SPEC_V1.md`
- `docs/BRAIN_CLEAN_GRADUATION_SYSTEM_V1.md`
- `docs/BRAIN_CLEAN_PRODUCT_LANGUAGE_BIBLE_V1.md`

**Policy:** Do not invent missing Bible economics, pricing dollars, or Safa depth detail. Where absent, freeze only what Build Spec, Reports Contract, Master, and this document decide. Gaps are non-blocking debt unless marked **BLOCKING**.

### 1.3 Precedence

1. This Premium Contract freezes **Premium V1 behavior** for V2.  
2. Reports Contract supersedes Build Spec wording when archive depth conflicted (“first Free” vs “latest + previous”).  
3. Build Spec PRE screen IDs remain authoritative for screen naming.  
4. Master RevenueCat entitlement / product IDs remain authoritative for **existing purchases**.  
5. No silent redesign of ads, RevenueCat project, package identity, or V1 purchase history.

### 1.4 Implementation posture for Slice 9.2A

This document is **decision and contract freeze only**. It does **not** authorize:

- New purchasing code  
- RevenueCat wiring changes  
- Ads redesign  
- Paywall production rewrite  
- Safa implementation  
- Mutation of Score, Plan, Check, Profile, Today, Session, Progress, Weekly Review, or Reports derivation logic  

---

## 2. Purpose

Brain Clean Premium is **post-proof stewardship**.

Premium exists to fund and deepen recovery continuity after the user has already received visible Free value. Premium never buys the right to recover.

**Required emotional outcome:** Appreciation.

**Forbidden framing:** Unlocking recovery, hostage access, fear of losing progress, artificial urgency, medical superiority, or shame.

---

## 3. Four capitals

Premium V1 may deepen only these four capitals:

| Capital | Meaning |
|---|---|
| **Continuity** | Long-horizon evidence archive and durable access depth after Free proof is already visible |
| **Interpretation** | Additional **deterministic**, approved context layers only — never AI medical claims, never Score mutation |
| **Fit** | Future approved adaptation depth — never silent Plan mutation, never Premium-only core plan correctness |
| **Support** | Future approved Safa depth under a **separate Safa contract** — never Premium-only crisis care |

Premium does **not**:

- Make recovery possible  
- Unlock the minimum path or standard daily core path  
- Unlock current Progress, current Weekly Review, latest Weekly Summary  
- Unlock latest Profile / Recovery Score  
- Remove access to user-owned historical data already earned  
- Increase scientific accuracy  
- Change Recovery Score, Recovery Plan logic, or eligibility  

---

## 4. Free core

The permanent Free core remains complete and useful without purchase:

| Area | Free retention |
|---|---|
| Onboarding | Full |
| Brain Check | Full |
| Brain Profile (latest) | Full |
| Current Recovery Plan | Full |
| Today / HOM-01 | Full |
| Minimum path + standard core path | Full |
| Daily Session completion (SES-01…04) | Full — Session never gated (Build Spec G9) |
| Current Progress (PRG-01 four answers) | Full (G3) |
| Weekly Review (WRV) | Full |
| Current Weekly Summary / latest WeeklyArtifact | Full |
| Previous one WeeklyArtifact | Full (Reports §9.2) |
| Latest valid measurement + latest-vs-previous comparison when compatible | Full (Reports §10.5) |
| Latest Reports Overview (RPT-01) | Full |
| SOS / urgent support flows | Full — **no entitlement check inside SOS** |
| Settings / Privacy | Full |
| Restore purchases | Full |
| Graduation / Maintenance entry (MOD-*) | Full where already approved |
| User-owned completed records | Forever retained regardless of entitlement |

---

## 5. Premium benefits

### 5.1 Supported V1 benefits (implementation-ready)

**Continuity (supported now by Reports Contract + archive gate):**

- Complete WeeklyArtifact archive beyond Free depth (index ≥ 2)  
- Extended measurement history beyond Free depth  
- Long-horizon evidence archive / long-horizon summaries where Reports surfaces already define them  

**Interpretation (bounded):**

- Additional **deterministic** context layers **only** where a later approved contract names them  
- Never AI medical interpretation  
- Never altered Recovery Score or artifact wording truth  

**Fit (future-approved only):**

- Adaptation depth only under a separate adaptation contract  
- Never silent Plan mutation  
- Never Premium-only “more correct” core Plan  

**Support (future Slice 9.3+ / Safa contract only):**

- Deeper contextual Safa continuity under a separate Safa contract  
- Repair support / continuity after difficult periods — without dependency framing  

### 5.2 Explicitly out of Premium V1 benefit invention

Do not add Premium benefits that are not supported by Build Spec, Reports Contract, or a later frozen contract. Missing Premium Bible items remain deferred.

---

## 6. Post-proof offer rule

Premium may be offered only after proof and only through approved entry points.

### 6.1 Allowed triggers

1. After first completed WeeklyArtifact (Soft Appreciation; rate-limited)  
2. After user opens deeper locked Reports history (archive boundary → PRE-01)  
3. After user explicitly opens Premium from Profile / Settings (PRE-03 manage path or explicit entry)  
4. After an approved Safa depth boundary **in a later Safa slice/contract**  
5. After the user has already received visible Free value  

### 6.2 Forbidden triggers

- During onboarding  
- Before Brain Check completion  
- Before Profile reveal  
- Before first Today action  
- During an active Daily Session  
- During Weekly Review questions  
- During SOS  
- Immediately after a setback  
- On cold app launch as an interrupt  
- Through countdown urgency  
- Through repeated interruption  

### 6.3 Frequency (from Build Spec PRE-01)

- Soft auto offer: **≤ 1 auto presentation per week**  
- After dismiss: **14-day cooldown** before another auto offer  
- Banned windows always enforced (Session, Check, Onboarding, SOS, Weekly Review questions)  
- “Not now” must be visually and interactionally equal in dignity to Subscribe  

### 6.4 Emotional rule

Premium must feel like **appreciation after proof**, never extraction before value.

---

## 7. Screen IDs

Build Spec already freezes PRE screen identity. This contract **does not rename** those IDs.

| ID | Name | Purpose |
|---|---|---|
| **PRE-01** | Appreciation sheet | Post-proof Premium overview + purchase intent entry |
| **PRE-02** | Success | Confirm Premium active after purchase / restore entitlement |
| **PRE-03** | Manage | Restore, status, expired/ Free status, store manage / resubscribe |

> Mission sketch PRE-01 Overview / PRE-02 Plan Selection / PRE-03 Restore Status is **absorbed** into the Build Spec IDs above (overview+offerings live on PRE-01; restore/status on PRE-03; success on PRE-02). No duplicate screen system.

### 7.1 PRE-01 — Appreciation sheet

Must include:

- Four-capital value explanation (Continuity · Interpretation · Fit · Support)  
- Free core reassurance (“current path remains yours”)  
- Current proof remains yours  
- Honest locked-archive explanation when entered from Reports gate  
- Store-sourced offering rows (title, billing period, localized price)  
- One primary CTA (Subscribe / Continue with Premium)  
- Secondary: Not now + Restore  
- Terms / Privacy links to existing approved destinations  
- **No** fake urgency, countdown, or scarcity  

Offline: cannot complete purchase → honest unavailable + dismiss.  
Empty offerings: honest unavailable + Not now / Restore.

### 7.2 PRE-02 — Success

Must include:

- Confirmation that Premium is active  
- Ads-removed confirmation **only if** entitlement actually controls ads in the active architecture  
- One primary return action to source context (or Today / Settings)  
- **No** upsell chain  

### 7.3 PRE-03 — Manage / Restore / Status

Must surface:

- Restore  
- Existing subscriber status  
- Expired status  
- Offline cached entitlement honesty  
- Purchase pending / failed / cancelled  
- Store unavailable  
- One safe next action per state  
- Easy cancel / manage via store intent  
- Free-core reassurance on expiration path  
- Resubscribe → PRE-01 only when post-proof eligible  

Legacy V1 surface `'/pro-paywall'` (`AppRoutes.proPaywall`) may remain until V2 Premium routes ship; user-facing V2 copy must say **Premium**, not “Pro”.

---

## 8. Entitlement

### 8.1 Canonical store entitlement (existing purchases)

From `docs/BRAIN_CLEAN_MASTER.md` RevenueCat block (do **not** invent a new id):

| Field | Exact value |
|---|---|
| Entitlement identifier | `"Brain Clean"` |
| Documented products | `brainclean_monthly`, `brainclean_yearly`, `brainclean_lifetime` |
| Offering (when RC tree is used) | store `default` offering |

**Rule (Build Spec G9):** UI name is **Premium**; entitlement id may stay legacy `"Brain Clean"`.

### 8.2 Current V2 workspace consumer

In this workspace root `lib/`:

| Surface | Behavior today |
|---|---|
| Provider | `isProUserProvider` |
| Preference flag | Hive / app preferences `isProUser` |
| Local stub plans | `pro_monthly`, `pro_annual`, `pro_lifetime` with **hardcoded** USD strings |
| `RevenueCatSubscriptionService` | Publish-time stub — throws if used unwired |
| Reports gate | `ReportsArchiveGate` + `isProUserProvider` |

**Freeze for integration:**

1. Existing valid store entitlement `"Brain Clean"` **remains valid** and must continue to grant Premium after RC wiring.  
2. Do **not** introduce a second simultaneous entitlement truth that can deny an already-paid subscriber.  
3. If a future id `"pro"` is accepted beside `"Brain Clean"`, acceptance must be additive (already entitled if **either** is active). Do not rename and strand purchasers.  
4. Integration must replace hardcoded stub prices with store offerings before any production purchase CTA is exposed on V2 Premium screens.  

### 8.3 Entitlement behavioral rules

- Restore is **idempotent**  
- Purchase acknowledgement follows existing RevenueCat / store acknowledgement pattern when wired  
- No duplicate entitlement state machines racing each other  
- Offline cached entitlement must be labeled honestly (`offline_cached_entitlement` vs `offline_unknown`)  
- Expired entitlement does **not** delete data  
- Expired user keeps Free core + user-owned evidence  
- Premium gates **only** deeper archive / approved depth  
- Subscription state **never** alters Score, Plan, Review answers, Session completion, or eligibility  
- **No** entitlement check inside SOS  
- **No** entitlement check blocking current daily core  

---

## 9. Purchase states

Exact Premium V1 states:

| State | Meaning |
|---|---|
| `loading` | Resolving offerings / entitlement |
| `offering_ready` | Valid store offerings available |
| `no_offering` | No purchasable packages |
| `purchasing` | Purchase in flight |
| `purchased` | Purchase acknowledged; entitlement active |
| `already_entitled` | User already Premium |
| `restoring` | Restore in flight |
| `restored` | Restore found active entitlement |
| `nothing_to_restore` | Restore completed; no entitlement |
| `cancelled` | User cancelled store sheet |
| `failed` | Purchase/restore error |
| `pending` | Store pending / deferred |
| `offline_cached_entitlement` | Offline; last known entitled = true |
| `offline_unknown` | Offline; entitlement unknown |
| `store_unavailable` | Billing unavailable |

Every state requires:

- Honest message  
- No blame  
- No duplicated purchase pressure  
- Exactly one safe primary next action  
- Restore available where appropriate  

---

## 10. Restore

| Rule | Contract |
|---|---|
| Availability | Always reachable from PRE-01 secondary and PRE-03 primary |
| Idempotence | Repeated restore must not create duplicate local side effects |
| Success | Promote to entitled → PRE-02 or status refresh → return source |
| Nothing to restore | Calm message; Free core remains; return source |
| Failure | Calm retry / Not now; no guilt |
| Offline | Prefer cached entitlement honesty; do not fake restore success |
| Existing subscribers | Must regain Premium without repurchase when store confirms entitlement |
| Local stub today | `LocalSubscriptionService.restorePurchases()` invalidates preferences only — **must be replaced by real RC restore** before production Premium ship (G13) |

---

## 11. Expiration

Healthy expiration:

- No guilt  
- No loss-threat copy  
- No “your recovery will stop”  
- No deletion of history  
- No locking of current proof (latest + previous Free depth remains)  
- No forced win-back loops  
- No downgrade shame  

Expired users retain:

- Free core  
- Latest proof + previous artifact Free depth  
- Current Plan  
- Completed records  
- Restore access  
- Settings / Privacy  

Expiration may restore **only** contract-approved Free ad behavior (see §14). It must not rewrite Score/Plan/session history.

---

## 12. Graduation

Graduation / Maintenance (MOD-*) remains a **valid success outcome**.

- Premium is optional stewardship, not dependence  
- Healthy churn is allowed  
- Graduation must never be framed as losing Premium value as a threat  
- Full Graduation System Bible is **missing** — until added, use: Free core + no guilt + no hostage retention + easy cancel (Build Spec PRE-03)

---

## 13. Reports boundary

Frozen exactly from Reports Contract §9 / §10 / §14 and `ReportsArchiveGate`:

### 13.1 Free

- RPT-01 Reports Overview  
- Latest WeeklyArtifact (index 0)  
- Previous one WeeklyArtifact (index 1)  
- Latest measurement + one prior comparable pair when compatible  
- Content values identical to Premium when visible  

### 13.2 Premium

- Older WeeklyArtifact archive (index ≥ 2)  
- Extended measurement history  
- Long-horizon comparisons / filters as already contracted  

### 13.3 Requirements

- Content values never differ by entitlement  
- Premium changes **depth/access only**  
- Newly created evidence is never immediately hidden  
- No locked placeholder inventing fake insights  
- Locked rows show honest archive boundary  
- Restore / Premium appreciation available from locked archive surface → PRE-01  

Code constant (current): `ReportsArchiveGate.freeArtifactDepth = 2`, `freeMeasurementDepth = 2`.

---

## 14. Ads boundary

| Rule | Contract |
|---|---|
| Valid Premium entitlement | Removes ads **according to existing ad architecture** when that architecture is active |
| Free ad rules | Remain unchanged by this contract |
| Forbidden ad placements | Today core path, Daily Session, Weekly Review, Reports proof content, SOS, onboarding, Brain Check, Profile reveal, paywall / PRE-* |
| This freeze | Adds **no** new ad unit |
| Claims | Do not claim “ads removed” unless entitlement actually controls the active ad path |
| Expiration | Restores only contract-approved Free ad behavior |

Build Spec G2 already blocks ads on Check, Session, Safa, Weekly Review, Monthly Report, Restart, Onboarding, MOD-*.

**Nonblocking debt:** Root V2 `lib/` does not currently host the mobile footer-ad stack; preserve behavior when present, do not invent a second ads system.

---

## 15. Safa boundary

Deferred to **Slice 9.3 / separate Safa contract**:

- Safa core safety/support remains available where already approved  
- Premium may add continuity or deeper contextual support **only** under that later contract  
- **No** Premium-only crisis support  
- **No** Premium-only safety response  
- **No** automatic raw data transfer  
- **No** AI cage  
- **No** unlimited dependency framing  
- **No** Safa implementation in Slice 9.2  

Build Spec SAF-01 still cites Premium Bible for depth — Bible missing → Safa Premium depth remains **unfrozen** beyond the bans above.

---

## 16. Routing

Premium is **not** a shell tab. Four-tab shell remains: Today · Plan · Progress · Profile.

### 16.1 Contextual V2 routes (freeze)

| Route | Screen | Notes |
|---|---|---|
| `/v2/premium` | PRE-01 | Deep link / explicit entry; if not eligible, recover safely (Today / source) |
| `/v2/premium/success` | PRE-02 | Optional alias; success may also be modal within stack |
| `/v2/premium/manage` | PRE-03 | Settings entry |
| `/v2/premium/restore` | PRE-03 restore intent | May land on PRE-03 with restore autofocus |

Aliases / sources:

- Reports locked archive → `/v2/premium` (PRE-01) with `proofContext` / source query  
- Profile / Settings → PRE-03 or PRE-01 (explicit)  
- Premium success / cancel / restore success → **return to source** when known  

### 16.2 Routing rules

- No automatic launch route  
- No onboarding interruption  
- No SOS interruption  
- Deep links gated safely; feature flag OFF preserves V1  
- Back-stack preserves source context  
- No route mutates recovery data  
- Legacy `'/pro-paywall'` remains V1 compatibility until replaced; must not be the V2 default appreciation path  

Build Spec deep-link note: `premium` → PRE-01 only if eligible else HOM-01.

---

## 17. Pricing / store data

| Rule | Contract |
|---|---|
| Prices | From RevenueCat / store products only |
| Currency / tax | Store / country handles display |
| Billing period | Store metadata |
| Trial / intro | Shown **only** if store offering confirms |
| Purchase CTA | Uses localized store price string |
| Missing offerings | Honest `no_offering` / `store_unavailable` |
| Discounts | No guessed discounts |
| “Best value” | Forbidden unless objectively defined by approved copy + store periods |
| Hardcoded stub prices | Forbidden on production V2 Premium surfaces (`$4.99` / `$29.99` / `$79.99` in local stub are **dev-only debt**) |

Canonical product ids to preserve for existing purchasers (Master):

- `brainclean_monthly`  
- `brainclean_yearly`  
- `brainclean_lifetime`  

Local stub ids `pro_monthly` / `pro_annual` / `pro_lifetime` are **not** store SKUs and must not be presented as production product identifiers.

---

## 18. Copy / emotional contract

### 18.1 Canonical term

**Premium**

### 18.2 Reject on new V2 user-visible copy

- Pro (new strings)  
- Unlock recovery  
- Fix your brain  
- Limited-time recovery  
- Don’t lose progress  
- Upgrade to keep healing  
- Exclusive cure  
- Advanced diagnosis  

Legacy internal identifiers (`isProUserProvider`, route `proPaywall`, entitlement `"Brain Clean"`) may remain in code; **userable UI** on V2 Premium surfaces must say Premium.

### 18.3 Required principles

- Pay after proof  
- Reassure Free core  
- Explain what continues  
- Explain what deepens  
- No fear / urgency / manipulation / fake scarcity / shame / medical superiority  

Required emotional outcome: **Appreciation**.

---

## 19. Privacy / analytics

| Rule | Contract |
|---|---|
| Purchase analytics | No raw recovery data |
| Forbidden props | Brain Check answers, Profile domains, Recovery Score internals, Weekly Review responses, private notes, Safa conversations |
| Allowed | Screen id, proofContext enum, purchase state enum, free/premium access class — when an approved sink exists |
| Network | No new network beyond RevenueCat/store behavior already present for purchases |
| Terms / Privacy | Existing approved destinations only |
| Build Spec events (when sink approved) | `premium_offer_show`, `premium_subscribe_tap`, `premium_dismiss`, `premium_purchase_ok|fail`, `premium_success_view`, `premium_manage_open`, `premium_cancel_intent`, `entitlement_change` |

---

## 20. Accessibility

Freeze for PRE-01…PRE-03:

- 320 logical-pixel width without truncation of primary CTA  
- Text scale 2.0 without blocking purchase/restore  
- Short-height scrolling  
- ≥48 logical-pixel targets  
- Price + billing period announced together  
- Purchase / restore / entitlement states announced  
- No color-only Premium state  
- Logical focus order  
- RTL / LTR  
- Loading / error semantics  
- Terms / Privacy accessible  
- No countdown animation  
- Reduced-motion safe  

---

## 21. Test vectors

Implementation-ready vectors (minimum set). Mutation expectation default: **no Score/Plan/Session/Review data mutation** unless noted.

| # | Name | Preconditions | Entry | Expected UI | Entitlement | Data access | Route | Mutation |
|---|---|---|---|---|---|---|---|---|
| 1 | Free explicit open | Free; post-proof eligible | Profile/Settings → Premium | PRE-01 overview | free | Free depth only | `/v2/premium` | none |
| 2 | After WeeklyArtifact | First artifact just completed; cooldown clear | Soft Appreciation | PRE-01 with proof echo | free | unchanged | PRE-01 overlay/route | none |
| 3 | Not during onboarding | Onboarding active | any premium trigger | blocked | free | n/a | stay onboarding | none |
| 4 | Not before proof | No artifact; no explicit intent | auto offer | not shown | free | n/a | none | none |
| 5 | Not during session | SES active | auto offer | blocked | free | n/a | stay session | none |
| 6 | Not during SOS | SOS open | auto offer | blocked | free | n/a | stay SOS | none |
| 7 | Valid offering | Store returns packages | PRE-01 | `offering_ready` | free | n/a | PRE-01 | none |
| 8 | Missing offering | Empty offerings | PRE-01 | `no_offering` + Not now | free | n/a | dismissable | none |
| 9 | Monthly product | monthly package present | PRE-01 | monthly title+period+price | free | n/a | — | none |
| 10 | Annual product | annual package present | PRE-01 | annual title+period+price | free | n/a | — | none |
| 11 | Localized price | non-USD store locale | PRE-01 | store price string | free | n/a | — | none |
| 12 | Trial present | store marks trial | PRE-01 | trial copy shown | free | n/a | — | none |
| 13 | No trial | store has no trial | PRE-01 | no trial copy | free | n/a | — | none |
| 14 | Purchase success | offering ready | Subscribe | PRE-02 | entitled | Premium depth | return source | entitlement only |
| 15 | Purchase cancel | user cancels sheet | Subscribe | `cancelled`; calm | free | Free depth | stay/source | none |
| 16 | Purchase failure | store error | Subscribe | `failed`; retry | free | Free depth | stay | none |
| 17 | Purchase pending | deferred | Subscribe | `pending` | pending | Free until active | stay | none until active |
| 18 | Already entitled | Premium active | PRE-01 | `already_entitled` → manage/success | entitled | Premium depth | PRE-02/03 | none |
| 19 | Restore success | prior purchase exists | Restore | `restored` | entitled | Premium depth | PRE-02/source | entitlement sync |
| 20 | Nothing to restore | no prior | Restore | `nothing_to_restore` | free | Free depth | stay | none |
| 21 | Restore failure | store error | Restore | `failed` calm | previous | previous | stay | none |
| 22 | Offline cached entitled | offline; cache true | open app/PRE-03 | `offline_cached_entitlement` | entitled(cache) | Premium depth | — | none |
| 23 | Offline unknown | offline; no cache | PRE-01 purchase | `offline_unknown`; no purchase | unknown | Free depth | dismiss | none |
| 24 | Store unavailable | billing down | PRE-01 | `store_unavailable` | free/unknown | Free depth | dismiss | none |
| 25 | Expired entitlement | was Premium; expired | PRE-03 | expired status; no guilt | free | Free depth | settings | none |
| 26 | Expired retains data | expired | reopen Reports/Progress | history present | free | Free depth + owned data | — | none deleted |
| 27 | Expired retains Free core | expired | Today/Session | fully usable | free | core Free | — | none |
| 28 | Latest artifact Free | ≥1 artifact; Free | RPT-02 latest | full content | free | index 0 | artifact | none |
| 29 | Previous artifact Free | ≥2 artifacts; Free | RPT-02 previous | full content | free | index 1 | artifact | none |
| 30 | Older archive Premium | ≥3 artifacts; Free | open index ≥2 | locked boundary → PRE-01 | free | blocked ≥2 | premium | none |
| 31 | Progress Free | any | PRG-01 | four answers Free | free | full PRG | progress | none |
| 32 | Weekly Review Free | eligible | WRV | questions Free | free | full WRV | weekly-review | none |
| 33 | Profile/Score Free | has profile | PRF | latest Score Free | free | full latest | profile | none |
| 34 | Sub ≠ Score | purchase/expire | Score surfaces | Score unchanged | any | identical values | — | none on Score |
| 35 | Sub ≠ Plan | purchase/expire | Plan | Plan hash/content unchanged | any | identical | — | none on Plan |
| 36 | Sub ≠ completion | purchase mid-week | Session completion | marks unchanged | any | identical | — | none |
| 37 | Ads removed only when entitled | ads architecture present | titled surfaces | no footer ads iff entitled | entitled | — | — | ads visibility only |
| 38 | No ad in paywall | Free | PRE-01 | no ad widgets | free | — | premium | none |
| 39 | Arabic | ar locale | PRE-01 | Arabic Premium labels | any | — | — | none |
| 40 | English | en locale | PRE-01 | English Premium labels | any | — | — | none |
| 41 | RTL | ar | PRE-* | RTL order correct | any | — | — | none |
| 42 | LTR | en | PRE-* | LTR order correct | any | — | — | none |
| 43 | 320 width | 320 logical width | PRE-01 | no overflow CTA | free | — | — | none |
| 44 | Text scale 2.0 | textScaler 2 | PRE-01/03 | scrollable; usable | free | — | — | none |
| 45 | Restore idempotent | entitled | Restore ×2 | still entitled once | entitled | Premium | — | no dup writes |
| 46 | No hardcoded price | wired RC | PRE-01 | price = store string | free | — | — | none |
| 47 | No fear copy | any | PRE-* copy audit | no forbidden fear strings | any | — | — | none |
| 48 | No “Pro” in new V2 copy | V2 Premium surfaces | UI strings | Premium only | any | — | — | none |
| 49 | Flag OFF preserves V1 | V2 shell flag off | `/v2/premium` | V1 safe path / no V2 shell break | previous | previous | V1 | none |
| 50 | Existing purchases preserved | active `"Brain Clean"` | cold start + restore | remains entitled | entitled | Premium depth | — | none lost |

---

## 22. Prohibited patterns

- Mid-Session paywall  
- Onboarding or Check hostage paywall  
- Paywall before first proof (except explicit Settings entry)  
- Countdown urgency / fake scarcity  
- Fear-of-loss retention  
- Deleting or locking latest / previous Free proof on expire  
- Premium-altered Score, Plan, Review, or Session completion  
- Premium-only SOS / crisis  
- Hardcoded production prices  
- New user-visible “Pro” branding on V2 Premium surfaces  
- Silent Plan mutation for Premium “fit”  
- Ads inside proof / Session / paywall  
- Inventing Monthly Report Premium chapter claims while Monthly remains deferred in Reports Contract  

---

## 23. Future Premium evolution

Allowed only via new frozen contracts / slices:

- Safa Premium depth (Slice 9.3+)  
- Additional deterministic interpretation layers  
- Approved Fit / adaptation depth  
- Export of long-horizon archives  
- Economics Bible pricing strategy (when tracked)

Not allowed without new authority:

- Replacing Free core with Premium  
- Medical claims  
- AI diagnosis upsell  

---

## 24. Superseding policy

| Conflict | Winner |
|---|---|
| Archive depth “first Free” vs “latest + previous” | **Reports Contract** (+ this Premium Contract) |
| PRE screen rename proposals vs Build Spec | **Build Spec PRE-01…PRE-03** |
| UI “Pro” vs “Premium” | **Premium** (user-visible V2) |
| Entitlement rename vs existing purchasers | **Preserve `"Brain Clean"`** (additive acceptance only) |
| Hardcoded stub prices vs store prices | **Store prices** for production |
| Missing Premium / Economics / Graduation / Language Bibles | This contract freezes **minimum V1**; Bibles may deepen but must not shrink Free core or reintroduce prohibited patterns |
| This contract vs later Safa contract | Safa contract owns Safa depth; cannot violate §15 bans |

---

## Audit appendix — contradictions and debt

| ID | Finding | Severity |
|---|---|---|
| D1 | Premium / Economics / Master Premium / Graduation / Language Bibles **missing** | Nonblocking debt |
| D2 | Live/legacy UI strings still say **Pro**; Build Spec + this contract require **Premium** on V2 surfaces | Nonblocking (fix at integration) |
| D3 | Root `LocalSubscriptionService` hardcodes USD prices and stub plan ids | Nonblocking until production Premium ship (**must clear**) |
| D4 | Root `RevenueCatSubscriptionService` unwired stub | Expected for 9.2A; blocking for production purchase |
| D5 | Legacy route `/pro-paywall` ≠ PRE-01 Appreciation model | Nonblocking; replace/redirect in 9.2B |
| D6 | Safa Premium depth cites absent Premium Bible | Nonblocking; deferred to Safa contract |
| D7 | Root ads stack may be absent while mobile tree has Pro ad gating | Nonblocking; preserve when present |
| D8 | Two historical code trees mentioned in Master (`brain_clean_mobile/` vs root) | Out of Slice 9.2A scope; do not merge trees in this freeze |

**No Build Spec contradiction blocks this freeze:** PRE IDs, G9 post-proof rule, Session never gated, Free core, and Reports depth are reconcilable.

---

**End of Premium Contract V1.**
