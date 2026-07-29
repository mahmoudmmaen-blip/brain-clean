# 11 — Analytics & Experiments Framework

**Purpose:** Measure North Star and harm — not vanity dopamine.

---

## North-Star metric

**Primary:** Daily Program completion rate (per user per local day).  

Secondary:

- Steps completed / started  
- Day End completion  
- Time to first DP step after open  

---

## Metric families

| Family | Examples |
|--------|----------|
| Activation | Onboarding complete, first DP step, first Day End |
| Retention | D1/D7/D30 open + DP start/complete |
| Completion | DP complete, Day End finish |
| Recovery | Return after missed day, Light Day usage |
| Focus sessions | Calm/focus tool starts/completes (supporting) |
| Safa | Opens, messages, blocked-by-paywall events |
| Reports | Weekly report opens, CTA clicks |
| Paywall | View, start purchase, success, cancel |
| Ads guardrails | Impression on allowed vs restricted routes |

---

## Event-naming convention (proposal)

```
namespace_object_action
```

Examples:

- `dp_program_started`  
- `dp_step_completed`  
- `dp_day_end_finished`  
- `safa_chat_sent`  
- `paywall_viewed`  
- `ad_impression` + `route` property  

**OPEN QUESTION:** Align with existing analytics implementation if any — do not invent parallel systems without audit.

---

## Privacy principles

- Collect minimum needed  
- No covert tracking narrative  
- Respect consent (UMP/ads)  
- Prefer local aggregates when possible  
- Match public Privacy Policy  

---

## Minimum viable analytics

If resources are limited, instrument only:

1. App open  
2. DP start  
3. DP complete  
4. Day End finish  
5. Paywall view/result  
6. Ad impression + route  
7. Missed-day return  

---

## A/B test template

- Hypothesis  
- Variant A/B  
- Primary metric (DP complete)  
- Guardrail metrics (ads on restricted routes, session addiction proxies)  
- Audience  
- Duration / min sample  
- Stop rules  

### Experiment stopping rules

Stop early if:

- Restricted-route ads/paywalls fire  
- Crash/error spike  
- Clear harm (shame copy complaints)  
- Primary metric strongly worse beyond threshold  

---

## Harm metrics

- Restricted-route ad impressions  
- Paywall during crisis routes  
- Drop-off after penalty/accountability  
- Excess session length without DP completion  

---

## First 10 experiments (candidates)

1. Default open → Daily Program vs Home  
2. Home declutter (DP + greeting only)  
3. Soft Pro prompt after Day 3 DP complete vs Safa expiry shock  
4. Weekly report: DP completions story vs BCI-first  
5. Missed-day Light Day auto-offer  
6. SOS 3-choice sheet vs recovery grid first  
7. Mood free during DP vs Pro gate  
8. Remove games highlight from weekly report  
9. Notification: unfinished step vs streak guilt (guilt should lose)  
10. Safa contextual entry from DP stuck state vs tab-only  

Each needs owner approval + handoff before code.
