# 05 — UX Decision Framework

**Purpose:** Protect exhausted users from cognitive overload. Arabic RTL is a first-class constraint.

---

## Core rules

1. **One clear primary action** per screen (especially first viewport).  
2. **Progressive disclosure** — depth on demand.  
3. **Calm before complexity.**  
4. **Daily Program / Day End never compete** with secondary tools on the same first screen.  
5. **Reduce taps, thinking, and decisions.**

---

## Cognitive-load limits (PRODUCT DECISION — initial)

| Surface | Max competing CTAs (guidance) |
|---------|-------------------------------|
| First viewport after open | **1 primary** (+ optional overflow “More”) |
| Daily Program | 1 primary step action + optional secondary tool link |
| Journey | 1 hero narrative + ≤3 secondary links |
| Exercises | Grouped list; optionally 1 “Recommended now” |
| Paywall | Plans + 1 subscribe CTA + restore |

**INFERENCE:** Current Home exceeds these limits — treat as UX debt (`15`).

---

## Decision-count & tap-depth

- Daily job: target **≤3 taps** from open to primary action.  
- Prefer `go` into journey over scavenger-hunt grids.  
- Settings/language toggles should not outrank today’s step.

---

## Home vs Today

| Rule | Detail |
|------|--------|
| Ideal entry | **Today = Daily Program state** (current step) |
| Home dashboard | Must not become feature warehouse |
| Metrics | Prefer Journey/report context over Home hero clinical scores |
| Quick actions | Prefer Exercises tab; avoid duplicating full tool grid on Home |

**OPEN QUESTION:** Migrate tab label/IA to “Today” vs keep “Home” — owner decision.

---

## Navigation rules

- 5-tab shell is shipping FACT; evaluate reduction only via experiment.  
- Safa: contextual entry preferred; dedicated tab must not empty-state → paywall trap.  
- SOS/support FAB: calm, not error-red panic; route to short choices (breathe / support / resume today) preferred over dense grids.

---

## RTL & Arabic requirements

- Full RTL layout integrity (mirroring, chevrons, padding).  
- No hardcoded LTR-only assumptions in new UX specs.  
- Arabic copy: plain, non-shaming, short sentences for foggy users.  
- Fonts/readability: prefer existing product fonts; do not add packages in handoffs without approval.

Example primary CTA tone:

- EN: “Continue today’s step”  
- AR: «كمّل خطوة اليوم»

---

## Accessibility

- Min touch target ~48dp  
- Meaningful semantics/labels  
- Contrast WCAG AA where feasible  
- Dynamic type tolerance in specs  
- Don’t rely on color alone for status

---

## Emotional-state-aware UX

| State | UX response |
|-------|-------------|
| Overwhelmed | Fewer choices; Light Day |
| After missed days | Warm return; no streak shame |
| Crisis / spiral | Short path; no ads; no hard paywall |
| Success | Quiet pride; Day End closure |

---

## System states

Every major screen needs specs for:

- Loading (prefer skeleton / keep prior data)  
- Empty (one next action)  
- Error (retry + plain language)  
- Offline (local-first continuation)  
- Permission (explain benefit; optional features only)

---

## Paywall placement rules

Allowed: after clear value; More/Pro entry; end of fair trial with honest messaging.  
Restricted: mid Daily Program, Day End, SOS, relapse, active Safa support, mood completion required for free DP.

---

## Crisis / relapse route rules

- No ads  
- No accountability punishment  
- Max 3 choices  
- Always offer return to Daily Program (light mode when possible)

---

## Screen audit template

For each screen:

1. Purpose — deserve to exist?  
2. 3-second feeling  
3. Cognitive load  
4. Visual hierarchy  
5. IA fit  
6. Primary CTA  
7. Emotional impact  
8. Scientific credibility  
9. Premium value  
10. Missing opportunities  
11. Recommendations (Critical/High/Medium/Low)

---

## UX acceptance checklist

- [ ] One primary action obvious  
- [ ] Serves North Star or explicitly secondary  
- [ ] No shame copy  
- [ ] No medical overclaim  
- [ ] RTL/AR checked  
- [ ] Ads/paywall rules respected  
- [ ] Empty/error/loading defined  
- [ ] Does not duplicate another tab’s job  
- [ ] Accessibility basics met  
- [ ] Can a distracted user answer “What now?”
