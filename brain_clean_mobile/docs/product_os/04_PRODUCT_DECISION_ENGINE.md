# 04 — Product Decision Engine

**Purpose:** Stage-gate system from idea → status. No silent shipping of research whims.

---

## Inputs required before Gate 1

- Problem statement in user language  
- Link to North Star (Daily Program)  
- Source(s) or internal observation  
- Rough UX surface (where it lives)

---

## Stage gates

### Gate 1 — Real user problem
Does a real exhausted/doomscrolling user hit this pain weekly+?  
Fail → REJECT / DEFER

### Gate 2 — Strategic fit
Does it serve Daily Program completion or clearly unblock it?  
Fail → REJECT

### Gate 3 — Scientific validity
Claims match `03` evidence rules? No medical overclaim?  
Fail → REJECT or rewrite as EXPERIMENT_ONLY without hard claims

### Gate 4 — Behavioral value
Changes real-world behavior (not only in-app taps)?  
Fail → REJECT / DEFER

### Gate 5 — Cognitive load
Adds decisions/CTAs on first open? Increases Home clutter?  
Fail → REJECT or MERGE into existing surface

### Gate 6 — Emotional safety
Shame, fear, punishment, crisis monetization?  
Fail → REJECT

### Gate 7 — Duplication
Same job as existing feature under another name?  
Fail → MERGE / REMOVE

### Gate 8 — Technical feasibility
Flutter/local-first/offline constraints; no new packages without separate approval.  
Fail → DEFER

### Gate 9 — Policy / privacy risk
Play/Apple, Usage Stats, ads placement, data safety, AI privacy.  
Fail → REJECT / APPROVE_WITH_GUARDRAILS

### Gate 10 — Retention value
Improves return & completion without addiction loops?  
Fail → DEFER

### Gate 11 — Monetization ethics
Fits `10` free-core and crisis rules?  
Fail → REJECT / rewrite

### Gate 12 — Measurement plan
North-star + harm metrics defined (`11`)?  
Fail → EXPERIMENT_ONLY blocked until metrics exist

### Gate 13 — Final decision
Owner applies status below; record in knowledge graph.

---

## Final statuses

| Status | Meaning |
|--------|---------|
| **APPROVE** | Build with handoff (`14`) |
| **APPROVE_WITH_GUARDRAILS** | Build only with listed constraints |
| **EXPERIMENT_ONLY** | Time-boxed test; no permanent IA change until results |
| **DEFER** | Valuable later; not now |
| **MERGE** | Absorb into existing feature/surface |
| **REMOVE** | Ship less — delete or hide |
| **REJECT** | Do not build; document why |

---

## Decision record (minimum fields)

- Idea name  
- Gates passed/failed (list)  
- Scorecard total (`07`)  
- Status  
- Guardrails  
- Owner  
- Date  
- Links to sources  

---

## Default bias

When uncertain between novelty and simplicity: **choose simplicity and Daily Program**.
