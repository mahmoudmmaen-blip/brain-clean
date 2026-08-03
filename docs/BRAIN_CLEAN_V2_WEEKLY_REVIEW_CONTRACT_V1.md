# Brain Clean V2 — Weekly Review Contract V1

**Document ID:** `BRAIN_CLEAN_V2_WEEKLY_REVIEW_CONTRACT_V1`  
**File:** `docs/BRAIN_CLEAN_V2_WEEKLY_REVIEW_CONTRACT_V1.md`  
**Status:** ENGINEERING CONTRACT — BINDING  
**Date:** 2026-08-03  
**Role:** Weekly Review Governance Board  

**Rule:** Implementation of Weekly Review V1 may begin only after this document.  
Nothing may invent calendar periods, questions, artifact fields, or adaptation beyond this freeze.

**Precedence:**

1. This file binds Weekly Review V1 scope, IDs, schemas, eligibility, and signals.  
2. `BRAIN_CLEAN_V2_BUILD_SPEC.md` remains binding for shell-level navigation and ad/privacy globals.  
3. Where Build Spec is silent or under-specified for Weekly Review (week model, WRV-02, questions), **this contract fills the gap**.  
4. `BRAIN_CLEAN_V2_RECOVERY_PLAN_CONTRACT_V1.md` §23 remains binding: **no automatic plan adaptation** in Weekly Review V1.  
5. `BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1.md` remains binding: Weekly Review **must not** recalculate or mutate Recovery Score.

**Language lock:** Product Language Bible (EN/AR) where present; canonical terms in §17.

---

## 1. Status and authority

This document is the **official Weekly Review Contract V1**.

It freezes decisions that blocked Slice 7.2:

- Local ISO calendar week (not rolling 7-day)
- Official screen IDs `WRV-01` and `WRV-02`
- Eligibility
- Structured question set
- Response types and validation
- Deterministic summary
- Immutable `WeeklyArtifact`
- Structured `WeeklyReviewSignal` for **future** adaptation only
- Persistence identifiers
- Test vectors

**Out of scope for this freeze (and for Weekly Review V1 implementation):**

- Mutating or regenerating Recovery Plan  
- Recovery Score mathematics  
- Brain Profile generation  
- Reports (RPT-01/RPT-02 full surfaces beyond artifact viewability later)  
- Premium archive depth  
- Safa / AI interpretation  
- Ads / RevenueCat / Supabase  
- Production splash or tab-shell replacement  

---

## 2. Purpose

Weekly Review V1 answers:

1. What did the user actually complete last ISO week?  
2. How manageable did the plan feel?  
3. What got in the way?  
4. What supported completion?  
5. What may deserve attention next?  
6. Explicitly: **the plan has not changed yet.**

It produces:

- One eligible weekly period review  
- One resumable structured draft  
- One honest weekly summary (`WRV-02`)  
- One immutable `WeeklyArtifact`  
- One deterministic `WeeklyReviewSignal` stored for a **later** approved adaptation contract  

---

## 3. Product boundary

Weekly Review is:

- A structured look-back  
- Based on completed local Daily Sessions  
- Calm, explainable, non-medical  
- Local-first  
- Honest about limited history  
- Useful when the week was inconsistent  

Weekly Review is **not**:

- A diagnosis or symptom screen  
- A new Brain Check  
- A Recovery Score recalculation  
- A punishment, grade, or streak judgment  
- An AI prose generator  
- A plan mutation engine  
- A Premium hostage point  
- An advertising destination  

---

## 4. ISO-week model

### 4.1 Official V1 period

**LOCAL ISO CALENDAR WEEK**

| Field | Rule |
|---|---|
| Start | Monday 00:00:00 **local** |
| End | Sunday 23:59:59.999 **local** |
| Day keys | Locale-independent `YYYY-MM-DD` via existing `DailyDayKey` convention |
| Week ID | `iso_{isoWeekYear}_W{isoWeek}` with week zero-padded to 2 digits (e.g. `iso_2026_W31`) |
| Week numbering | ISO 8601 week date (week starts Monday; week 1 contains first Thursday of Gregorian year) |
| Locale | Language/locale switch **must not** change week identity |
| First-day | **No Sunday-first** locale variation in V1 |
| Rolling | **Forbidden** in V1 |
| Scientific claim | Product convenience only — not clinical periodicity |

### 4.2 Stored period fields

```
WeeklyPeriod {
  periodId              // Week ID above
  startDayKey           // Monday YYYY-MM-DD
  endDayKey             // Sunday YYYY-MM-DD
  timezoneOffsetMinutes // int; offset used when period was materialized
  materializedAt        // UTC instant
}
```

Historical period boundaries **never** rewrite after materialization.

### 4.3 Current incomplete week

- The ISO week containing “now” (local) is **current**.  
- Current week is **never reviewable**.  
- Sessions in the current week are visible to Progress elsewhere but do not form a WRV period until the week has ended.

### 4.4 Previous completed week

- Default review target = the immediately previous ISO week whose `endDayKey` is strictly before today’s local day key.  
- Example: local Tuesday → review Monday–Sunday of the prior ISO week.

### 4.5 Timezone crossing mid-week

1. New drafts/reviews materialize periods using the device offset **at materialization**.  
2. Existing draft/completed records keep their stored `startDayKey` / `endDayKey` / `timezoneOffsetMinutes`.  
3. Session membership for an already materialized period uses stored day keys only (session `dayKey` ∈ [startDayKey, endDayKey]).  
4. No silent rebasing of historical periods after a timezone change.

### 4.6 First week with partial history

- If the user’s first completed session falls mid-period, the period still uses full Mon–Sun keys.  
- Summary evidenceDepth / rhythmLabel must reflect limited history (see §11).  
- Do **not** invent missing days as completed or failed.

### 4.7 Year boundary and week 53

- Use ISO week-year (may differ from Gregorian year near 1 Jan).  
- `iso_*_W53` is valid when ISO defines week 53.  
- Period identity remains `iso_{weekYear}_W{nn}` with stable Mon–Sun day keys.

### 4.8 Alignment with Build Spec `weekId` / `Δ7`

Build Spec lists inputs `weekId`, `Δ7`. V1 mapping:

| Spec token | V1 binding |
|---|---|
| `weekId` | `WeeklyPeriod.periodId` |
| `Δ7` | Observational labeling for the 7 local day-keys of that ISO week (Mon–Sun), **not** a rolling window |

---

## 5. Screen IDs

| ID | Name | Purpose |
|---|---|---|
| `WRV-01` | Weekly Review Questions | Eligibility / not-ready, structured questions one-at-a-time, autosave, resume, exit |
| `WRV-02` | Weekly Review Summary | Honest artifact summary after completion; plan-unchanged notice; one primary CTA |

**No additional WRV screens in V1.**

### 5.1 WRV-01 required behaviors

- Show not-ready when ineligible  
- Present exactly the question set in §7 order  
- One question visible at a time  
- Autosave after every valid answer change  
- Exact resume to current question index  
- Safe exit preserves draft only  
- Completion allowed only when all required responses are valid  

### 5.2 WRV-02 required behaviors

- Show completed-day count  
- Path mix  
- Rhythm description  
- Main obstacle  
- What felt manageable  
- What may deserve attention  
- Explicit: plan has not changed  
- Evidence/confidence qualifier when limited  
- One primary CTA to approved Progress/Today V2 boundary  

### 5.3 Build Spec catalog note

Build Spec ID catalog currently lists `WRV-01` only. **This contract officially freezes `WRV-02`** for Weekly Review V1. Future Build Spec edits should add `WRV-02` for catalog parity; until then, implementers follow this contract.

---

## 6. Eligibility

A Weekly Review for period `P` is **eligible** only when **all** are true:

1. `P` is a **previous** local ISO week (not current).  
2. At least **one** completed DailySession (full completion / completed mark) has `dayKey` within `[P.startDayKey, P.endDayKey]`.  
3. A valid ProgressSnapshot can be generated that covers completed sessions for that period (period-filtered progress for the week, or a whole-history snapshot from which period subset is derived — implementation may choose, but must not invent sessions).  
4. A valid active RecoveryPlan **or** a plan referenced by those sessions exists.  
5. A valid ProfilePack reference exists (from plan source or session source).  
6. No **completed** WeeklyReviewRecord already exists for `P.periodId`.  
7. All involved schema/model versions are supported (`weekly_review_pack_v1`, related Progress / Session / Plan schemas).

### 6.1 Hard exclusions from eligibility

Must **not** depend on:

- Subscription / Premium  
- Recovery Score band alone  
- Streak  
- Missing-day count as a blocker  
- Ads  
- AI judgment  
- Shame heuristics  

### 6.2 Zero completed sessions

- **Not eligible**  
- No artifact  
- No signal  
- Calm not-ready: “not enough completed activity yet”  

### 6.3 Exactly one completed session

- **Eligible**  
- `evidenceDepth = limited`  
- `rhythmLabel = limited_history`  
- Confidence/signal remain conservative (`insufficient_evidence` or equivalent — §13)  

---

## 7. Question set

Present in this exact order. No free text in V1.

### Q1 — `wrv_manageability`

| Field | Value |
|---|---|
| Type | single_choice |
| Required | yes |
| Meaning | How manageable did the plan feel this week? |
| Options | `too_light` · `about_right` · `too_demanding` |

### Q2 — `wrv_pause_focus`

| Field | Value |
|---|---|
| Type | bounded_scale |
| Required | yes |
| Scale | integer **1–5** |
| Meaning | How much did the sessions help you pause or focus? |

### Q3 — `wrv_obstacle`

| Field | Value |
|---|---|
| Type | single_choice |
| Required | yes |
| Options | `time` · `forgetfulness` · `low_energy` · `interruptions` · `unclear_step` · `access_or_environment` · `no_major_obstacle` |

### Q4 — `wrv_support`

| Field | Value |
|---|---|
| Type | multi_select |
| Required | no |
| Max selections | **2** |
| Options | `shorter_path` · `clearer_timing` · `quieter_environment` · `accessibility_alternative` · `stronger_reminder` · `same_plan_is_working` |

### Q5 — `wrv_accessibility_used`

| Field | Value |
|---|---|
| Type | boolean |
| Required | no |
| Meaning | Did you use an accessibility alternative this week? |

**Forbidden:** diagnostic, medical, shame, open-ended, or “why did you fail?” prompts.

---

## 8. Response validation

| Type | Validation |
|---|---|
| single_choice | Exactly one value from allowed set |
| bounded_scale | Integer in `[1, 5]` |
| multi_select | Unique values ⊆ allowed set; count ∈ `[0, max]` |
| boolean | `true` / `false`, **or absent** when optional unanswered |

Rules:

- No hidden defaults  
- Required unanswered → block completion  
- Optional unanswered → field absent (never coerced to `0` / `false` / empty list unless user selected)  
- Invalid values rejected; draft not updated with invalid payload  
- Save after every **valid** change  
- Local only; never analytics of raw answers  

Response wire shape (conceptual):

```
WeeklyReviewResponse {
  questionId
  answeredAt          // UTC
  singleChoice?       // string
  scaleValue?         // int
  multiSelect?        // string[]
  booleanValue?       // bool
}
```

---

## 9. Draft / resume / exit

### Draft

- One mutable draft per `periodId`  
- Stores: period, question index, responses, source refs, timestamps  
- Status: `draft`

### Resume

- Restore exact question index  
- Restore exact valid answers  
- Same `periodId` and draft id  
- Locale switch preserves draft identity and answers  

### Exit

- Draft preserved  
- **No** summary  
- **No** artifact  
- **No** signal  
- **No** Plan mutation  
- **No** Score mutation  

### Restart

- **Not exposed in V1**  
- No implicit restart  
- Never delete DailySession or Progress history  

---

## 10. Completion

Completion requires:

- Eligible period  
- All required responses valid  
- Valid source ProgressSnapshot reference for period computation  
- Valid Plan / Profile references  
- No completed record already present for the period  

Completion creates **exactly once** for that period:

1. `WeeklyReviewRecord` (status `completed`)  
2. `WeeklyReviewSummary`  
3. `WeeklyArtifact`  
4. `WeeklyReviewSignal`  

Repeated completion:

- Returns existing record / artifact / signal  
- Creates **no** duplicates  
- Changes **no** Plan  
- Changes **no** Recovery Score  

Completed records, summaries, artifacts, and signals are **immutable**.

---

## 11. Weekly summary

### 11.1 Schema — `WeeklyReviewSummary`

| Field | Notes |
|---|---|
| `periodId` | ISO week id |
| `periodStartDayKey` | Monday |
| `periodEndDayKey` | Sunday |
| `completedSessionCount` | Full completions in period |
| `completedDayCount` | Unique day keys with ≥1 full completion |
| `minimumPathCount` | Sessions with minimum path |
| `standardPathCount` | Sessions with standard path |
| `pathMixLabel` | enum §11.2 |
| `rhythmLabel` | enum §11.2 |
| `evidenceDepth` | enum §11.2 |
| `manageabilityResponse` | from Q1 |
| `pauseFocusResponse` | from Q2 (1–5) |
| `obstacleResponse` | from Q3 |
| `supportResponses` | from Q4 (0–2) |
| `accessibilityUsed` | from Q5 or `null` if unanswered |
| `strongestObservedPattern` | deterministic short key §11.3 |
| `attentionNext` | deterministic short key §11.3 |
| `planUnchangedNotice` | always true conceptually; copy in UI |
| `confidenceQualifier` | string key §11.3 |
| `generatedAt` | UTC |
| `modelVersion` | `weekly_review_model_v1` |

### 11.2 Deterministic labels

**pathMixLabel**

| Condition | Label |
|---|---|
| `completedSessionCount == 1` | `single_session_only` |
| `minimumPathCount > 0` and `standardPathCount == 0` | `mostly_minimum` |
| `standardPathCount > 0` and `minimumPathCount == 0` | `mostly_standard` |
| else (both > 0) | `balanced` |

**rhythmLabel**

| Condition | Label |
|---|---|
| `completedSessionCount == 1` OR `completedDayCount <= 1` | `limited_history` |
| `completedDayCount >= 5` | `steady` |
| else | `intermittent` |

**evidenceDepth**

| Condition | Label |
|---|---|
| `completedSessionCount == 1` | `limited` |
| `completedSessionCount` in `2..3` | `developing` |
| `completedSessionCount >= 4` | `sufficient_for_weekly_summary` |

### 11.3 Pattern / attention / confidence keys

Deterministic, non-medical keys (UI localizes):

**strongestObservedPattern**

1. If `completedSessionCount == 1` → `single_completion_observed`  
2. Else if pathMix `mostly_minimum` → `minimum_path_majority`  
3. Else if pathMix `mostly_standard` → `standard_path_majority`  
4. Else if pathMix `balanced` → `mixed_paths`  
5. Else → `completed_activity_present`

**attentionNext** (priority order; first match wins)

1. Q1 `too_demanding` → `consider_load`  
2. Q1 `too_light` → `consider_support_depth`  
3. Q3 not `no_major_obstacle` → `obstacle_{option}`  
4. Q2 ≤ 2 → `pause_focus_low`  
5. Else → `maintain_observation`

**confidenceQualifier**

| evidenceDepth | Key |
|---|---|
| `limited` | `limited_evidence` |
| `developing` | `early_evidence` |
| `sufficient_for_weekly_summary` | `summary_only_not_causal` |

### 11.4 Prohibited summary content

- New Recovery Score  
- Diagnosis / mood inference / medical conclusions  
- Causation claims  
- User comparisons  
- Grades / shame / “bad week” / “failure”  
- Invented missing history  
- AI-generated prose  

---

## 12. WeeklyArtifact

### 12.1 Schema

| Field | Notes |
|---|---|
| `artifactId` | Stable: `wart_{periodId}` |
| `weeklyReviewRecordId` | Parent record |
| `periodId` | |
| `sourceProgressSnapshotId` | Snapshot used at completion |
| `sourcePlanId` | |
| `sourceProfilePackId` | |
| `sourceRecoveryScoreReference` | Model/version stamp only — **not** a recalculated score |
| `summary` | `WeeklyReviewSummary` |
| `completedSessionIds` | Ordered list of session ids in the period |
| `createdAt` | UTC |
| `artifactSchemaVersion` | `weekly_artifact_v1` |
| `reviewModelVersion` | `weekly_review_model_v1` |
| `immutableHash` | Deterministic content hash |

### 12.2 Rules

- Exactly one artifact per completed review / period  
- Immutable after creation  
- Repeated completion returns existing artifact  
- Raw question answers are **not** required on the artifact surface (summary carries structured responses needed for display)  
- No AI prose; no network  

---

## 13. WeeklyReviewSignal (future adaptation only)

### 13.1 Schema

| Field | Notes |
|---|---|
| `signalId` | `wrsig_{periodId}` |
| `periodId` | |
| `sourceArtifactId` | |
| `planFitSignal` | enum |
| `loadSignal` | enum |
| `obstacleSignal` | enum |
| `accessibilitySignal` | enum |
| `evidenceDepth` | same as summary |
| `confidence` | `low` · `moderate` · `adequate_for_signal` |
| `createdAt` | UTC |
| `signalVersion` | `weekly_review_signal_v1` |

### 13.2 Allowed enums

**planFitSignal:** `maintain` · `consider_more_support` · `consider_less_load` · `insufficient_evidence`  

**loadSignal:** `light` · `suitable` · `heavy` · `unknown`  

**obstacleSignal:** `time` · `forgetfulness` · `low_energy` · `interruptions` · `unclear_step` · `access_or_environment` · `none` · `unknown`  

**accessibilitySignal:** `used` · `not_used` · `unknown`  

### 13.3 Deterministic mapping (frozen)

Apply in order:

**A. Evidence gate**

If `evidenceDepth == limited` OR `completedSessionCount == 1`:

- `planFitSignal = insufficient_evidence`  
- `loadSignal` from Q1 if answered else `unknown` (see B)  
- `obstacleSignal` from Q3 if answered else `unknown`  
- `accessibilitySignal` from Q5 else `unknown`  
- `confidence = low`  
- Stop (still emit remaining mapped fields below for load/obstacle).

**B. loadSignal from Q1**

| Q1 | loadSignal |
|---|---|
| `too_light` | `light` |
| `about_right` | `suitable` |
| `too_demanding` | `heavy` |
| missing | `unknown` |

**C. planFitSignal (when not insufficient_evidence)**

| Condition | planFitSignal |
|---|---|
| Q1 `too_demanding` | `consider_less_load` |
| Q1 `too_light` | `consider_more_support` |
| Q1 `about_right` | `maintain` |
| else | `insufficient_evidence` |

**D. obstacleSignal from Q3**

| Q3 | obstacleSignal |
|---|---|
| `no_major_obstacle` | `none` |
| any other option | same token as option |
| missing | `unknown` |

**E. accessibilitySignal from Q5**

| Q5 | accessibilitySignal |
|---|---|
| `true` | `used` |
| `false` | `not_used` |
| absent | `unknown` |

**F. confidence (when not forced low)**

| evidenceDepth | confidence |
|---|---|
| `developing` | `moderate` |
| `sufficient_for_weekly_summary` | `adequate_for_signal` |

### 13.4 Signal rules

- Deterministic; no AI; no network; no randomness  
- **Does not** modify Plan  
- **Does not** modify Recovery Score  
- Is **not** a recommendation UI mandate  
- Is **not** medical  
- Is **not** Premium-dependent  
- Slice 7.2 (and this V1 review) **stores only**  
- Future adaptation requires a **separate approved contract**  

---

## 14. Persistence

| Identifier | Value |
|---|---|
| Box | `weekly_review_v1` |
| Pack schema | `weekly_review_pack_v1` |
| Artifact schema | `weekly_artifact_v1` |
| Review model | `weekly_review_model_v1` |
| Signal model | `weekly_review_signal_v1` |

Repository behavior:

- Mutable draft by `periodId`  
- Append-only completed reviews  
- Retrieval by period  
- Latest completed review  
- Artifact by review id / period  
- Signal by artifact id  
- Idempotent save / completion  
- Corrupt records skipped safely  
- Unsupported versions surfaced honestly  
- No destructive migration  
- No V1 conversion  
- No Supabase / remote raw review storage  

Register through existing Hive bootstrap patterns when implementing.

### 14.1 WeeklyReviewRecord (conceptual)

```
WeeklyReviewRecord {
  id
  periodId
  periodStartDayKey
  periodEndDayKey
  timezoneOffsetMinutes
  status                  // draft | completed
  questionIndex
  responses[]
  sourceProgressSnapshotId
  sourcePlanId
  sourceProfilePackId
  sourceRecoveryScoreReference
  completedSessionIds[]
  summary?                // set on completion
  artifactId?             // set on completion
  signalId?               // set on completion
  createdAt
  updatedAt
  completedAt?
  schemaVersion           // weekly_review_pack_v1
  reviewModelVersion      // weekly_review_model_v1
}
```

---

## 15. History and immutability

- Completed reviews, summaries, artifacts, signals: immutable  
- Drafts: mutable until completion  
- Historical periods: never rebased  
- DailySession / Progress history: never deleted by Weekly Review  
- One completed review per period  

---

## 16. Routing

| From | To |
|---|---|
| Future Progress UI or gated V2 test entry | Eligibility gate → WRV-01 or not-ready |
| WRV-01 valid completion | WRV-02 |
| Draft re-entry | WRV-01 exact resume |
| Completed period re-open | WRV-02 historical |
| Not eligible | Calm not-ready |
| Invalid direct route | Safe recovery |
| WRV-02 primary CTA | Approved V2 Progress or Today boundary |

Rules:

- No route mutates Plan  
- No production splash / shell replacement  
- Feature flag OFF preserves V1  
- No Premium interruption; no Safa auto-route  

Deep link token `weekly_review` (Build Spec) resolves to WRV-01 when eligible, else Progress/not-ready — not Reports.

---

## 17. Localization

### Canonical English

- Weekly Review  
- Weekly Summary  
- This week’s pattern  
- What got in the way  
- What supported you  
- Your plan has not changed yet  

### Canonical Arabic

- المراجعة الأسبوعية  
- ملخص الأسبوع  
- نمط هذا الأسبوع  
- ما الذي أعاقك؟  
- ما الذي ساعدك؟  
- لم تتغير خطتك بعد  

Requirements:

- Natural Modern Standard Arabic  
- Plain global English  
- Semantic parity  
- No shame / diagnosis / medical / cure / “bad week” / “failure”  
- No mixed-language UI state  

---

## 18. Accessibility

Minimum for WRV surfaces:

- 320 logical-pixel width  
- Text scale 2.0  
- Short-height scrolling  
- ≥48 logical-pixel targets  
- Progress / question / selection / summary announced  
- Numbers with context  
- No color-only meaning  
- Logical focus order  
- RTL/LTR parity  
- Reduced-motion-safe transitions  
- Loading/errors announced  

---

## 19. Free / Premium boundary

| Capability | V1 |
|---|---|
| WRV-01 | Free |
| Current WRV-02 summary | Free |
| WeeklyArtifact creation | Free |
| Signal generation | Independent of subscription |
| Long-term archive/compare depth | Future Premium contract only |

Subscription must not alter eligibility, core summary content, or signal mapping.

---

## 20. Ads / Safa / AI boundary

- All Weekly Review routes: **ad-free** (Build Spec G2)  
- No paywall interruption  
- No Safa dependency  
- No AI-generated interpretation  
- No automatic Safa route  

---

## 21. Privacy

- Local only  
- No new analytics unless exact approved event IDs + existing safe sink exist later  
Never log:

- Raw review responses  
- Private text (none in V1)  
- Profile domain values  
- Score internals  
- Full weekly summary as analytics payload  
- Identity-linked plan-fit details  

Build Spec analytics names (`weekly_review_open`, `weekly_artifact_save`, …) remain optional until a sink is approved; if emitted later, use categorical props only.

---

## 22. Test vectors

**Count:** 32 normative vectors.

| # | Scenario | Eligibility | Expected core |
|---|---|---|---|
| 1 | Previous ISO week, 0 sessions | No | Not-ready; no artifact/signal |
| 2 | 1 completed session | Yes | `limited_history`, `limited`, `insufficient_evidence` |
| 3 | Several completed sessions (≥4 days) | Yes | `steady` possible; `sufficient_for_weekly_summary` if ≥4 sessions |
| 4 | Current week sessions only | No | Not reviewable |
| 5 | Already completed review | No new | Return existing artifact/signal |
| 6 | Locale switch mid-draft | — | Same periodId; answers retained |
| 7 | Timezone change after materialize | — | Stored day keys unchanged |
| 8 | Year boundary ISO week | — | Correct `iso_{weekYear}_Wnn` |
| 9 | ISO week 53 | — | Valid periodId + Mon–Sun keys |
| 10 | Minimum-only paths | Yes | `mostly_minimum` |
| 11 | Standard-only paths | Yes | `mostly_standard` |
| 12 | Balanced paths | Yes | `balanced` |
| 13 | Q1 too_light | Yes | load `light`; planFit `consider_more_support` (if evidence > limited) |
| 14 | Q1 about_right | Yes | load `suitable`; planFit `maintain` |
| 15 | Q1 too_demanding | Yes | load `heavy`; planFit `consider_less_load` |
| 16 | Q2 = 1 | Yes | attention may `pause_focus_low` if higher priority unused |
| 17 | Q2 = 5 | Yes | Valid scale |
| 18 | Each Q3 obstacle | Yes | Matching `obstacleSignal` |
| 19 | Q4 exactly 2 supports | Yes | Persist both |
| 20 | Q4 > 2 supports | Reject | Invalid; draft unchanged |
| 21 | Q5 true | Yes | accessibility `used` |
| 22 | Required answer missing | Block | No completion |
| 23 | Exit draft | — | Draft kept; no summary/artifact/signal |
| 24 | Resume draft | — | Exact question index |
| 25 | Idempotent completion | — | Same ids/hashes |
| 26 | Corrupt record in history | — | Skip safely |
| 27 | Unsupported schema version | — | Honest unsupported state |
| 28 | Free vs Premium same inputs | — | Identical core outputs |
| 29 | Completion vs Plan | — | Plan unchanged |
| 30 | Completion vs Score | — | Score unchanged |
| 31 | Arabic copy | — | Canonical terms present; no shame/medical |
| 32 | English copy | — | Canonical terms present; no shame/medical |

Vector template fields for implementers:

- Inputs (period, sessions, answers, refs)  
- Eligibility  
- Expected review state  
- Expected summary labels  
- Expected artifact identity  
- Expected signal enums  
- Expected persistence behavior  

---

## 23. Prohibited uses

- Using Weekly Review to punish missing days  
- Silent plan rewrite  
- Score mutation disguised as “insight”  
- Clinical labeling  
- Inventing sessions or days  
- Treating signal as a user-facing mandate or diagnosis  
- Rolling 7-day windows in V1  
- Sunday-first weeks in V1  

---

## 24. Future adaptation boundary

Recovery Plan Contract §23:

> Weekly Review may create a **new** plan version later. **No automatic adaptation** before that system exists.

Weekly Review V1:

- May **store** `WeeklyReviewSignal`  
- Must **not** create `PlanAdaptation` drafts that apply  
- Must **not** regenerate RecoveryPlanPack  
- Adaptation requires a separate approved contract after this freeze  

Build Spec WRV-01 output “optional PlanAdaptation draft” is **deferred** out of V1 implementation; V1 substitutes the non-mutating `WeeklyReviewSignal`.

---

## 25. Superseding policy

1. This contract is the authority for Weekly Review V1.  
2. Build Spec under-specification on week model / WRV-02 / questions is resolved **here**.  
3. Conflicts with frozen Recovery Score math → Score Contract wins; Weekly Review must not recalculate.  
4. Conflicts with Recovery Plan adaptation ban → Plan Contract wins; store signal only.  
5. Future Build Spec amendments may raise catalog parity (add WRV-02) without weakening V1 rules unless this document is explicitly revised with a new version stamp.

---

## Appendix A — Source audit (freeze note)

| Source | Finding |
|---|---|
| Build Spec | `WRV-01` only; `WeeklyArtifact` named; inputs `weekId`, `Δ7`; adaptation draft mentioned; no question set |
| Recovery Plan Contract | Adaptation future-only; no week calendar |
| Recovery Score Contract | Soft “too early” language for short spans; Weekly Review must not emit new score |
| Progress Foundation | `ProgressSnapshot` + stats/timeline/summary; day keys `YYYY-MM-DD` |
| DailySession | Completed sessions + marks + path + dayKey |
| Day-key convention | `DailyDayKey.fromLocal` locale-independent |
| Weekly Review code | None at freeze time |

### Nonblocking contradictions / debt

1. Build Spec ID catalog lacks `WRV-02` → frozen here; catalog should catch up.  
2. Build Spec mentions PlanAdaptation draft → deferred; signal stored instead.  
3. Build Spec `Δ7` naming → mapped to ISO Mon–Sun observational span, not rolling.  

None block contract approval.

---

**End of Weekly Review Contract V1.**
