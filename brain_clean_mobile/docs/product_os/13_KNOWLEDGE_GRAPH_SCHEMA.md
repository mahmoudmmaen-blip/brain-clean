# 13 — Knowledge Graph Schema (Documentation-Level)

**Purpose:** Traceability from source → decision without building a database.  
**Implementation:** Markdown / tables / future JSON optional. **No code in this OS drop.**

---

## Entities

| Entity | Definition | Key fields |
|--------|------------|------------|
| **Source** | Lecture, paper, review, interview, analytics note | id, type, title, author, date, url, credibility |
| **Claim** | Atomic assertion from a source | id, source_id, text, claim_type, evidence_tier, confidence |
| **Concept** | Clustered idea | id, name, definition, aliases |
| **Evidence** | Assessment of support | id, claim_id, tier, confidence, notes, verification_status |
| **UserPain** | User problem | id, name, severity, frequency |
| **BehaviorMechanism** | How behavior changes | id, name, model_tags (COM-B/Fogg/etc.) |
| **Feature** | Product capability | id, name, surfaces, free_pro, status |
| **Screen** | UI surface | id, route_or_name, primary_cta |
| **DailyProgramStep** | Step in journey | id, step_key, required_optional |
| **SafaResponse** | Coaching pattern | id, mode, language, safety_tags |
| **Metric** | Analytics metric | id, name, type (north_star/guardrail/etc.) |
| **Experiment** | A/B or pilot | id, hypothesis, status |
| **Risk** | Harm/policy risk | id, category, severity |
| **Decision** | Gate outcome | id, status, date, owner, guardrails |

---

## Relationships

| Relationship | From → To | Meaning |
|--------------|-----------|---------|
| `EXTRACTS` | Source → Claim | Source contains claim |
| `INSTANTIATES` | Claim → Concept | Claim about concept |
| `SUPPORTED_BY` | Claim → Evidence | Evidence assessment |
| `ADDRESSES` | Feature → UserPain | Feature targets pain |
| `USES_MECHANISM` | Feature → BehaviorMechanism | Mechanism employed |
| `APPEARS_ON` | Feature → Screen | UI placement |
| `INTEGRATES_STEP` | Feature → DailyProgramStep | DP integration |
| `COACHES_WITH` | Feature → SafaResponse | Safa patterns |
| `MEASURED_BY` | Feature/Experiment → Metric | Measurement |
| `TESTS` | Experiment → Feature/Decision | Experiment scope |
| `HAS_RISK` | Feature/Decision → Risk | Risk link |
| `DECIDES` | Decision → Feature | Outcome |
| `CONTRADICTS` | Claim/Decision → Claim/Decision | Conflict |
| `DUPLICATES` | Feature → Feature | Same job |

---

## Required metadata (all entities)

- `id` (stable string)  
- `created_at`  
- `updated_at`  
- `labels` (FACT/INFERENCE/HYPOTHESIS/PRODUCT_DECISION/OPEN_QUESTION)  
- `confidence` (0–100) where applicable  
- `status` (active/deprecated/rejected)

---

## Confidence & traceability

- Every Feature that asserts science must link to Claim + Evidence.  
- Every Decision must link to Feature + failed/passed gates summary.  
- Marketing copy proposals must link to Evidence.verification_status = `verified` or `softened`.

---

## Duplicate detection

Before adding Feature:

1. Search same UserPain  
2. Search same BehaviorMechanism  
3. If overlap → propose MERGE  

---

## Contradiction handling

1. Create `CONTRADICTS` link  
2. Add entry in `15_OPEN_QUESTIONS_AND_CONFLICTS.md`  
3. Do not ship both sides as truth  
4. Owner resolves Decision  

---

## Example records (illustrative)

**Source**  
`src_master_constitution` — docs/BRAIN_CLEAN_MASTER.md — credibility Medium (mixed product+tech; version may be stale)

**Claim**  
`cl_bci_invented` — “BCI is an internal motivational index, not a medical measure.” — FACT (doc intent)

**Feature**  
`ft_bci_hero` — BCI hero on Journey/Home — status: under review / trust risk

**Decision**  
`dec_bci_reframe` — status APPROVE_WITH_GUARDRAILS (candidate) — reframe as consistency; no clinical copy — **needs owner approval**

**Risk**  
`rk_scientific_trust` — category science/marketing — severity High
