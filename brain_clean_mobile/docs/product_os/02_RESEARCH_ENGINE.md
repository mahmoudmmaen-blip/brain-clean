# 02 — Research Engine

**Purpose:** Repeatable pipeline from any source → Brain Clean product decision.  
**Never:** Summarize-only. **Always:** Layered competitive product intelligence.

---

## Supported source types

| Type | Examples |
|------|----------|
| Lectures | YouTube, conference talks |
| Scientific papers | Journals, preprints (label confidence carefully) |
| Books | Chapters relevant to attention/habits |
| Podcasts | Expert interviews |
| Articles | Journalism, explainers |
| Competitor reviews | Opal, One Sec, Forest, Headspace, Freedom, Screen Time, etc. |
| User interviews | Moderated / unmoderated |
| App-store reviews | Play / App Store |
| Internal analytics | Product events (privacy-respecting) |

---

## Pipeline (mandatory layers)

### 1) Source intake
Capture: type, title, author/speaker, date, URL, transcript/summary, constraints, target topic.

### 2) Claim extraction
List discrete claims. Tag each: **FACT / CLAIM / OPINION / MARKETING**.

### 3) Concept clustering
Group related claims into concepts (e.g., “attention residue”, “implementation intentions”).

### 4) Evidence verification
Apply `03_SCIENTIFIC_EVIDENCE_FRAMEWORK.md`.  
If citation missing: **Evidence verification required.**

### 5) Behavioral mechanism
What action tendency does this change? (prompt, friction, reward, identity…)

### 6) Cognitive mechanism
Attention, working memory, executive function, load — without clinical overclaim.

### 7) Emotional mechanism
Calm, hope, shame risk, self-efficacy.

### 8) User-pain mapping
Map to exhausted / doomscrolling / fog / executive difficulty.

### 9) Product opportunity
Features that serve **Daily Program completion** first.

### 10) UX opportunity
Fewer taps, clearer hierarchy, emotional safety.

### 11) Monetization opportunity
Only ethical paths per `10_MONETIZATION_ETHICS_FRAMEWORK.md`.

### 12) Risks
Anxiety, addiction, policy, duplication, weak science, overload.

### 13) Decision
Run `04_PRODUCT_DECISION_ENGINE.md` gates → status.

### 14) Knowledge-base storage
Record via `13_KNOWLEDGE_GRAPH_SCHEMA.md` (documentation-level).

---

## Analysis modes (commands / labels)

### `QUICK_SCAN`
- Layers 1–3 + top risks + reject list  
- Output: 5 opportunities max  
- Use for triage

### `FULL_ANALYSIS`
- All layers + full concept cards + final verdict sections  
- Use for lectures/papers that may change product direction

### `BUILD_BACKLOG`
- Convert APPROVE* / EXPERIMENT_ONLY into prioritized backlog  
- Requires scorecard (`07`) scores

### `EXPERIMENT_DESIGN`
- Hypothesis, metrics, sample, stop rules (`11`)  
- Guardrails for harm metrics

### `SCIENTIFIC_REVIEW`
- Evidence hierarchy focus only  
- Produce claim table + allowed copy language (`03`)

### `COMPETITOR_SCAN`
- Competitor jobs-to-be-done vs Brain Clean North Star  
- Steal mechanisms, not features; reject dopamine patterns

---

## Required output skeleton (FULL_ANALYSIS)

1. Executive Summary  
2. Scientific Insights  
3. Product Insights  
4. UX Insights  
5. Behavior Insights  
6. Feature Backlog candidates  
7. Quick Wins  
8. Long-term Ideas  
9. Implementation Roadmap (product-level)  
10. Top 10 Opportunities  
11. Top 10 Risks  
12. Top 10 Experiments  
13. Action Checklist  
14. Final Verdict  

Plus per major idea scores (1–10): scientific evidence, business value, retention, engagement, ease, global potential.

---

## Rejection filter (apply during extraction)

Discard / mark REJECT early if idea:

- Increases anxiety or shame  
- Encourages addiction / infinite scroll patterns  
- Has weak science sold as strong  
- Conflicts with Play/Apple/privacy  
- Increases cognitive overload  
- Duplicates existing Brain Clean jobs  
- Competes with Daily Program on first open  

---

## Storage convention (docs)

Until a database exists:

```
brain_clean_mobile/docs/product_os/research_logs/
  YYYY-MM-DD_<short-slug>.md   # filled from 12_SOURCE_ANALYSIS_TEMPLATE.md
```

**OPEN QUESTION:** Whether `research_logs/` should be created now. Not created in this initial OS drop unless requested.

---

## Quality bar

- Optimize for truth, simplicity, real behavior change — never novelty.  
- Prefer Daily Program integration over new tabs.  
- Prefer forgiveness retention over streak punishment.
