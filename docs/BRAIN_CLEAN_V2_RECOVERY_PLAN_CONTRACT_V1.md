# Brain Clean V2 — Recovery Plan Contract V1

**Document ID:** `BRAIN_CLEAN_V2_RECOVERY_PLAN_CONTRACT_V1`  
**Status:** APPROVED FOR IMPLEMENTATION (Slice 4.1 freeze)  
**Authority class:** Product plan-generation contract  
**Branch context:** `v2/product-rebuild`  
**Frozen against HEAD:** `3f6c5169502fded291a2ddbe9faa208076d32dc5`  
**Engine version:** `recovery_plan_engine_v1`  
**Catalog version:** `recovery_practice_catalog_v1`  
**Schema / box:** `recovery_plan_pack_v1` / `recovery_plan_v1`

---

## 1. Status and authority

### 1.1 Binding order

1. This contract (plan generation, catalog, intensity, because, persistence)
2. `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md` (IDs `PLN-00`, `PLN-01`, shared `plan.today.because`)
3. `docs/BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1.md` (inputs, bands, confidence, §11.5 intensity hints, §18)
4. Implemented ProfilePack / Recovery Score V1 in `lib/features/brain_profile/`

### 1.2 Non-authority (absent from worktree)

Plan/Engine/Habit/Language/User/Emotional/Premium master bibles were requested but **not tracked**. Rules below are **V1 product heuristics**, not scientific truth, unless marked FACT from Build Spec / Score Contract.

### 1.3 Screen IDs (Build Spec)

| ID | Role |
|---|---|
| `PLN-00` | Building / generate plan |
| `PLN-01` | Plan reveal (path + Because + Today preview) |
| Shared | `plan.today.because` → HOM-01, PRF-01 Why, PLN-01, SES-01 |
| Temporary next | Today-ready boundary only (do not build Today/Session player in Slice 4) |

---

## 2. Purpose

Define how one **valid current ProfilePack** becomes one **deterministic, explainable, local-first RecoveryPlan** with:

- Limited priority-support domains
- Intensity and cadence
- Mapped recovery practices
- Minimum and standard paths
- `plan.today.because`
- Starter fallback
- Immutable history

---

## 3. Non-medical boundary

The Recovery Plan is a **product support plan**.

It is **not** medical treatment, therapy, cure, diagnosis response, or clinical rehabilitation.

**Prohibited language:** diagnosis, treatment, cure, brain damage, dopamine detox (as claim), ADHD treatment, brain-training cure, severe/clinical intensity, punishment, shame.

---

## 4. Inputs

### 4.1 Required (from Score Contract §18)

| Input | Rule |
|---|---|
| Current valid `ProfilePack` | Required |
| Valid Recovery Score (`value` 0–100, `recovery_score_v1`) | Required for normal plan |
| Score band | Intensity **hint only** |
| Confidence | May **reduce** load, never increase via shame |
| Domain scores / contributions | Priority selection |
| Stronger / support domain IDs | Support assets |
| Missing/uncertain indicators | Conservative load |
| Profile + calculation model versions | Versioning |
| Brain Check constraints | Only if captured (V1 bank has none beyond answers) |

### 4.2 Forbidden inputs

AI, network, randomness, V1 BC_score/diagnostic storage, ads, entitlement, streak loss, penalties.

### 4.3 Approved domains (implemented item bank)

| Mode | Domain IDs (canonical order) |
|---|---|
| Lite | `lite_attention`, `lite_recovery` |
| Pulse | `pulse_check` |
| Full | `full_attention`, `full_mood`, `full_habits`, `full_intention` |

Canonical order above is the **tie-break order**.

### 4.4 Score bands / confidence (Score Contract)

Bands: `gathering_footing` · `building_rhythm` · `finding_steadiness` · `growing_foundation`  
Confidence: `provisional` · `moderate` · `strong`

---

## 5. Priority selection

**Heuristic label:** V1 product heuristic (not scientific truth).

| Rule | Value |
|---|---|
| Max priority-support domains | **2** |
| Max stronger/supportive domains | **1** |
| Sort | Ascending by domain display score (lowest need first = higher support need) |
| Tie-break | Canonical domain order (§4.3) |
| Unavailable / missing domain | Exclude from priority; never treat as 0 |
| All domains within **5** display points | Select top 1 priority only (reduce personalization noise) |
| One domain ≥ **10** points below next | That domain is sole priority |
| Pulse mode | Single domain `pulse_check` is the priority when valid |
| Lite mode | Up to 2 domains per rules above |
| Full mode | Up to 2 priorities |
| Score band alone | **Never** selects priorities |
| Confidence | Does not change which domain is “worse”; may change intensity (§8) |

Stronger domain = highest valid domain score; if tie, last in canonical order among ties for “stronger” (prefer protective asset stability). Must not equal a selected priority; if conflict, pick next-highest.

---

## 6. Tie-breaking

1. Lower display score wins priority  
2. Equal scores → earlier in canonical domain order wins  
3. Stronger asset → higher score; equal → later in canonical order among the high set  
4. Practice selection ties → lexicographic ascending `practiceId`

---

## 7. Confidence handling

| Confidence | Effect |
|---|---|
| `provisional` | Prefer **LIGHT** intensity; omit optional steps; because uses low-confidence qualifier |
| `moderate` | Prefer **STANDARD** unless band is `gathering_footing` → LIGHT |
| `strong` | Allow **SUPPORTED** only when band is `gathering_footing` or two priorities; else STANDARD |

Low confidence **reduces** load. Never increases steps for “fixing.”

---

## 8. Intensity levels

Three intensities only. Avoid severe / clinical / high-risk wording.

| Internal ID | EN | AR |
|---|---|---|
| `light` | Light | خفيف |
| `standard` | Standard | قياسي |
| `supported` | Supported | مدعوم |

### 8.1 Selection (deterministic)

Evaluate in order:

1. If score unavailable / pending → **no normal plan** → starter fallback (§17)  
2. If confidence = `provisional` → `light`  
3. If band = `gathering_footing` → `light`  
4. If band = `growing_foundation` AND confidence ≠ `provisional` → `standard` (maintenance; not `supported`)  
5. If band = `finding_steadiness` OR (`building_rhythm` AND confidence = `strong`) → `standard`  
6. If two priorities AND confidence = `strong` AND band ∈ {`building_rhythm`, `finding_steadiness`} → `supported`  
7. Else → `standard`

Band hints from Score Contract §11.5 are **aligned** with this table (shorter/fewer ↔ light; standard starter ↔ standard; maintenance ↔ standard not heavier).

### 8.2 Cadence table

| Intensity | Required steps | Optional steps | Min path time | Standard path time | Total steps max | Rest day |
|---|---|---|---|---|---|---|
| `light` | 1 | 0–1 | 3–5 min | 8–12 min | 2 | Soft skip OK any day |
| `standard` | 2 | 0–1 | 5 min | 12–18 min | 3 | Soft skip OK |
| `supported` | 2 | 0–2 | 5–7 min | 15–20 min | **3** | Soft skip OK |

**Hard cap:** never exceed **20 minutes** standard path in V1.

### 8.3 User-facing meaning

| ID | Meaning | Prohibited |
|---|---|---|
| light | Small daily support while footing gathers | “You are broken”, intensive treatment |
| standard | Steady starter rhythm | Clinical severity |
| supported | Extra structure, still gentle | Punishment, medical risk |

---

## 9. Cadence

V1 uses a **repeated daily template** (same structure each day), not a 30/90-day clinical chapter.

- `dayIndex` starts at 0 on plan creation and increments locally when a day completes (Today slice owns increment; Plan stores template only)
- No automatic weekly adaptation until Weekly Review exists
- Optional steps never required for “done”
- Skip never applies penalty

---

## 10. Recovery Practice Catalog (`recovery_practice_catalog_v1`)

**Practice count:** **11** (including one starter-only practice).

Evidence class for all: **HYPOTHESIS** (product plausibility) unless noted. Not clinical FACT.

| Practice ID | EN | AR | Domains | Min path | Standard path | Dur (min) | Offline | A11y alt |
|---|---|---|---|---|---|---|---|---|
| `prac_single_task` | One-task focus setup | إعداد التركيز على مهمة واحدة | attention*, pulse | Choose 1 task; silence one distraction | 5-min single-task timer | 3–8 | Y | Voice-only choose task |
| `prac_notify_friction` | Notification friction | تقليل سحب الإشعارات | attention | Mute one noisy channel 10 min | Place phone face-down + mute 15 min | 2–5 | Y | Ask helper to mute |
| `prac_settle_breath` | Brief settle breath | تنفّس تهدئة قصير | mood, pulse, recovery | 3 slow breaths | 1-min paced breathing | 1–3 | Y | Eyes-open counting breaths |
| `prac_screen_pause` | Intentional screen pause | توقف مقصود عن الشاشة | mood, pulse, recovery | 2-min pause | 5-min pause + stand | 2–5 | Y | Audio cue only |
| `prac_offline_interval` | Planned offline interval | فترة دون اتصال | habits, recovery | 5-min offline | 10-min offline walk/room | 5–10 | Y | Stay seated offline |
| `prac_body_move` | Brief body move | حركة جسم قصيرة | habits | Stand + stretch 1 min | 3-min gentle walk | 1–5 | Y | Seated stretch |
| `prac_sleep_winddown` | Sleep wind-down prep | تهيئة النوم | habits, mood | Dim one screen 10 min before bed intent | Same + no new feeds | 3–8 | Y | Audio wind-down only |
| `prac_one_change` | Name one small change | تسمية تغيير صغير | intention, recovery | Write/speak one change | Same + when you’ll try it | 2–4 | Y | Voice memo |
| `prac_env_reset` | Environment reset | إعادة ضبط المكان | attention, habits | Clear one surface | Clear surface + water nearby | 2–5 | Y | Verbal checklist |
| `prac_awareness_check` | Awareness check-in | تفقد الوعي | attention, pulse | Notice urge 30s | Notice + choose next 1 min | 1–3 | Y | Tactile cue |
| `prac_starter_calm` | Calm start (starter) | بداية هادئة | any / fallback | 3 breaths + one kind next step | Same + 2-min pause | 2–5 | Y | Breath count only |

\*attention = `lite_attention` / `full_attention`; recovery = `lite_recovery`; mood = `full_mood`; habits = `full_habits`; intention = `full_intention`; pulse = `pulse_check`.

### 10.1 Completion / skip (all practices)

| Rule | Behavior |
|---|---|
| Completion | User marks done **or** timer ends for timed paths |
| Partial | Allowed; counts as attempt, not failure |
| Skip | Allowed; no score/XP/streak punishment in V2 plan contract |
| Safety | Stop if distress; no forced exposure |

### 10.2 Prohibited claims (catalog-wide)

Cure, detox science claims, clinical CBT, ADHD treatment, supplements, cold exposure, brain-training intelligence improvement.

---

## 11. Domain-to-practice mapping

| Domain | Primary (ordered) | Secondary | Not allowed |
|---|---|---|---|
| `lite_attention` / `full_attention` | `prac_single_task`, `prac_notify_friction` | `prac_env_reset`, `prac_awareness_check` | `prac_sleep_winddown` as sole required |
| `lite_recovery` | `prac_one_change`, `prac_screen_pause` | `prac_settle_breath`, `prac_offline_interval` | punishment deprivation |
| `pulse_check` | `prac_awareness_check`, `prac_settle_breath` | `prac_screen_pause` | long journaling |
| `full_mood` | `prac_settle_breath`, `prac_screen_pause` | `prac_sleep_winddown` | clinical mood treatment framing |
| `full_habits` | `prac_body_move`, `prac_offline_interval` | `prac_sleep_winddown`, `prac_env_reset` | supplement advice |
| `full_intention` | `prac_one_change` | `prac_single_task` | guarantee of outcome |

**Selection algorithm (deterministic):**

1. For each priority domain (order already fixed), take first unused primary practice  
2. If intensity needs a second required step, take next unused primary/secondary from remaining priorities then secondaries  
3. Optional steps: next unused secondary not already selected  
4. Stronger domain: attach as **support reason** only (does not force an extra required step); may prefer a secondary that overlaps stronger domain when choosing optionals  
5. Practice IDs sorted lexicographically when multiple candidates equal rank

Every selected step **must** list its `targetDomainId` and a because template key.

---

## 12. Daily structure

### 12.1 Objects

**RecoveryPlan** — immutable generated plan for one ProfilePack  
**RecoveryPlanDayTemplate** — repeated daily structure  
**TodayAct** — concrete day instance (built by Plan engine for preview; Today slice materializes completion)  
**RecoveryPlanStep** — one practice instance in the plan

### 12.2 TodayAct fields

| Field | Type / notes |
|---|---|
| `id` | `tact_{planId}_{dayIndex}` |
| `planId` | Parent plan |
| `dayIndex` | int ≥ 0 |
| `primaryDomainId` | First priority |
| `supportDomainId` | Stronger domain or null |
| `requiredStepIds` | 1–2 |
| `optionalStepIds` | 0–2 |
| `minimumPathStepIds` | Subset (always includes first required) |
| `standardPathStepIds` | Required + eligible optionals for intensity |
| `estimatedMinutesMin` / `Max` | From intensity table |
| `becauseKey` + resolved EN/AR | `plan.today.because` |
| `accessibilityAltKeys` | Per step |
| `completionRule` | `user_mark_or_timer` |
| `skipBehavior` | `allowed_no_penalty` |
| `version` | `recovery_plan_engine_v1` |

### 12.3 RecoveryPlanStep fields

Stable `stepId` = `step_{practiceId}_{domainId}` · practice version · purpose · durations · min/standard paths · accessibility · completion/skip · because key · optional flag · safety boundary · localization keys.

### 12.4 Structure choice

**Repeated daily template** — simplest Build-Spec-aligned path (Today preview without inventing a multi-week clinical program).

---

## 13. Minimum path

- Always includes **exactly one** required step (first required) for LIGHT; for STANDARD/SUPPORTED includes first required only when user chooses Minimum  
- Time within intensity min range  
- Still provides real value (breath / one task / one change)  
- Never empty

---

## 14. Standard path

- Includes all **required** steps for intensity  
- Includes optional steps only if intensity allows and practices remain  
- Time ≤ 20 minutes  
- No guilt copy if user stays on Minimum

---

## 15. Accessibility alternatives

Every catalog practice has an a11y alternative (§10). Plan must copy the alt text keys onto each step. Distinguish Minimum vs Standard **without color alone** (labels + icons + text).

---

## 16. `plan.today.because`

### 16.1 Templates (max ~140 chars EN / ~160 AR)

| Template ID | EN | AR |
|---|---|---|
| `because_priority` | Today focuses on {domain} because your check showed it needs gentler support. | اليوم نركز على {domain} لأن فحصك أظهر أنه يحتاج دعماً ألطف. |
| `because_priority_lowconf` | Today gently supports {domain}. This estimate is still early — keep it light. | اليوم ندعم {domain} بلطف. هذا التقدير ما زال مبكراً — اجعله خفيفاً. |
| `because_with_strength` | Today supports {domain}, while keeping {strength} as something that already helps. | اليوم ندعم {domain}، مع الإبقاء على {strength} كشيء يساعدك بالفعل. |
| `because_pulse` | A short check-in today helps you notice how focus and calm feel right now. | تفقد قصير اليوم يساعدك على ملاحظة كيف يبدو التركيز والهدوء الآن. |
| `because_starter` | A calm starter step while your personal plan finishes shaping. | خطوة بداية هادئة بينما تتشكّل خطتك الشخصية. |
| `because_fallback` | A simple practice to keep momentum without overload. | ممارسة بسيطة للحفاظ على الزخم دون إرهاق. |

Placeholders `{domain}` / `{strength}` = localized domain titles only — **never** scores or IDs.

### 16.2 Selection

1. Starter/fallback plan → `because_starter` or `because_fallback`  
2. Pulse-only → `because_pulse`  
3. Provisional confidence → `because_priority_lowconf`  
4. Else if stronger domain present → `because_with_strength`  
5. Else → `because_priority`

### 16.3 Policy

- 1–3 because lines on PLN-01 (Build Spec): line 1 = today because; optional line 2 = intensity plain sentence; optional line 3 = confidence qualifier  
- No day-to-day random variation in V1 (determinism)  
- Prohibited: medical claims, internal IDs, weights, “AI recommends”, fake certainty

---

## 17. Starter fallback

Triggers when Profile valid but: score pending/unavailable, catalog map empty, unsupported engine/catalog version, or generation error.

| Field | Value |
|---|---|
| Status | `starter_fallback` |
| Steps | Exactly `prac_starter_calm` |
| Because | `because_starter` |
| Intensity | `light` |
| Personalization claim | Must say starter / not full personalization |
| History | New plan row; never overwrite prior valid plans |
| Premium | None |

---

## 18. Free / Premium boundary

**Core plan correctness and interpretation do not depend on subscription.**

| Free | Premium (future only; not Slice 4) |
|---|---|
| Full usable current plan | Longer history, deeper copy, extra optional variants |
| Priorities + min/standard + because | Must not change priorities or score |

Premium must not improve score, hide reasons, or shame Free users.

---

## 19. Persistence

| Item | Value |
|---|---|
| Hive box | `recovery_plan_v1` |
| Schema ID | `recovery_plan_pack_v1` |
| Engine | `recovery_plan_engine_v1` |
| Catalog | `recovery_practice_catalog_v1` |
| Plan ID | `rplan_{uuid}` |
| Keys | `schema_version`, `active_plan_id`, `plan_history` (append-only list) |
| Idempotent save | Same `sourceProfilePackId` + same content hash → return existing |
| Retrieval | Latest active; by ProfilePack ID; chronological history |
| Corrupt record | Skip entry; keep others; do not invent plan |
| Unsupported version | Starter fallback for **new** generation; leave history untouched |
| Remote | None in V1 |
| V1 boxes | Untouched |
| Destructive migration | Forbidden |

Content hash inputs: profilePackId, score value/band/confidence, priority IDs, intensity, ordered practice IDs, engine+catalog versions.

---

## 20. Idempotency

Repeated generation from unchanged ProfilePack + same engine/catalog → **same plan identity** (no duplicate history rows).

---

## 21. History

Append-only. Historical plans immutable. Active pointer may move to newer plan without mutating old JSON.

---

## 22. Rebuild

| Event | Behavior |
|---|---|
| Unchanged inputs | Idempotent |
| New ProfilePack (retake) | New plan; old remains |
| Manual rebuild | Requires explicit confirm; if inputs unchanged → idempotent; if forced rebuild with same inputs → still no duplicate (return existing) |
| Invalid active | Generate new or starter; keep history |

---

## 23. Future adaptation

Weekly Review may create a **new** plan version later. **No automatic adaptation** before that system exists. Never silent rewrite of history.

---

## 24. Explainability

Every plan exposes: main focus, priorities, stronger domain, daily time, min/standard paths, why fit, today’s because, confidence, engine+catalog versions, non-medical boundary, why it may change.

No evidence IDs in UI.

---

## 25. Test vectors

**Count:** 28 normative vectors.

| # | Scenario | Priorities | Intensity | Steps (concept) | Because | Persist |
|---|---|---|---|---|---|---|
| 1 | High score + strong conf Full | 1 lowest | standard | 2 req | with_strength or priority | 1 plan |
| 2 | Mid + moderate | ≤2 | standard | 2 req | priority | 1 |
| 3 | Low + provisional | ≤2 | light | 1 req | lowconf | 1 |
| 4 | One clear low domain | that 1 | per rules | mapped | priority | 1 |
| 5 | Two clear lows | those 2 | per rules | 2 domains mapped | priority | 1 |
| 6 | Three equal lowest | first 2 in canonical order | per rules | deterministic | priority | 1 |
| 7 | All close (≤5) | 1 only | per rules | light/standard | priority | 1 |
| 8 | One unavailable domain | exclude it | — | — | — | no invent |
| 9 | Missing indicator / provisional | — | light | fewer optionals | lowconf | 1 |
| 10 | Equal tie | canonical order | — | lex practice IDs | — | stable |
| 11 | Stronger support | +1 stronger | — | support in because | with_strength | 1 |
| 12 | LIGHT | — | light | 1 req | — | — |
| 13 | STANDARD | — | standard | 2 req | — | — |
| 14 | SUPPORTED | 2 pri + strong | supported | ≤3 total | — | — |
| 15 | Minimum path | — | — | first required only | — | — |
| 16 | Standard path | — | — | all required (+opts) | — | — |
| 17 | A11y | — | — | alts present | — | — |
| 18 | Starter fallback | — | light | `prac_starter_calm` | starter | new row |
| 19 | Repeat generate | same | same | same plan id | — | no dup |
| 20 | New retake profile | may differ | — | new plan | — | history 2 |
| 21 | Unsupported version | — | — | starter | starter | no mutate old |
| 22 | Corrupt history | — | — | skip bad | — | safe |
| 23 | Free user | — | — | full core | — | — |
| 24 | Premium same inputs | identical core | identical | identical | identical | — |
| 25 | Arabic because | — | — | — | AR template | — |
| 26 | English because | — | — | — | EN template | — |
| 27 | No medical wording | — | — | — | scan copy | — |
| 28 | No AI/network/random | pure function | — | — | — | — |

---

## 26. Prohibited uses

Medical claims · AI override · Premium-gated correctness · Shame/penalties · Band-as-diagnosis · Zero-imputation · History rewrite · V1 score conversion · Catalog invention at coding time beyond this contract.

---

## 27. Future review conditions

Re-open when Habit/Engine/Plan master specs are added; catalog version bump; new domains; Weekly Review adaptation; Language Bible conflicts.

---

## 28. Superseding policy

Newer `…_V2` must bump `recovery_plan_engine_v*` and `recovery_practice_catalog_v*`. Never mutate V1 history. Starter fallback remains for unsupported versions.

---

## Appendix A — Source audit summary

| Topic | Finding |
|---|---|
| V2 domains | Lite/Pulse/Full as implemented |
| V1 detox/pomodoro/breathing screens | **Not** auto-approved as V2 catalog entries; V2 uses new `prac_*` IDs |
| Existing plan storage | None |
| Build Spec because | Shared string; 1–3 lines on PLN-01 |
| Score Contract intensity | Qualitative hints → mapped in §8 |
| Contradictions | None blocking; V1 feature surface ≠ V2 practice approval |

---

## Appendix B — Plan principles (frozen)

1–20 as in Slice 4.1 mission Part 3 (product support, deterministic, local, limited priorities, small daily load, no AI core, immutable history, no subscription interpretation, return user to life).

---

**End of contract.**
