# Brain Clean — Product & Research Operating System

**Status:** Initial draft  
**Created:** 2026-07-29  
**Scope:** Documentation only (no app code)  
**Authority:** Complements `docs/BRAIN_CLEAN_MASTER.md` and `brain_clean_mobile/docs/BRAIN_CLEAN_HANDOFF_2026-07-29.md` — does **not** silently override them. Conflicts are tracked in `15_OPEN_QUESTIONS_AND_CONFLICTS.md`.

---

## What this is

The **Product OS** is Brain Clean’s permanent operating system for:

- Turning research into product decisions
- Protecting the North Star (Daily Program completion)
- Rejecting dopamine-machine and shame-based features
- Keeping scientific claims honest
- Handing approved decisions to engineering safely

It is **not** a second product plan, a marketing site, or a code architecture doc.

---

## Why it exists

Brain Clean already has a strong constitution and a working app. Without a shared OS:

- Research becomes random feature ideas
- Marketing copy drifts from evidence
- Home/Journey/Safa compete with Daily Program
- Monetization can interrupt emotional recovery

This OS forces every idea through the same gates: **truth → simplicity → real behavior change**.

---

## Document map

| File | Purpose |
|------|---------|
| `00_README.md` | Map, hierarchy, how to use |
| `01_PRODUCT_CONSTITUTION.md` | Non-negotiable product law |
| `02_RESEARCH_ENGINE.md` | Source → decision pipeline |
| `03_SCIENTIFIC_EVIDENCE_FRAMEWORK.md` | Evidence & claim rules |
| `04_PRODUCT_DECISION_ENGINE.md` | Stage gates & statuses |
| `05_UX_DECISION_FRAMEWORK.md` | UX / cognitive-load rules |
| `06_BEHAVIOR_CHANGE_FRAMEWORK.md` | Habit & forgiveness science |
| `07_FEATURE_EVALUATION_SCORECARD.md` | Weighted scoring |
| `08_AI_COACH_SAFA_FRAMEWORK.md` | Safa boundaries |
| `09_RETENTION_AND_FORGIVENESS_FRAMEWORK.md` | Ethical retention |
| `10_MONETIZATION_ETHICS_FRAMEWORK.md` | Free / Pro / ads ethics |
| `11_ANALYTICS_AND_EXPERIMENTS_FRAMEWORK.md` | Metrics & A/B rules |
| `12_SOURCE_ANALYSIS_TEMPLATE.md` | Reusable research template |
| `13_KNOWLEDGE_GRAPH_SCHEMA.md` | Doc-level knowledge model |
| `14_IMPLEMENTATION_HANDOFF_TEMPLATE.md` | Product → Flutter handoff |
| `15_OPEN_QUESTIONS_AND_CONFLICTS.md` | Living conflict register |

---

## Decision hierarchy

When documents disagree, apply this order:

1. **User safety & emotional safety** (no shame, no crisis monetization)
2. **Policy / privacy / store compliance** (Google Play, Apple, privacy)
3. **North Star** — Complete today’s Daily Program
4. **Product Constitution** (`01_…`) over feature docs
5. **Scientific Evidence Framework** (`03_…`) over marketing claims
6. **Current handoff / release branch facts** over stale master version numbers
7. **Master constitution intent** over opportunistic feature ideas
8. **Open Questions** until Product Owner decides

**Label:** PRODUCT DECISION — hierarchy above is initial OS policy and requires owner ratification if conflicted with shipping reality.

---

## Research → approved decision flow

```
Source intake
  → Claim extraction (FACT vs claim)
  → Evidence verification (03)
  → Concept clustering
  → Behavior / cognition / emotion mechanisms (06)
  → Scorecard (07)
  → Stage gates (04)
  → Status: APPROVE | APPROVE_WITH_GUARDRAILS | EXPERIMENT_ONLY | DEFER | MERGE | REMOVE | REJECT
  → If APPROVE*: Implementation Handoff (14)
  → Knowledge graph entry (13)
  → Analytics / experiment plan (11)
```

Use analysis modes defined in `02_RESEARCH_ENGINE.md`:

- `QUICK_SCAN`
- `FULL_ANALYSIS`
- `BUILD_BACKLOG`
- `EXPERIMENT_DESIGN`
- `SCIENTIFIC_REVIEW`
- `COMPETITOR_SCAN`

---

## How contributors should use these files

| Role | Start here | Then |
|------|------------|------|
| Product Owner | `01`, `15` | Decide conflicts |
| Research / CRO | `02`, `03`, `12` | Fill template per source |
| UX | `05`, `09` | Audit screens against checklist |
| Monetization | `10` | Check ads/paywall placement |
| Engineering | `14` only after APPROVE* | Do not invent scope |
| Marketing / ASO | `03` claim rules + `15` conflicts | Never invent clinical claims |

**Rules:**

1. Do not implement from a lecture summary alone.
2. Do not add features that fail Gate 2 (strategic fit) or Gate 5 (cognitive load).
3. Do not treat old docs as automatically correct — check `15`.
4. Do not fabricate citations. Write: **Evidence verification required.**

---

## Versioning rules

- Each material change to Product OS files should note date + short reason at top or in changelog section of the edited file.
- Product OS versioning is independent of app `versionName` / `versionCode`.
- Shipping code truth for release is the **handoff + branch**; Product OS may be ahead of shipped UI.

---

## Epistemic labels (required)

Every non-trivial statement in Product OS work must be tagged:

| Label | Meaning |
|-------|---------|
| **FACT** | Observed in code, docs, store, or measured analytics |
| **INFERENCE** | Reasonable conclusion from facts; may be wrong |
| **HYPOTHESIS** | Testable assumption; needs experiment |
| **PRODUCT DECISION** | Chosen rule for Brain Clean (owner-owned) |
| **OPEN QUESTION** | Missing information; do not invent |

Difference summary:

- **Factual evidence** = measured / cited / inspected artifact  
- **Inference** = interpretation of evidence  
- **Hypothesis** = proposed causal claim for testing  
- **Product opinion** = preference or brand choice (must still pass constitution)

---

## Related project docs (inputs, not automatic truth)

| Path | Role |
|------|------|
| `docs/BRAIN_CLEAN_MASTER.md` | Historical master constitution + technical SOP |
| `brain_clean_mobile/docs/BRAIN_CLEAN_HANDOFF_2026-07-29.md` | Current release/ops handoff (v1.2.x) |
| `brain_clean_mobile/PRIVACY_POLICY.md` | Public privacy policy |
| `brain_clean_mobile/store_metadata.md` | Store copy (may conflict with science rules) |

---

## First document to use

1. Read `01_PRODUCT_CONSTITUTION.md`
2. Read `15_OPEN_QUESTIONS_AND_CONFLICTS.md`
3. Then run research through `02` + `12`

**Next recommended step:** Product Owner resolves Priority conflicts in `15` (Home vs Today, BCI marketing, ads vs recovery trust, Safa tab vs contextual coach).
