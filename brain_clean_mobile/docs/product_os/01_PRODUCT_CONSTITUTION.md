# 01 — Product Constitution

**Status:** Initial Product OS constitution  
**Labels:** PRODUCT DECISION unless marked otherwise  
**Inputs:** Master constitution, handoff 2026-07-29, product audits, authoritative task context

---

## Mission

Help people **recover intentional attention**, reduce digital overstimulation, rebuild focus and executive steadiness, and create a calmer daily rhythm — without becoming another dopamine machine.

**FACT (positioning):** App is digital wellbeing / daily recovery companion — **not** medical diagnosis or treatment.  
**PRODUCT DECISION:** No medical claims in product, marketing, or AI output.

---

## Product promise

Brain Clean helps the user complete a **calm, intentional Daily Program** and close the day with dignity.

Supporting tools exist only to make that journey easier, safer, or clearer.

---

## North Star

> **Complete today’s Daily Program.**

Secondary metrics (streaks, reports, Safa usage, Pro conversion) are subordinate.  
If a feature increases engagement but reduces Daily Program completion, it fails.

---

## Target user state

Primary audience experiences some mix of:

- Mental exhaustion  
- Compulsive scrolling / doomscrolling  
- Brain fog / reduced attention tolerance  
- Low motivation / executive-function difficulty  
- Mild anxiety / heavy phone use  

**Design implication:** Every extra decision, tap, or competing CTA loses users.

**Languages:** Arabic-first (RTL quality is strategic). English/global readiness required.

---

## Emotional journey (per session)

**PRODUCT DECISION** — protect this arc; do not interrupt with ads, shame, or paywalls:

```
Confusion → Hope → Focus → Progress → Trust → Reflection → Quiet pride → Closure
```

Arabic framing (from master intent):  
حيرة → أمل → تركيز → تقدّم → ثقة → تأمّل → فخر هادئ → إغلاق

---

## Product boundaries

### In scope
- Daily Program + Day End  
- Support tools that reduce friction for the journey (calm, focus, optional journal)  
- Contextual coaching (Safa)  
- Journey/reports that **explain** behavior change  
- Ethical monetization (peace, depth, backup, personalization)

### Out of scope
- Medical diagnosis, treatment, or cure claims  
- Addiction-style feeds, infinite novelty, casino rewards  
- Features that exist only because competitors have them  
- Invented clinical-looking brain scores marketed as scientific truth  
- Aggressive paywalls on mood/crisis routes

---

## Never-build list

1. Social/content feed  
2. Large brain-training game suite sold as intelligence improvement  
3. Nagging / shaming notifications  
4. Medical/treatment claims  
5. Full app blockers as v1 complexity (**OPEN QUESTION:** whether later friction tools are allowed — see `15`)  
6. Duplicate systems for the same user job  
7. Unexplained vanity metrics  
8. Trend features that ignore North Star  
9. Daily jobs requiring >3 taps when avoidable  
10. Content that conflicts with product identity / recovery safety  
11. Documentation that replaces shipping (docs serve decisions)  
12. Full rewrite of a working product without staged migration  

---

## Free vs Pro ethical boundaries

| Must remain free | May be Pro |
|------------------|------------|
| Daily Program core journey | Deeper insights / advanced reports |
| Day End closure | Cloud backup (when enabled) |
| Crisis / SOS / relapse-safe routes | Unlimited / deeper Safa modes (**guardrails required**) |
| Basic mood check during Daily Program | Extra themes / premium polish |
| Essential calm tools needed to complete today’s steps | Remove ads |

**PRODUCT DECISION:** Monetize **peace and depth**, not distress.  
**PRODUCT DECISION:** Free users must receive a genuinely useful recovery experience.

**OPEN QUESTION:** Exact free vs Pro matrix for Safa, games, and Journey charts in shipping build — verify against code/RevenueCat offerings before marketing updates.

---

## Domain rules

### Daily Program + Day End
- Core product.  
- One current step; map below is orientation, not a second dashboard.  
- Completion = conscious participation, not perfection.  
- Adaptive day types (light / normal / deep / recovery) are desired; shipping visibility is **OPEN QUESTION**.

### Home / Today
- **PRODUCT DECISION (strategic):** Entry should answer “What should I do now?” with Daily Program.  
- **FACT (shipping):** Navigation still includes a Home tab with multiple cards/metrics (cognitive overload risk).  
- Competing CTAs on first screen are a constitution violation.

### Safa
- Coach/assistant — supports, does not replace user agency.  
- Strongest **in context** (mood, relapse, stuck step).  
- Must not become bait-and-switch paywall theater.  
- **CONFLICT:** Master says contextual, not isolated tab; shipping has a Safa tab — see `15`.

### Journey
- Explains change; does not drive today’s action.  
- Metrics must answer: *why?* and *what next?*  
- No clinical presentation of BCI.

### Recovery / SOS / Detox / Accountability
- Support after difficult days.  
- No shame language; no “you lost everything.”  
- **CONFLICT:** Multiple overlapping systems — see `15`.  
- Accountability **penalties that punish scores** are rejected unless reframed as optional reflection.

### Exercises / Focus tools
- Patient tools “when needed.”  
- Must not compete with Daily Program entry.  
- Prefer calm/focus tools with clearer real-life transfer over game suites.

### Reports
- Plain-language progress stories preferred over chart theater.  
- Highlight Daily Program completions and real behaviors.  
- Do not center “best game” as identity.

### Games / Brain Gym
- Optional micro-breaks only.  
- **Never** claim improved IQ, cured brain fog, or clinical cognitive enhancement.  
- Prefer honest framing: pause / interrupt impulse — not “brain training.”

### Ads
- **PRODUCT DECISION:** Ads must not interrupt Daily Program, Day End, SOS/relapse, emotional flows, or Safa conversations.  
- **FACT (handoff):** Banner-only on selected free routes with exclusions.  
- Ads on a recovery product remain a **trust risk** even when technically constrained.

### Notifications
- Few, controllable, non-judgmental.  
- Re-engage with forgiveness, not guilt.

---

## Feature rejection criteria (automatic)

Reject if any is true:

1. Does not serve Daily Program or clearly improve the day’s journey  
2. Increases cognitive load on first open  
3. Creates shame, fear, or addiction loops  
4. Requires medical/clinical claims to sell  
5. Duplicates an existing user job  
6. Paywalls crisis/mood essentials  
7. Conflicts with Play/privacy policy  
8. Markets weak-transfer games as cognitive cure  
9. Presents invented scores as medical truth  

---

## Conflict-resolution hierarchy

1. Emotional safety & crisis integrity  
2. Store/privacy compliance  
3. North Star (Daily Program completion)  
4. This Constitution  
5. Scientific Evidence Framework (`03`)  
6. Current release handoff facts  
7. Master doc intent (may be stale on version/features)  
8. Product Owner decision recorded in `15`

---

## Success definition

A successful session ends with the user **closing the app and living life** — not maximizing session length.
