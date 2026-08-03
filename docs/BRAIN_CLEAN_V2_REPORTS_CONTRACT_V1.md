# Brain Clean V2 — Reports Contract V1

**Document ID:** `BRAIN_CLEAN_V2_REPORTS_CONTRACT_V1`  
**File:** `docs/BRAIN_CLEAN_V2_REPORTS_CONTRACT_V1.md`  
**Status:** ENGINEERING CONTRACT — BINDING  
**Date:** 2026-08-03  
**Role:** Reports Governance Board  
**Frozen against HEAD:** `7ba6652fcbed79b138e893894dcd4025bb15ffc2`  
**Branch:** `v2/product-rebuild`

**Rule:** Implementation of Reports V1 (Slice 8.2) may begin only after this document.  
Nothing may invent report types, archive depth, comparison language, Free/Premium history gates, export, or Monthly chapters beyond this freeze.

**Precedence:**

1. This file binds Reports V1 purpose, screen IDs, evidence sources, schemas, archive/premium depth, comparison, privacy, routing, localization, accessibility, cache, and test vectors.  
2. `BRAIN_CLEAN_V2_BUILD_SPEC.md` remains binding for shell-level navigation and ad/privacy globals (G2–G13).  
3. Where Build Spec under-specifies Reports (overview hub, measurement history, archive depth numbers, Free depth), **this contract fills the gap**.  
4. Where Build Spec assigns different meanings to `RPT-01` / `RPT-02` or requires Monthly Report / share-export without Premium Bible detail, **this contract supersedes for Reports V1 catalog** and defers Monthly / export — Build Spec catalog should catch up later (nonblocking debt).  
5. `BRAIN_CLEAN_V2_WEEKLY_REVIEW_CONTRACT_V1.md` remains binding for `WeeklyArtifact` immutability and WRV surfaces.  
6. `BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1.md` remains binding for score math, history immutability, and longitudinal comparison math (§15–§16). Reports **must not** recalculate Recovery Score.  
7. `BRAIN_CLEAN_V2_RECOVERY_PLAN_CONTRACT_V1.md` remains binding: **no automatic plan adaptation**; Reports must never mutate Plan.  
8. Existing Progress Foundation / PRG-01 remain authoritative for current Progress proof; Reports must not replace or rewrite Progress.

**Language lock:** Canonical terms in §18. No Product Language Bible was tracked as a separate authority at freeze time.

---

## 1. Status and authority

This document is the **official Reports Contract V1**.

It freezes decisions that blocked Slice 8.2:

- Reports product purpose and non-answers  
- Official screen IDs `RPT-01`, `RPT-02`, `RPT-03`  
- Allowed and forbidden evidence sources  
- V1 report types (and deferred Monthly / export / share)  
- `ReportsOverview` derived schema  
- Longitudinal evidence-depth labels  
- WeeklyArtifact archive depth (Free vs Premium)  
- Recovery measurement history and within-user comparison  
- Domain-history policy  
- Empty/error states  
- Ads / Safa / AI boundary  
- Privacy  
- Gated routing  
- Localization and accessibility  
- Persistence / optional cache  
- Implementation-ready test vectors  

**Out of scope for this freeze (and for Reports V1 implementation):**

- Production Reports Dart UI / repositories beyond following this contract later  
- Modifying Progress, Weekly Review, DailySession, Recovery Score, Brain Profile, Recovery Plan  
- Plan adaptation  
- Premium purchasing flows (PRE-*)  
- Safa or AI interpretation  
- Replacing the production navigation shell  
- Ads, RevenueCat, Supabase, privacy policy text, signing, package identity, startup routing, V1 data  
- Monthly Report chapters (Build Spec old `RPT-02`)  
- PDF / doctor-facing / social export  

### 1.1 Non-authority

The following must **not** be treated as approved V2 Reports behavior:

- Legacy V1 routes/screens under `lib/features/reports/` and `lib/core/services/weekly_report_service.dart`  
- `brain_clean_mobile` weekly_report packages  
- V1 dashboard charts, BCI / BC_score analytics, or peer-style diagnostics  
- Absent “Premium Bible,” “Reports Master Spec,” or “Language Bible” files not tracked in this workspace  

---

## 2. Purpose

Brain Clean Reports provide **honest longitudinal proof** from completed local activity and completed weekly evidence.

Reports answer:

1. What evidence has accumulated?  
2. What patterns have repeated?  
3. How has the user’s own measured baseline changed, when valid rechecks exist?  
4. What remains uncertain?  
5. What was recorded during each completed week?

Reports do **not** answer:

- Whether the user has a medical condition  
- Whether the brain is healed  
- Why a change happened  
- Whether one practice caused improvement  
- Whether the user is better than other people  
- What treatment they need  

**Proof pipeline (read-only):**

```text
DailySession history
    ↓
ProgressSnapshot history
    ↓
WeeklyArtifact history
    ↓
Valid Brain Profile / Recovery Score snapshots
    ↓
Read-only Reports
```

---

## 3. Product boundary

Reports **are**:

- Read-only derived views over local completed evidence  
- Calm, explainable, non-medical  
- Offline-readable from local data  
- Honest about missing, limited, or incompatible history  
- Useful after Weekly Review and Profile rechecks exist  

Reports **must not**:

- Recalculate Recovery Score  
- Modify Recovery Plan  
- Generate medical conclusions or diagnoses  
- Use AI interpretation  
- Fabricate trends or invent missing history  
- Compare the user with other users  
- Become a productivity analytics warehouse  
- Hide newly created **current** proof behind Premium  
- Claim higher scientific accuracy for Premium  

---

## 4. Screen IDs

### 4.1 Official V1 catalog (this contract)

| ID | Name | Purpose |
|---|---|---|
| `RPT-01` | Reports Overview | Evidence orientation; depth; recent artifacts; session summary; measurement status; one primary CTA |
| `RPT-02` | Weekly Artifact Detail | One immutable `WeeklyArtifact` (user-facing summary fields only) |
| `RPT-03` | Recovery Measurement History | Valid completed ProfilePack / Recovery Score snapshots; within-user comparison when allowed |

Do **not** add further Reports screens in V1.

### 4.2 Build Spec remapping (authoritative for V1)

| Build Spec (pre-freeze) | V1 contract decision |
|---|---|
| `RPT-01` Weekly Artifact detail | Purpose preserved as **`RPT-02`**; Back may return via `RPT-01` hub (also `PRG-01` recovery) |
| `RPT-02` Monthly Report | **Deferred** — not implemented in Reports V1; requires a future Monthly Report Contract + Premium Bible |
| (missing) Overview hub | Frozen as **`RPT-01`** |
| (missing) Measurement history | Frozen as **`RPT-03`** |
| Share / export outputs | **Deferred** — future export contract only |
| Soft archive gate | Preserved as Free depth rules in §9 / §14 |

**Catalog debt (nonblocking):** Future Build Spec edit should rename IDs to match this contract and park Monthly Report under a new ID (e.g. `RPT-04`) when that product is approved.

### 4.3 Screen content freeze

#### RPT-01 — Reports Overview

Must show:

- Evidence orientation (what Reports are / are not)  
- Current `evidenceDepth` (§8) with plain explanation  
- Recent WeeklyArtifact list (depth-gated; newest first)  
- Completed-session summary (counts; path mix hint if available; rhythm fields from latest ProgressSnapshot when present)  
- Measurement-history status (none / baseline only / comparable available)  
- **One** primary CTA (deterministic priority): open latest artifact if any → else open measurement history if ≥1 valid pack → else return/continue to PRG-01 or Today depending on empty proof  

Must not show:

- Internal IDs / hashes  
- Raw reflections or Brain Check answers  
- Monthly chapters  
- Peer comparisons  
- Causal “because you practiced X” claims  

#### RPT-02 — Weekly Artifact Detail

Must show (from `WeeklyArtifact.summary` / public fields):

- One immutable artifact  
- Period label (localized from `periodStartDayKey`–`periodEndDayKey` / `periodId`)  
- Completed days / session counts  
- Path mix (`pathMixLabel`)  
- Rhythm (`rhythmLabel`)  
- Main obstacle (localized from structured `obstacleResponse`)  
- Support pattern (localized from structured `supportResponses`)  
- Evidence qualifier (`confidenceQualifier` / `evidenceDepth`)  
- Plan-unchanged statement (`planUnchangedNotice`)  

Must **hide** from users:

- Source references (`sourceProgressSnapshotId`, `sourcePlanId`, `sourceProfilePackId`, `sourceRecoveryScoreReference`)  
- `immutableHash`, internal model IDs / version tokens as technical dumps (versions may appear only as calm “how this was built” if already product-pattern elsewhere; default: hide)  
- Raw Weekly Review answer enums untranslated  
- `WeeklyReviewSignal` enums  
- Plan adaptation claims  

#### RPT-03 — Recovery Measurement History

Must show:

- Valid completed ProfilePacks with **valid** Recovery Score only  
- Measurement date (day key / calendar date from pack `createdAt` local day key convention)  
- Score (display integer)  
- Band (localized communication band)  
- Confidence (localized)  
- Domain summary (localized titles; not raw domain IDs)  
- Descriptive within-user comparison when ≥2 compatible packs exist  

Must **not**:

- Invent a trend line from one point  
- Recalculate historical scores with a newer model  
- Show peer percentiles  
- Claim clinical improvement  

---

## 5. Evidence sources

### 5.1 Allowed

| Source | Use |
|---|---|
| Completed `DailySession` records | Counts, day keys, path mix, rhythm inputs via Progress |
| Persisted `ProgressSnapshot` history | Overview session/rhythm/depth inputs; reference id |
| Completed `WeeklyReviewRecord` + immutable `WeeklyArtifact` | Archive + RPT-02 |
| Valid completed `ProfilePack` with valid Recovery Score | RPT-03 |
| Recovery Score snapshot references stamped on packs / artifacts | Display version stamps; never recompute |
| Active/historical Recovery Plan references | Context only (ids/stamps); never mutate |

### 5.2 Forbidden

- Incomplete sessions  
- Draft Weekly Reviews  
- Raw Brain Check answers  
- Raw private session reflections / notes  
- AI-generated summaries  
- Analytics events as evidence  
- Network-derived user interpretation  
- V1 diagnostic / BCI / BC_score history (no migration contract)  
- Legacy V1 weekly report screens as V2 truth  

---

## 6. Report types

### 6.1 V1 report types (only)

1. **Current Evidence Overview** → `RPT-01` / `ReportsOverview`  
2. **Weekly Artifact Detail** → `RPT-02`  
3. **Recovery Measurement History** → `RPT-03`  

### 6.2 Not in V1

- Monthly medical / month chapter report (Build Spec Monthly)  
- Clinical / doctor-facing report  
- PDF export  
- Social sharing / public profile  
- Peer comparison / leaderboards  
- AI report interpretation  
- Automated health recommendations  
- Recovery forecast / predicted completion date  
- Productivity warehouse dashboards  

---

## 7. ReportsOverview

### 7.1 Schema

Read-only derived view. Not a source-of-truth history record.

| Field | Type / notes |
|---|---|
| `reportOverviewId` | Stable derived id for a generation pass, e.g. `rov_{asOfDayKey}_{contentHashPrefix}` |
| `generatedFromDayKey` | Local day key `YYYY-MM-DD` used as “as of” |
| `latestProgressSnapshotId` | Nullable if missing |
| `completedSessionCount` | From completed sessions / latest Progress stats |
| `completedDayCount` | Unique completed day keys |
| `minimumPathCount` | |
| `standardPathCount` | |
| `currentRhythm` | Current consecutive completed-day rhythm (Progress `currentStreak`) |
| `longestRhythm` | Approved: Progress already exposes `longestStreak` / `longestRhythmDays` — include |
| `firstCompletedDayKey` | Nullable |
| `lastCompletedDayKey` | Nullable |
| `weeklyArtifactCount` | Completed artifacts only |
| `latestWeeklyArtifactId` | Nullable |
| `validMeasurementCount` | ProfilePacks with valid Recovery Score |
| `latestProfilePackId` | Nullable |
| `latestRecoveryScoreReference` | Model/version stamp + display value/band only |
| `evidenceDepth` | §8 enum |
| `createdAt` | UTC generation time |
| `reportModelVersion` | `reports_model_v1` |

### 7.2 Rules

- Read-only derived view  
- No new Recovery Score  
- No causal claim fields  
- No fabricated missing history (null / zero / empty, not invented days)  
- Identical semantic inputs ⇒ identical semantic overview  
- Regeneration may refresh the overview without mutating source history  
- Premium state must not change numeric fields, depth label, or score references — only archive **access** (see §14)  

---

## 8. Evidence depth

### 8.1 Namespace

Reports longitudinal depth is **`ReportsEvidenceDepth`** — distinct from:

- Progress `ProgressEvidenceDepth` (session-count on PRG-01)  
- Weekly Review `EvidenceDepth` (within one ISO week)  

Do not overload those enums for Reports Overview.

### 8.2 Labels (product display conventions — not scientific classifications)

| Label | Condition (first match in order below after `no_evidence`) |
|---|---|
| `no_evidence` | `completedSessionCount == 0` |
| `established_history` | `weeklyArtifactCount >= 4` **and** `validMeasurementCount >= 2` |
| `developing_evidence` | `completedDayCount >= 4` **and** `weeklyArtifactCount >= 2` |
| `early_evidence` | else if `completedDayCount` in `1..3` **or** `weeklyArtifactCount == 1` **or** (`completedSessionCount >= 1` and not developing/established) |

Clarifications:

- Zero sessions ⇒ always `no_evidence` even if corrupt stubs exist.  
- One WeeklyArtifact alone may yield `early_evidence` even with few days.  
- `established_history` requires **both** archive and dual measurement proof.  
- These thresholds do not alter Progress or Weekly Review evidence labels on those screens.

### 8.3 User language keys (see §18)

Examples: “Your evidence is still developing” / «ما زالت أدلتك في مرحلة التكوّن».

---

## 9. WeeklyArtifact archive

### 9.1 Behavior

- Completed WeeklyArtifacts only  
- Newest first (`createdAt` desc; tie-break `periodId` desc)  
- Immutable; retrieve by `artifactId`  
- Period label + evidence-depth qualifier (from artifact summary)  
- No raw review answers beyond structured summary fields already frozen for WRV-02  
- No `WeeklyReviewSignal` exposure  
- No internal hashes / source ids to users  
- No Plan adaptation claims  

### 9.2 Free / Premium depth (exact)

| Access | Free | Premium |
|---|---|---|
| Latest (index 0) WeeklyArtifact | **Allowed** | Allowed |
| Previous (index 1) WeeklyArtifact | **Allowed** | Allowed |
| Older artifacts (index ≥ 2) | Soft-gated → Premium appreciation entry | Full history |
| Artifact **content** when accessible | Identical | Identical |
| Current Progress overview / PRG-01 | Full Free | Full |
| Newly created current artifact | Never paywalled | Never paywalled |

**Rule:** Core evidence must never disappear behind Premium immediately after creation. Soft gate applies only after Free depth (latest + previous) is satisfied.

Build Spec “ongoing archive may Soft-gate after first Free” is interpreted as: Free retains **current + one prior** so recent proof remains reachable without purchase.

### 9.3 Missing / corrupt artifacts

Skip corrupt entries for list; open by id → dedicated error state (§13). Never invent replacements.

---

## 10. Recovery measurement history

### 10.1 Inclusion rules

Include a pack only when **all** are true:

1. ProfilePack schema supported  
2. Recovery Score state = **valid** (not pending, not unavailable)  
3. Display integer present  
4. Band is a communication band (not unavailable/pending)  
5. Pack not corrupt  

Sort: newest measurement first.

### 10.2 Preserved historical fields

- Historical `calculationModelVersion` / score model version  
- Measurement date / day key  
- Score display integer  
- Band  
- Confidence  
- Domain summaries (localized titles + display estimates)  
- Mode stamp (Lite / Pulse / Full) for compatibility checks  

### 10.3 Forbidden mutations

- Never recalculate old measurements with a newer model  
- Never modify historical scores  
- Never invent missing measurement points  
- Never convert V1 BC_score into history  

### 10.4 History cardinality

| Count of valid packs | Meaning |
|---|---|
| 0 | No measurements |
| 1 | Baseline only — no comparison |
| ≥2 | Descriptive comparison **only if** compatible (§12) |

### 10.5 Free / Premium measurement depth

| Access | Free | Premium |
|---|---|---|
| Latest valid measurement | Allowed | Allowed |
| One prior comparable baseline for latest-vs-previous comparison | Allowed when compatible | Allowed |
| Full list beyond the latest pair / extended filters / long-horizon summaries | Soft-gated | Allowed |
| Content of any visible measurement | Identical | Identical |

---

## 11. Domain history

### 11.1 Decision (frozen)

- Show **domain history comparison** only when ≥2 comparable ProfilePacks share:  
  - compatible domain schema / catalog (`profileSchemaVersion` + domain aggregation model)  
  - same Recovery Score `calculationModelVersion`  
  - same Brain Check mode policy as overall comparison (§12 / Score Contract §16.2)  
- Otherwise show **latest domain snapshot only**.  
- Never interpolate missing domains.  
- Never compare incompatible model versions numerically.  
- Descriptive language only — no clinical improvement claims.  
- Internal `domainId` strings must **not** be visible to users (use localized titles).  

### 11.2 DomainHistoryPoint

| Field | Notes |
|---|---|
| `profilePackId` | Internal |
| `measurementDayKey` | `YYYY-MM-DD` |
| `domainId` | Internal only |
| `displayedEstimate` | Integer or null if missing on that pack |
| `scoreModelVersion` | |
| `profileSchemaVersion` | |
| `confidence` | Pack-level confidence |

---

## 12. Comparison rules

### 12.1 Compatibility

Compare only when:

- Both packs valid  
- Same `calculationModelVersion`  
- Same mode (Full–Full, Lite–Lite, Pulse–Pulse); **cross-mode = not_comparable** for overall Δ (Score Contract §16.2)  
- Compatible profile/domain schemas for domain Δ  

### 12.2 Allowed comparison result enum

| Result | Meaning |
|---|---|
| `higher` | Latest display integer > earlier |
| `lower` | Latest display integer < earlier |
| `unchanged_within_rounding` | Latest display integer == earlier |
| `not_comparable` | Model/mode/schema mismatch or invalid pair |
| `insufficient_history` | Fewer than two valid packs |

### 12.3 Mandatory soft interpretive overlay (Score Contract §16.3)

When a directional result is `higher` or `lower`, if `|Δ| < 3` **or** elapsed time between measurements `< 7 days`:

- UI **must** apply “too early to interpret” / soft wording  
- Must **not** claim meaningful improvement or decline  
- Must **not** invent percentages of improvement  

Whole-number score comparisons only. No statistical significance. No extrapolation. No forecast. No causal explanation. No “recovered” classification. No automatic Plan change. Missing data stays unavailable. Low-confidence packs receive an uncertainty qualifier.

### 12.4 Plain wording (required patterns)

Allowed:

- “Your latest self-report estimate is higher/lower than your earlier one.”  
- “Compared with your earlier check.”  
- “This is a self-report estimate.”  
- “No cause can be determined from this history.”  
- “Not enough measurements to compare yet.”  

Forbidden:

- “Your brain improved by X%.”  
- “Healed / damaged / cured / diagnosed …”  
- Peer or percentile language  

---

## 13. Empty / error states

Every state provides **one** safe action. Never fabricate a report.

### 13.1 RPT-01

| State | Safe action |
|---|---|
| No completed activity | CTA → Today / Session entry |
| Early evidence | Continue → PRG-01 or complete week toward Weekly Review |
| Reports ready | Primary CTA per §4.3 |
| Missing ProgressSnapshot | Retry rebuild from sessions / return PRG-01 |
| Corrupt history | Skip bad records; show honest incomplete badge; offer PRG-01 |
| Unsupported model version | Honest unsupported; return PRG-01 |
| Persistence failure | Retry; else return home |

### 13.2 RPT-02

| State | Safe action |
|---|---|
| Artifact ready | Close / back → RPT-01 |
| Artifact missing | Return RPT-01 |
| Unsupported artifact version | Honest unsupported → RPT-01 |
| Corrupt artifact | Honest error → RPT-01 |
| Invalid direct access (Premium gate / bad id) | Soft Premium entry **or** RPT-01 recovery — never blank crash |

### 13.3 RPT-03

| State | Safe action |
|---|---|
| No measurements | CTA → Brain Check entry (gated) or PRG-01 |
| One baseline measurement | Show baseline; no comparison claim |
| Multiple comparable measurements | Show history + comparison rules |
| Incompatible measurements | List snapshots; `not_comparable` explanation |
| Unsupported score model | Honest unsupported |
| Missing historical profile | Skip slot; do not invent |

---

## 14. Free / Premium boundary

### 14.1 Core Free value (must remain)

- PRG-01 remains fully useful (four Progress answers Free — Build Spec G3)  
- Latest Weekly Summary / latest WeeklyArtifact Free  
- Previous WeeklyArtifact Free (§9.2)  
- Latest Progress overview Free  
- Latest Recovery Score / Profile Free  
- Latest-vs-previous compatible measurement comparison Free  
- **No paywall blocks current proof**  

### 14.2 Premium may include

- Complete WeeklyArtifact archive beyond Free depth  
- Longitudinal measurement history beyond the Free latest pair  
- Extended historical filtering / long-horizon evidence summaries  
- Future export **only** under a separate export contract  

### 14.3 Premium must not

- Change historical values  
- Change interpretations or wording truthfulness  
- Change `evidenceDepth`  
- Change Recovery Score  
- Change Weekly Review eligibility  
- Hide newly created current evidence  
- Claim higher scientific accuracy  

Subscription must not alter derivation of overview fields or artifact content — only **access depth**.

---

## 15. Ads / Safa / AI boundary

- `RPT-01`, `RPT-02`, `RPT-03` are **proof surfaces**  
- **No** interstitial or rewarded ads  
- **No** ads inside report content  
- Build Spec G2 already blocks ads on Monthly Report; V1 Reports routes inherit the same ad-free treatment as Weekly Review / proof flows  
- If a shell banner is required elsewhere, it must **not** interrupt or obscure report evidence  
- **No** Safa dependency  
- **No** AI-generated reports  
- **No** automatic AI interpretation  
- Reports remain readable **offline** from local data  

---

## 16. Privacy

- Local-first  
- No automatic remote upload of report content  
- No raw Brain Check answers  
- No raw Weekly Review responses  
- No raw private session notes  
- No internal evidence IDs in UI or analytics payloads  
- No analytics containing full report content  
- No automatic share  
- No screenshots / exports generated without explicit user action (export deferred anyway)  
- No clinical privacy certification claims  

Build Spec analytics names (`artifact_view`, `artifact_share`, `monthly_report_view`) remain optional until a sink is approved; `artifact_share` / monthly events are **not** activated in V1 (export deferred). If any view event is emitted later, use categorical props only (screen id, evidence depth enum, free/premium access class) — never score series or answer payloads.

---

## 17. Routing

### 17.1 Gated V2 routes (conceptual; implement later)

| From | To |
|---|---|
| `PRG-01` | `RPT-01` (archive / reports soft entry) |
| `RPT-01` | `RPT-02` (artifact id) |
| `RPT-01` | `RPT-03` |
| `RPT-02` | `RPT-01` |
| `RPT-03` | `RPT-01` |
| Invalid direct route | Safe recovery (`RPT-01` or `PRG-01`) |

Additional recovery: `RPT-02` may also offer back to `PRG-01` when opened from Progress without hub (parity with Build Spec back→PRG-01).

### 17.2 Shell / flag

- Do **not** implement the final tab shell in this contract  
- Feature flag OFF preserves V1 shell and legacy weekly report routes untouched  
- Prefer extending `V2FeatureBoundary` (or equivalent existing gate) so Reports V2 routes redirect home when disabled  

### 17.3 Mutation ban

No Reports route may mutate Score, Profile, Plan, Progress, Weekly Review records, DailySession history, or WeeklyArtifacts.

---

## 18. Localization

### 18.1 Canonical terms

| English | Arabic |
|---|---|
| Reports | التقارير |
| Evidence overview | نظرة عامة على الأدلة |
| Weekly history | السجل الأسبوعي |
| Weekly report | تقرير الأسبوع |
| Measurement history | سجل القياسات |
| Your evidence is still developing | ما زالت أدلتك في مرحلة التكوّن |
| Not enough measurements to compare yet | لا توجد قياسات كافية للمقارنة بعد |
| Compared with your earlier check | مقارنةً بفحصك السابق |
| This is a self-report estimate | هذا تقدير قائم على إجاباتك الذاتية |
| No cause can be determined from this history | لا يمكن تحديد السبب من هذا السجل |

### 18.2 Requirements

- Natural Modern Standard Arabic  
- Plain global English  
- Semantic parity  
- No medical claims  
- No shame  
- No fake certainty  
- No “healed,” “damaged,” “cured,” or diagnostic language  
- ALL UI strings via `app_en.arb` / `app_ar.arb` at implementation time  
- Directionality: RTL Arabic / LTR English parity  

---

## 19. Accessibility

Freeze:

- 320 logical-pixel width usable  
- Text scale 2.0 without clipping essential actions  
- Short-height scrolling  
- Minimum 48 logical-pixel targets  
- Report headings announced  
- Evidence depth announced with explanation  
- Counts announced with units  
- Measurement dates announced  
- Score and confidence announced **separately**  
- Comparison direction announced in plain language  
- No color-only trend communication  
- Lists preferred over inaccessible charts  
- RTL/LTR parity  
- Reduced-motion-safe behavior  
- Errors/loading announced  

---

## 20. Persistence / cache

### 20.1 Source of truth

Reports **do not** own independent history. Source history remains:

- DailySession  
- ProgressSnapshot  
- WeeklyArtifact / WeeklyReviewRecord  
- ProfilePack  

### 20.2 Optional derived cache (allowed, not required)

If implemented for performance:

| Item | Value |
|---|---|
| Box | `reports_cache_v1` |
| Schema | `reports_overview_v1` |
| Model | `reports_model_v1` |

Rules:

- Cache may be rebuilt safely from sources  
- Cache **never** overrides source records  
- Missing/corrupt cache ⇒ recompute; do not error as “no evidence” if sources exist  
- No destructive migration  
- No V1 conversion into Reports cache  
- Premium entitlement is read at access time; do not bake paywall into cached overview numbers  

---

## 21. Test vectors

**Count:** 42 normative vectors.

For every vector, implementers must define: Inputs · Report state · User-visible output · Free/Premium access · Comparison result · Error behavior · Mutation expectation (`none` unless noted).

| # | Scenario | Expected core |
|---|---|---|
| 1 | Zero sessions | `no_evidence`; empty overview; CTA Today/Session |
| 2 | One completed session | `early_evidence`; counts=1; no artifact required |
| 3 | Several sessions (≥4 days), 0 artifacts | not `developing_evidence` yet (needs ≥2 artifacts); early or pre-developing honest state |
| 4 | One WeeklyArtifact | `early_evidence` eligible; Free access to that artifact |
| 5 | Two WeeklyArtifacts | can reach `developing_evidence` if also ≥4 completed days |
| 6 | Four WeeklyArtifacts + ≥2 valid measurements | `established_history` |
| 7 | Latest artifact Free access | Allowed for Free |
| 8 | Previous artifact Free access | Allowed for Free |
| 9 | Older artifact (index ≥2) Premium access | Free soft-gated; Premium allowed; content identical when opened |
| 10 | Subscription does not change artifact content | Same hash/fields Free vs Premium when both can open |
| 11 | No Profile measurement | RPT-03 empty; `insufficient_history` |
| 12 | One Profile measurement | Baseline only; no direction claim |
| 13 | Two compatible measurements | Direction enum among higher/lower/unchanged |
| 14 | Two incompatible model versions | `not_comparable` |
| 15 | Higher latest score | `higher` (+ soft overlay if \|Δ\|<3 or <7d) |
| 16 | Lower latest score | `lower` (+ soft overlay rules) |
| 17 | Same rounded score | `unchanged_within_rounding` |
| 18 | Low-confidence comparison | Uncertainty qualifier present |
| 19 | Missing historical domain | No interpolation; gap shown/unavailable |
| 20 | Compatible domain history | DomainHistoryPoints for shared domains |
| 21 | Incompatible domain schema | Latest domains only; no numeric domain Δ |
| 22 | No causal wording | Copy audit rejects cause claims |
| 23 | No improvement percentage | Copy/UI has no “% improved” |
| 24 | No peer comparison | No percentile/leaderboard |
| 25 | No fabricated point | Sparse history stays sparse |
| 26 | Corrupt WeeklyArtifact | List skips / detail error; no crash invent |
| 27 | Unsupported artifact version | Unsupported state → RPT-01 |
| 28 | Missing ProgressSnapshot | Overview rebuild/retry honesty |
| 29 | Corrupt Profile history | Skip corrupt; valid packs still show |
| 30 | Offline report access | Full local readability |
| 31 | Arabic | Canonical AR terms; MSA; no shame/medical |
| 32 | English | Canonical EN terms; plain language |
| 33 | RTL | Layout parity |
| 34 | LTR | Layout parity |
| 35 | Free core | Current proof + Free depth intact |
| 36 | Premium archive depth | Index ≥2 artifacts + extended measurement history |
| 37 | No ads | No interstitial/rewarded/in-content ads on RPT-* |
| 38 | No Safa/AI | No Safa route; no AI prose |
| 39 | No Score mutation | Packs unchanged after report views |
| 40 | No Plan mutation | Plan pack unchanged after report views |
| 41 | Feature flag OFF preserves V1 | V2 Reports routes unavailable; V1 shell intact |
| 42 | 320 width + text scale 2.0 | Essential actions reachable; headings announced |

---

## 22. Prohibited uses

- Medical or diagnostic labeling  
- Shame / punishment framing from history dips  
- Recalculating historical Recovery Scores  
- Silent Plan rewrite from Reports  
- Inventing sessions, weeks, or measurements  
- Treating Premium as more “scientific”  
- Using V1 weekly_report / BC_score as V2 evidence  
- Monthly chapters without a future contract  
- Automatic share or export  
- Peer comparison warehousing  

---

## 23. Future export boundary

Build Spec optional Share/Export and Monthly chapters are **out of Reports V1**.

A future contract must separately freeze:

- Explicit user action  
- Non-medical disclaimer  
- Exactly which fields may leave the device  
- Formats (image/PDF/etc.)  
- Premium rules  
- Analytics  

Until then: **no share button**, **no export**, **no monthly chapter UI** on Reports V1 screens.

---

## 24. Superseding policy

1. This contract is the authority for Reports V1.  
2. Build Spec ID meanings for `RPT-01`/`RPT-02` are remapped/deferred as in §4.2 until the Build Spec catalog is amended.  
3. Conflicts with Recovery Score math / immutability → Score Contract wins.  
4. Conflicts with WeeklyArtifact schema / immutability → Weekly Review Contract wins.  
5. Conflicts with Plan adaptation ban → Plan Contract wins.  
6. Conflicts with Progress Foundation field meanings → Progress remains source for current proof; Reports must not redefine Progress session math.  
7. Future Build Spec amendments may restore catalog parity without weakening V1 privacy / free-core / non-medical rules unless this document is explicitly revised with a new version stamp.

---

## Appendix A — Source audit (freeze note)

| Source | Finding |
|---|---|
| Build Spec §9 | `RPT-01` artifact detail; `RPT-02` Monthly; share?; archive soft-gate; ads G2 mentions Monthly Report |
| Build Spec ID table | Lists `RPT-01, RPT-02` only |
| Weekly Review Contract | Artifact schema/immutability; Free current summary; archive depth deferred to Reports; out-of-scope Reports |
| Recovery Score Contract | History immutable; longitudinal compare rules §16; soft |\Δ|<3 or <7d |
| Recovery Plan Contract | No automatic adaptation; Free core plan |
| Progress Foundation / PRG-01 | `ProgressSnapshot`, stats incl. longest streak, `ProgressEvidenceDepth`, archive soft entry Premium note |
| WeeklyArtifact implementation | Matches WRV contract fields + hash |
| ProfilePack history | Append-only local history repository |
| Premium foundations | Build Spec PRE-* + soft archive language; no Premium Bible tracked |
| Routing / l10n / boundary patterns | Gated `/v2/*` via `V2FeatureBoundary`; ARB EN/AR |
| Legacy `lib/features/reports/` | V1 weekly report — **not** V2 Reports |
| Reports docs prior | **None** tracked before this file |

### Nonblocking contradictions / debt

1. Build Spec `RPT-01`/`RPT-02` meanings differ from this contract → remapped/deferred in §4.2; catalog should catch up.  
2. Build Spec Share / Monthly export → deferred (§23).  
3. Missing Premium Bible → Free depth frozen here as latest+previous artifact and latest measurement pair.  
4. Multiple evidence-depth namespaces (Progress / WRV / Reports) — intentional; documented in §8.  
5. `V2FeatureBoundary` has no Reports-specific flag yet — add at implementation without startup routing changes.  

None block contract approval for documentation freeze.

---

## Appendix B — Board decision on screen IDs

Governance decision (2026-08-03): adopt preferred V1 structure  
`RPT-01` Overview · `RPT-02` Artifact Detail · `RPT-03` Measurement History,  
with Build Spec Monthly Report deferred and catalog remapping recorded as nonblocking debt.

---

**End of Reports Contract V1.**
