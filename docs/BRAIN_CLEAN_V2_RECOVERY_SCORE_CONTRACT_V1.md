# Brain Clean V2 — Recovery Score Mathematics Contract V1

**Document ID:** `BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1`  
**Status:** APPROVED FOR IMPLEMENTATION (Slice 3.1 freeze)  
**Authority class:** Product measurement contract  
**Branch context:** `v2/product-rebuild`  
**Frozen against HEAD:** `8b9f99c3cc3ac5e40e6733e1a6626d018b1b81c4`  
**Model version identifier:** `recovery_score_v1`  
**Weight-set identifier:** `weight_set_equal_v1`  
**Domain aggregation companion:** `domain_mean_v1` (superseded for polarity + overall score by this contract)  
**Profile schema companion:** `brain_profile_pack_v1` (shape retained; score fields become non-pending under `recovery_score_v1`)

---

## 1. Status and authority

### 1.1 Binding authority order

1. This contract (for Recovery Score mathematics, confidence, bands, edge cases, and Slice 4 score inputs)
2. `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md` (screen IDs, ProfilePack object, non-medical UX rules, “no BCI”)
3. Existing tracked Product OS constitution / scientific evidence framework under `brain_clean_mobile/docs/product_os/` (non-medical boundary and anti-BCI honesty)
4. Implemented Brain Check item bank + ProfilePack models in `lib/features/brain_check/` and `lib/features/brain_profile/`

### 1.2 Non-authority

The following were **requested but not present** as tracked Recovery Score mathematics authorities in this worktree and therefore **must not be assumed**:

- `BRAIN_CHECK_MASTER_SPEC_V1.md`
- `PROFILE_MASTER_SPEC_V1.md`
- `BRAIN_CLEAN_SCIENTIFIC_MODEL_V1.md`
- `BRAIN_CLEAN_RECOVERY_MATHEMATICS_V1.md`
- `BRAIN_CLEAN_EVIDENCE_REGISTRY_V1.md`
- `BRAIN_CLEAN_PRODUCT_LANGUAGE_BIBLE_V1.md`
- `BRAIN_CLEAN_USER_BIBLE_V1.md`
- `BRAIN_CLEAN_EMOTIONAL_BLUEPRINT_V1.md`

Build Spec mentions `κ` / ImprovementConfidence but **does not define** numerical κ, Recovery Score weights, bands, or formula. Those gaps are closed **here** as product heuristics, not scientific claims.

### 1.3 Freeze statement

This document freezes the V1 Recovery Score contract so Slice 3 finalization and Slice 4 Recovery Plan can proceed without inventing mathematics in code.

---

## 2. Purpose

Define a **deterministic, explainable, local-first Recovery Score estimate** derived only from a completed, valid Brain Check `MeasurementEvent`.

The score exists to:

- Summarize self-reported domains into one calm overall estimate
- Support bilingual explanation
- Feed Recovery Plan intensity hints (not diagnosis)
- Enable later longitudinal comparison under explicit rules

---

## 3. Non-medical boundary

Recovery Score is:

- A self-reported snapshot estimate
- A product measurement for noticing change
- Versioned, recalculable for **new** profiles only
- Always shown with confidence and plain-language limits

Recovery Score is **not**:

- A medical, neurological, or clinical diagnosis
- Proof of brain damage or recovery
- A measure of intelligence
- A psychometric instrument with claimed clinical validity
- A substitute for professional evaluation
- “BCI” or any clinical-looking invented index marketed as science

**Prohibited user-facing language:** brain damage, neurological diagnosis, clinical diagnosis, dopamine damage, permanent impairment, scientifically proven cure, guaranteed recovery, healthy/unhealthy brain, red-zone danger framing, “you are broken.”

---

## 4. Inputs

### 4.1 Required calculation inputs

| Input | Source | Notes |
|---|---|---|
| `MeasurementEvent` | Completed Brain Check | Mode, answers, section IDs, timestamps, language |
| Mode item bank | `BrainCheckItemBank` for `lite` / `pulse` / `full` | Version stamp `brain_check_measurement_v1` |
| Question polarity table | §5 of this contract | Forward vs reverse |
| Weight set | `weight_set_equal_v1` | Mode-scoped |

### 4.2 Explicit non-inputs

- AI / LLM output
- Network responses
- Random values
- V1 diagnostic / BCI / BC_score storage
- Ads, entitlement, or Premium state
- Plan completion percentage
- Session streak or XP

### 4.3 Approved domains (from implemented item bank)

#### Lite (`BrainCheckMode.lite`)

| Domain ID | Title EN | Title AR | Questions (all required for Lite score) |
|---|---|---|---|
| `lite_attention` | Attention | الانتباه | `lite_q1`, `lite_q2`, `lite_q3` |
| `lite_recovery` | Recovery readiness | جاهزية التعافي | `lite_q4`, `lite_q5`, `lite_q6` |

#### Pulse (`BrainCheckMode.pulse`)

| Domain ID | Title EN | Title AR | Questions |
|---|---|---|---|
| `pulse_check` | Pulse check | نبضة سريعة | `pulse_q1`…`pulse_q4` |

#### Full (`BrainCheckMode.full`)

| Domain ID | Title EN | Title AR | Questions |
|---|---|---|---|
| `full_attention` | Attention | الانتباه | `full_q1`, `full_q2`, `full_q3` |
| `full_mood` | Mood balance | توازن المزاج | `full_q4`, `full_q5`, `full_q6` |
| `full_habits` | Daily habits | العادات اليومية | `full_q7`, `full_q8`, `full_q9` |
| `full_intention` | Intention | النية | `full_q10`, `full_q11`, `full_q12` |

### 4.4 Response scales (implemented)

| Scale | Raw range | Wire name |
|---|---|---|
| Likert agreement | 1–5 | `likert5` |
| Frequency | 1–5 | `frequency` |
| Yes / No | 0–1 (`no`=0, `yes`=1) | `yesNo` |

### 4.5 Required vs optional (V1 freeze)

- **For the selected mode path, every question in the current item bank is required** for a final Recovery Score.
- Future adaptive deepeners (Build Spec “Adaptive”) are **optional** only if they were never shown; unanswered deepeners **must not** block score generation and **must not** be imputed as 0.
- V1 bank has no optional items today.

---

## 5. Domain normalization

### 5.1 Directionality (global)

- **0** = greatest currently reported recovery need (weaker reported state)
- **100** = strongest currently reported state
- Higher Recovery Score ⇒ stronger self-reported snapshot (not “healthier brain”)

### 5.2 Item polarity

Each question has polarity `forward` or `reverse`.

**Reverse** means the stem describes a struggle / pull / avoidance pattern where **higher raw answers indicate greater need**.

#### V1 polarity table (authoritative for `brain_check_measurement_v1`)

| Question ID | Polarity | Rationale (product, not clinical) |
|---|---|---|
| `lite_q1` | forward | Capability / steadiness |
| `lite_q2` | forward | Clarity for short work |
| `lite_q3` | forward | Awareness of aimless scrolling is protective |
| `lite_q4` | forward | Desire for calmer routine (`yes`=1) |
| `lite_q5` | forward | Ability to protect a session |
| `lite_q6` | forward | Readiness for a gentle plan |
| `pulse_q1` | forward | Steadier focus vs last week |
| `pulse_q2` | forward | Protected a calm break |
| `pulse_q3` | forward | Urge feels manageable |
| `pulse_q4` | forward | Desire to continue |
| `full_q1` | forward | Task completion without app switching |
| `full_q2` | forward | Reading without losing thread |
| `full_q3` | **reverse** | Notifications pull away often |
| `full_q4` | forward | Calmer evenings |
| `full_q5` | forward | Recover after stressful online moment |
| `full_q6` | **reverse** | Screens to avoid uncomfortable feelings |
| `full_q7` | forward | Consistent sleep window |
| `full_q8` | forward | Move body briefly |
| `full_q9` | forward | Protect offline time |
| `full_q10` | forward | Know why cleaner digital life matters |
| `full_q11` | forward | Can name one small change |
| `full_q12` | forward | Ready for personal recovery path |

**Audit note:** Slice 3 `DomainAggregator.normalizeAnswer` currently treats all items as forward and silently clamps. Finalization **must** apply this polarity table and the invalid-data rules in §13. That is a deliberate supersession, not silent drift.

### 5.3 Exact item normalization (pseudocode)

```
function normalizeItem(question, rawValue) -> Result<ItemScore>:
  min = question.scale.minValue
  max = question.scale.maxValue

  if rawValue is missing:
    return Missing

  if rawValue is not an integer OR rawValue < min OR rawValue > max:
    return InvalidRange(rawValue)   # do NOT clamp silently

  # Linear map to 0..100 in raw direction first
  forward01 = (rawValue - min) / (max - min)
  forward100 = forward01 * 100

  if question.polarity == reverse:
    item100 = 100 - forward100
  else:
    item100 = forward100

  return Ok(item100)   # retain full double precision internally
```

### 5.4 Domain score

```
function domainScore(domain, answers) -> Result<DomainScore>:
  itemScores = []
  for question in domain.questions:   # all required in V1 path
    r = normalizeItem(question, answers[question.id])
    if r is Missing: return IncompleteRequired
    if r is InvalidRange: return InvalidData
    itemScores.append(r.value)

  mean = average(itemScores)          # equal weight within domain
  return Ok(DomainScore(
    domainId,
    valueInternal = mean,             # precision retained
    valueDisplayHint = roundHalfUp(mean)  # whole number for UI only
  ))
```

Unanswered optional (future) items: **omit from mean**; never convert to 0.

### 5.5 Worked examples

**Example A — Likert forward (`full_q1`, min=1, max=5, raw=5)**  
`(5-1)/(5-1)*100 = 100`

**Example B — Likert reverse (`full_q3`, raw=5 “often”)**  
Forward map = 100; reverse → `0`

**Example C — Frequency reverse (`full_q6`, raw=1 “rarely”)**  
Forward map = 0; reverse → `100`

**Example D — Yes/No forward (`lite_q4`, yes=1)**  
`(1-0)/(1-0)*100 = 100`

**Example E — Yes/No forward (`lite_q4`, no=0)**  
`0`

**Example F — Domain mean**  
Items `{0, 50, 100}` → domain internal `50.0` → display `50`

---

## 6. Directionality

| Concept | Direction |
|---|---|
| Item score after polarity | Higher = stronger reported state |
| Domain score | Higher = stronger reported state in that domain |
| Overall Recovery Score | Higher = stronger overall self-report estimate |
| Progress % of Brain Check | **Orthogonal** — never substitute for Recovery Score |
| Confidence | **Orthogonal** — never derived from score magnitude |

---

## 7. Domain weights

### 7.1 Evidence search result

No approved product or scientific authority in this worktree defines unequal Recovery Score domain weights.

Therefore **equal domain weighting** is selected as the **conservative V1 product heuristic**, explicitly **not** scientific truth.

### 7.2 Weight set `weight_set_equal_v1`

Weights apply **only to domains included for the MeasurementEvent mode**. Within a mode, weights sum to **1.00**.

#### Lite

| Domain | Weight |
|---|---|
| `lite_attention` | 0.50 |
| `lite_recovery` | 0.50 |
| **Sum** | **1.00** |

#### Pulse

| Domain | Weight |
|---|---|
| `pulse_check` | 1.00 |
| **Sum** | **1.00** |

#### Full

| Domain | Weight |
|---|---|
| `full_attention` | 0.25 |
| `full_mood` | 0.25 |
| `full_habits` | 0.25 |
| `full_intention` | 0.25 |
| **Sum** | **1.00** |

### 7.3 Excluded domains

| Exclusion | Reason |
|---|---|
| Domains from a different mode | Mode-scoped measurement only |
| Unknown domain IDs | Invalid / unavailable (see §13) |
| V1 diagnostic subscales / BCI | Different product generation; no conversion |
| Future deepeners not shown | Not part of weight set until versioned |

### 7.4 Future review conditions

Revisit unequal weights only when an approved mathematics / assessment authority is added to this repo **and** explicitly defines weights. Until then, do not invent differentials.

---

## 8. Overall score formula

### 8.1 Preconditions for a **valid final score**

All must hold:

1. `MeasurementEvent` mode is known (`lite` | `pulse` | `full`)
2. Every **required** question for that mode has a present, in-range answer
3. Every answered question ID is known to the item bank version stamped on the event
4. At least one included domain has a valid domain score
5. Sum of included valid domain weights > 0

If any fail → score state = **`unavailable`** (not `0`).

### 8.2 Formula

```
overallInternal =
  sum( domainScoreInternal_i * weight_i )
  / sum( weight_i for included valid domains )

# Equivalent under weight_set_equal_v1 with all domains valid:
# equal-weight mean of domain scores.
```

Because V1 requires all mode domains to be complete before scoring, the denominator equals **1.00** whenever a final score is produced.

### 8.3 Contribution (explainability)

```
contribution_i = domainScoreInternal_i * weight_i
contributionShare_i = contribution_i / overallInternal   # when overallInternal > 0
```

Store/expose contributions for explanations; do not show raw evidence IDs.

### 8.4 Model version

| Field | Value |
|---|---|
| `calculationModelVersion` | `recovery_score_v1` |
| `weightSetVersion` | `weight_set_equal_v1` |
| Supersedes pending | `recovery_score_pending_v0` |

---

## 9. Rounding

| Layer | Rule |
|---|---|
| Internal | IEEE-754 double (or equivalent); no random noise |
| Domain display | `roundHalfUp(domainInternal)` → integer 0–100 |
| Overall display | `roundHalfUp(overallInternal)` → integer 0–100 |
| User-facing | **Whole numbers only** — never show fake decimals (e.g. 67.3) |
| Ties at `.5` | Round **away from zero toward +∞ for positive scores** (standard half-up): 67.5 → 68 |

**Output range:** integer **0–100** inclusive when valid.

**Unavailable:** no numeric score rendered; use pending/unavailable copy.

---

## 10. Confidence

### 10.1 Purpose

Confidence describes **measurement completeness and snapshot stability only**.  
It does **not** claim clinical validity, scientific accuracy, or score correctness.

### 10.2 Levels (max three)

| Internal ID | User EN | User AR |
|---|---|---|
| `provisional` | Provisional | أولية |
| `moderate` | Moderate | متوسطة |
| `strong` | Strong | جيدة |

Wire compatibility: map legacy Slice 3 `solid` → `strong` on read for new calculations; historical packs may still store `solid` and must remain immutable.

### 10.3 Exact rules

Evaluate in order; first match wins after completeness gate.

**Gate — incomplete required answers**  
→ do not emit final score; confidence for any partial preview (if shown) = `provisional`.

**Then:**

| Condition | Confidence |
|---|---|
| Corrupt/partial recovery used to assemble answers, OR unknown question version corrected, OR schema mismatch flagged | `provisional` |
| Mode `lite` or `pulse`, all required answers valid, first profile for this user device history **or** any retake | `moderate` (Lite/Pulse never auto-`strong` in V1) |
| Mode `full`, all required answers valid, no corrupt recovery, current schema + `recovery_score_v1` | `strong` |
| Mode `full`, all required answers valid, but optional deepeners omitted (future) or minor metadata inconsistency that did not change answers | `moderate` |
| Otherwise | `provisional` |

**Forbidden:** deriving confidence from the numeric Recovery Score (high score ≠ strong confidence).

### 10.4 User explanation (canonical)

| Level | EN meaning | AR meaning |
|---|---|---|
| Provisional | This snapshot is early or incomplete; treat it gently. | هذه اللقطة مبكرة أو غير مكتملة؛ تعامل معها بلطف. |
| Moderate | Coverage is enough for a useful estimate, with normal uncertainty. | التغطية كافية لتقدير مفيد، مع عدم يقين طبيعي. |
| Strong | Coverage for this Full check is solid for product use — still not a diagnosis. | تغطية هذا الفحص الكامل جيدة للاستخدام في المنتج — وليست تشخيصاً. |

### 10.5 Prohibited interpretations

- “Scientifically validated”
- “Clinically reliable”
- “Your brain is measured accurately”
- Equating Strong confidence with guaranteed improvement

---

## 11. Bands

### 11.1 Nature

**Product communication bands only** — not validated clinical thresholds.  
Always show with explanation + confidence. Never show band alone.

### 11.2 Four bands (inclusive ranges on **displayed** overall integer)

| Internal ID | Range | EN label | AR label |
|---|---|---|---|
| `gathering_footing` | 0–24 | Gathering footing | جمع القوة للبداية |
| `building_rhythm` | 25–49 | Building rhythm | بناء الإيقاع |
| `finding_steadiness` | 50–74 | Finding steadiness | إيجاد الثبات |
| `growing_foundation` | 75–100 | Growing foundation | تنمية الأساس |

### 11.3 Meaning and supportive wording

| ID | One-sentence meaning | Supportive EN | Supportive AR |
|---|---|---|---|
| `gathering_footing` | Self-report suggests a heavier load right now. | Start small. One gentle step is enough. | ابدأ صغيراً. خطوة لطيفة واحدة تكفي. |
| `building_rhythm` | Some structure is forming; support will help. | Keep the path light and consistent. | اجعل المسار خفيفاً وثابتاً. |
| `finding_steadiness` | Reported steadiness is emerging. | Protect what already works. | احمِ ما ينجح بالفعل. |
| `growing_foundation` | Reported foundation feels stronger. | Maintain calm habits; avoid overconfidence. | حافظ على عادات هادئة؛ وتجنب الإفراط في الثقة. |

### 11.4 Prohibited band wording

Unhealthy/healthy brain, severe, critical, red zone, addiction diagnosis, damage, failure, shame.

### 11.5 Slice 4 plan-intensity hint (permitted)

| Band | Hint only (not diagnosis) |
|---|---|
| `gathering_footing` | Prefer shorter, fewer daily acts |
| `building_rhythm` | Standard starter intensity |
| `finding_steadiness` | Standard + optional deepen |
| `growing_foundation` | Maintenance-leaning intensity |

### 11.6 Band alone may trigger Premium or notifications?

**NO.**

---

## 12. Missing-data rules

| Case | Behavior |
|---|---|
| Missing required answer | Final score **unavailable**; no numeric 0; confidence provisional if any UI preview |
| Missing optional (future, not shown) | Omit from domain mean; do not impute 0 |
| Missing optional (shown but unanswered) | Treat as incomplete required for that shown item → unavailable |
| Partial domain with required missing | Domain invalid → overall unavailable |
| Missing-data warning | Set explanation flag `missing_required` or `optional_omitted` |

**Never** treat missing as the healthiest answer.

---

## 13. Invalid-data rules

| Case | Behavior |
|---|---|
| Out-of-range answer | Reject; score unavailable; flag `invalid_range`; **do not silent-clamp** |
| Unknown question ID / version | Reject unknown; score unavailable; flag `unknown_question` |
| Unknown domain | Ignore for weights; if required domain missing → unavailable |
| Duplicate answer for same question ID | Last write wins only if session still draft; on completed event, duplicates are invalid metadata → unavailable unless answers map is already canonical unique keys |
| Corrupt stored draft | Do not score from corrupt draft; resume/restart UX; no invisible fallback score |
| Completed session with inconsistent metadata (mode vs sectionIds) | Prefer answers + mode item bank; if unreconcileable → unavailable |
| Zero included domain weight | Unavailable (should be impossible under `weight_set_equal_v1`) |
| Legacy V1 diagnostic data | **Never convert** into Recovery Score under this contract |
| Empty answers map | Unavailable |

**Silent clamp (Slice 3 interim) is disallowed for `recovery_score_v1`.**

---

## 14. Retakes

| Rule | Behavior |
|---|---|
| New Brain Check session | New `MeasurementEvent` ID → new ProfilePack |
| Same session regenerate | Idempotent: return existing pack; do not recompute over immutable history |
| Changed answers on retake | New score/band/confidence for the new pack only |
| Prior packs | Remain immutable; never rewritten by model upgrade |

---

## 15. History / versioning

| Rule | Behavior |
|---|---|
| Historical profiles | Immutable forever |
| Model upgrade | Applies only to **newly generated** packs |
| Recalculation of old packs | Forbidden in V1 |
| `recovery_score_pending_v0` packs | Remain pending historically; do not backfill |
| Schema | Keep `brain_profile_pack_v1`; add/populate score fields for new packs under `recovery_score_v1` |
| Destructive migration | Forbidden |
| V1 BC_score / diagnostic boxes | Untouched |

---

## 16. Longitudinal comparison

Applies only when comparing **two valid** ProfilePacks with the **same** `calculationModelVersion` and comparable mode policy.

### 16.1 Distinctions

| Term | Definition |
|---|---|
| Current score | Latest valid displayed overall |
| Baseline score | First valid pack chosen by product policy (onboarding Lite recommended) |
| Absolute change | `current - baseline` (integers) |
| Domain-level change | Per-domain displayed integer deltas |
| Confidence change | Enum transition only |
| Time interval | `current.createdAt - baseline.createdAt` |
| Incomparable | Different model versions, or pending vs valid, or mode mismatch policy below |

### 16.2 Mode comparability (V1)

| Pair | Comparable for overall Δ? |
|---|---|
| Full vs Full | Yes |
| Lite vs Lite | Yes |
| Pulse vs Pulse | Yes |
| Cross-mode | **No** for overall Δ; domain titles may be shown separately without claiming overall improvement |

### 16.3 Display threshold (“too early to interpret”)

- If `|Δ_overall| < 3` **or** elapsed time `< 7 days`, UI must use **“too early to interpret”** / soft wording — do **not** claim meaningful improvement or decline.
- Do **not** claim statistical significance.
- A **single** profile never defines improvement.

Slice 4 consumes **current-profile inputs only** (§18). Weekly Review / Progress consume longitudinal rules later.

---

## 17. Explainability

Every valid generated score **must** expose (data layer and/or UI bindings):

1. Overall estimate (integer 0–100)
2. Confidence level + meaning
3. Included domain scores (integers)
4. Domain contribution (weight × domain score)
5. Stronger reported areas (top domains by score)
6. Areas needing support (lowest domains by score)
7. Missing-data warning when relevant
8. Model version (`recovery_score_v1`) and weight set id
9. Non-medical explanation (what it is / is not)
10. Why the score may change (answers, retake, coverage)

**Forbidden in visible UI:** internal evidence IDs, κ formulas, “AI said”, clinical citations theater.

**Forbidden in calculation:** AI-generated interpretation or scoring.

---

## 18. Recovery Plan input contract (Slice 4)

### 18.1 Slice 4 **may** consume

- Current valid `ProfilePack`
- Overall Recovery Score when state = valid
- Confidence
- Domain scores
- Stronger domain IDs
- Priority-support domain IDs
- User constraints already captured in Brain Check answers (as plain features, not diagnosis)
- Missing/uncertain indicators
- Profile schema + calculation model versions
- Band **only** as intensity hint (§11.5)

### 18.2 Slice 4 **must not**

- Recalculate Recovery Score with a different formula
- Override score/band/confidence using AI
- Treat a band as a diagnosis
- Generate treatment/cure claims
- Hide confidence
- Use unavailable data as zero
- Mutate completed profile history
- Convert V1 diagnostic scores into V2 Recovery Score

---

## 19. Test vectors

**Vector table version:** `recovery_score_v1_vectors`  
**Count:** 20 core vectors (implementation-ready). Implementers should expand equality checks for each mode as needed.

Notation: `Lmin` = all answers at scale minimum (after polarity → domain lows for forward items).  
Display score = half-up integer.

| # | Name | Inputs (summary) | Expected domains (concept) | Overall | Band | Confidence | Flags |
|---|---|---|---|---|---|---|---|
| 1 | All minimums Full | All Full answers = scale min | Forward items → 0; reverse items → 100 | Compute exact from formula | per result | `strong` | none |
| 2 | All maximums Full | All Full answers = scale max | Forward → 100; reverse → 0 | Exact | per result | `strong` | none |
| 3 | All midpoints Full | Likert/freq = 3; yesNo = 0 or 1 midpoint N/A → use 0 and 1 separately in suite | ~50 on 1–5 mid | Exact | per result | `strong` | none |
| 4 | Mixed-domain Full | Attention high, mood low, habits mid, intention high | Distinct domain values | Weighted equal mean | per result | `strong` | contributions differ |
| 5 | Reverse-scored | Isolate `full_q3`/`full_q6` extremes | Reverse maps invert | Exact | per result | `strong` | `reverse_applied` |
| 6 | Optional missing | N/A in V1 bank — simulate future omitted deepener | Domains unchanged | Valid if required complete | per result | `moderate` or `strong` per §10 | `optional_omitted` |
| 7 | Required missing | Omit `full_q1` | — | **unavailable** | none | `provisional` | `missing_required` |
| 8 | Invalid range | `full_q1 = 99` | — | **unavailable** | none | `provisional` | `invalid_range` |
| 9 | Unknown question version | Answer key `legacy_qX` | — | **unavailable** | none | `provisional` | `unknown_question` |
| 10 | Duplicate answer | Canonical map already unique; duplicate write in draft then complete | Same as single | Deterministic | per result | per mode | none |
| 11 | Determinism | Identical Full answers twice | Identical domains | Identical overall | identical | identical | none |
| 12 | Retake changed | Session A then Session B different answers | Different packs | Different allowed | may differ | per mode | history length 2 |
| 13 | First profile confidence Lite | Complete Lite first time | Lite domains | Valid | per result | **`moderate`** (not strong) | `first_or_short_path` |
| 14 | Full complete | All Full required answered | All 4 domains | Valid | per result | **`strong`** | none |
| 15 | Corrupt draft | Non-map draft blob | — | **unavailable** (no score from draft) | none | n/a | `corrupt_draft` |
| 16 | Historical old model | Pack with `recovery_score_pending_v0` | Preserved | Stay pending | `pendingApproval` or none | stored | `immutable_history` |
| 17 | Model mismatch compare | pending_v0 vs v1 | — | Longitudinal incomparable | — | — | `incomparable_models` |
| 18 | Band boundaries | Overall display ∈ {0,24,25,49,50,74,75,100} | — | Those values | Exact band edges | per setup | `band_boundary` |
| 19 | Band near-edges | Overall display ∈ {23,26,48,51,73,76} | — | Those values | Correct side of cut | per setup | `band_near_edge` |
| 20 | No fake decimals | Any valid | Internals may be `.5` | UI shows integer only | — | — | `display_integer_only` |

### 19.1 Closed-form anchors (Full, equal weights)

Let domain means after polarity be `A,M,H,I` in 0–100.  
`overallInternal = (A+M+H+I)/4`.

**All-forward-min / reverse-max mix:**  
If every forward item is min (0) and every reverse item is max raw (→ 0 after reverse), all domains 0 → overall **0** → band `gathering_footing`.

**All-forward-max / reverse-min mix:**  
All domains 100 → overall **100** → band `growing_foundation`.

**Lite all max forward:** both domains 100 → overall **100**, confidence **`moderate`**.

Implementers must encode exact per-question vectors in unit tests; this table is the normative checklist.

---

## 20. Prohibited uses

1. Shame, punishment, streak penalties, or alarm based on score/band  
2. Medical/neurological claims  
3. Intelligence claims  
4. Marketing as scientific brain measurement / BCI replacement  
5. Premium unlock gates based on band alone  
6. Notifications triggered by band alone  
7. AI recalculation or narrative that invents numbers  
8. Silent zero for unavailable calculation  
9. Rewriting historical packs after model change  
10. Converting V1 diagnostic scores into V2 Recovery Score without a future explicit migration contract

---

## 21. Future review conditions

Re-open this contract only when one of the following is true:

1. An approved Recovery Mathematics / Assessment authority is added to the repo with explicit weights or bands  
2. Item bank version changes (new questions/polarities)  
3. Optional deepeners ship and require weight-set revision  
4. Product Language Bible arrives with conflicting canonical labels (reconcile via superseding policy)  
5. Accessibility or emotional-safety audit requires band label changes (labels only; ranges need re-approval)

---

## 22. Superseding policy

| Artifact | Relation |
|---|---|
| `recovery_score_pending_v0` | Superseded for **new** packs by `recovery_score_v1`; historical pending packs unchanged |
| Slice 3 silent clamp + all-forward normalization | Superseded by §5 and §13 for finalization |
| Build Spec κ | Remains undefined; **not** part of Recovery Score V1; do not invent κ here |
| Unequal weights | Forbidden until a newer contract version explicitly approves them |
| Newer contract `…_V2` | Must bump model version; must not mutate V1 history |

---

## Appendix A — Product-measurement principles (frozen)

1. Self-report estimate only  
2. Not a diagnosis  
3. Not intelligence  
4. Does not prove cognitive damage or recovery  
5. No AI, network, or randomness in scoring  
6. Identical valid inputs → identical results  
7. Confidence ≠ score  
8. Progress % ≠ score  
9. Missing ≠ healthiest answer  
10. Score change explainable via domains  
11. History immutable  
12. New model never rewrites old profiles  
13. User-facing whole numbers only  
14. No fake display precision  
15. Never for shame, punishment, or alarm  

---

## Appendix B — Audit summary (Slice 3.1)

| Topic | Finding |
|---|---|
| Approved weights in Build Spec | **None** → equal weights chosen |
| Approved bands in Build Spec | **None** → four communication bands proposed |
| Reverse items in code today | **Not implemented** → required by this contract |
| Out-of-range handling in code today | Silent clamp → **disallowed** for `recovery_score_v1` |
| Confidence naming | Code `solid` ↔ contract user label `Strong` (`strong`) |
| Non-medical / anti-BCI | Aligned with Build Spec + Product Constitution |
| Arabic/English | Labels frozen bilingually in §10–§11 |

**Unresolved nonblocking debt:** ImprovementConfidence `κ` remains unspecified for Progress/Weekly surfaces; out of Recovery Score V1 scope.

---

**End of contract.**
