# 07 — Feature Evaluation Scorecard

**Purpose:** Weighted 0–100 score before stage-gate finalization.

---

## Dimensions & weights

| Dimension | Weight | Notes |
|-----------|--------|-------|
| User-pain severity | 10 | Exhaustion/doomscroll relevance |
| Frequency | 5 | How often pain appears |
| North-Star contribution | 15 | Daily Program completion |
| Scientific confidence | 10 | From `03` |
| Behavior-change potential | 10 | Real-life transfer |
| Cognitive simplicity | 10 | Low load = high score |
| Emotional safety | 10 | Shame risk lowers score |
| Differentiation | 5 | Vs global competitors |
| Retention | 5 | Ethical retention |
| Revenue | 5 | Ethical monetization only |
| Implementation cost (inverse) | 5 | Higher cost → lower points |
| Maintenance cost (inverse) | 3 | |
| Privacy/policy risk (inverse) | 4 | High risk → low points |
| Global potential | 2 | |
| Arabic-market advantage | 1 | RTL/cultural fit |

Weights sum = **100**.

### Scoring each dimension (0–10)
Multiply: `(score_0_to_10 / 10) * weight`.  
Sum = total 0–100.

### Implementation/Maintenance/Privacy inverse rule
Rate “cost/risk” 0–10 where **10 = worst**.  
Points awarded = `((10 - cost) / 10) * weight`.

---

## Automatic rejection conditions

Regardless of score, REJECT if:

- Medical overclaim required to sell  
- Crisis/mood essentials paywalled  
- Ads on restricted emotional routes  
- Shame/punishment core loop  
- Cognitive training cure claims  
- Home first-screen CTA explosion without progressive disclosure  
- Policy-illegal sensitive permission without readiness  

---

## Interpretation bands

| Total | Guidance |
|-------|----------|
| 80–100 | Strong APPROVE candidate |
| 65–79 | APPROVE_WITH_GUARDRAILS / EXPERIMENT |
| 50–64 | DEFER or MERGE |
| <50 | REJECT / REMOVE unless strategic exception documented |

---

## Example evaluations (illustrative)

**Label:** INFERENCE — based on audits + docs; recalibrate with analytics when available.

### Daily Program
High North Star, behavior change, safety. **~88** → APPROVE (core).

### Day End
High emotional retention, low load. **~86** → APPROVE (core).

### Safa (contextual)
High differentiation; risk if paywall-tab. **~72** → APPROVE_WITH_GUARDRAILS (contextual, no crisis paywall).

### BCI as Home/Journey hero “scientific clarity score”
Low scientific confidence, trust risk. **~42** → REMOVE hero framing / MERGE as optional explained consistency metric.

### Brain games as cognitive enhancement
Weak transfer, marketing risk. **~35** → REJECT enhancement claims; optional micro-break only.

### Weekly report (behavior story)
Good retention if narrative. **~70** → APPROVE_WITH_GUARDRAILS (plain language, DP completions first).

### Accountability penalties (−score)
Emotional safety fail. **~28** → REJECT penalty framing / MERGE to optional reflection.

### Footer ads on free non-sensitive routes
Revenue yes; trust risk on recovery brand. **~48–55** → APPROVE_WITH_GUARDRAILS only with strict exclusions (shipping approach) — monitor harm metrics.

### Return-after-missed-day flow
High forgiveness retention, North Star. **~84** → APPROVE (build next).

---

## Scorecard template

```
Feature:
Date:
Scorer:
Scores (0-10): [list dimensions]
Total:
Auto-reject triggered?: Yes/No
Proposed status:
Guardrails:
```
