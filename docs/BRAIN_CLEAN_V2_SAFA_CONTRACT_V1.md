# Brain Clean V2 — Safa Contract V1

**Document ID:** `BRAIN_CLEAN_V2_SAFA_CONTRACT_V1`  
**File:** `docs/BRAIN_CLEAN_V2_SAFA_CONTRACT_V1.md`  
**Status:** APPROVED FOR IMPLEMENTATION GOVERNANCE — CONTRACT FREEZE  
**Slice:** 9.3A (contract only; no Safa production implementation in this slice)  
**Date:** 2026-08-03  
**Role:** Safa Governance and Safety Board  

---

## 1. Status and authority

### 1.1 Binding authorities (tracked)

| Authority | Role |
|---|---|
| `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md` | Primary V2 scope; catalog ID `SAF-01`; Safa ≠ tab; G2 ads ban; deep link `safa` |
| `docs/BRAIN_CLEAN_V2_PREMIUM_CONTRACT_V1.md` | Free safety core; no Premium-only crisis; Support capital deferred to this contract |
| `docs/BRAIN_CLEAN_V2_RECOVERY_PLAN_CONTRACT_V1.md` | Safa must not silently mutate Plan |
| `docs/BRAIN_CLEAN_V2_RECOVERY_SCORE_CONTRACT_V1.md` | Safa must not calculate or alter Score |
| `docs/BRAIN_CLEAN_V2_WEEKLY_REVIEW_CONTRACT_V1.md` | No automatic Review payload to AI |
| `docs/BRAIN_CLEAN_MASTER.md` | Existing Edge Function `safa-chat`; Claude secret server-side only |
| `lib/core/services/claude_ai_service.dart` | Existing Edge transport (message-only body today) |
| Four-tab shell contract | Today · Plan · Progress · Profile — Safa never a tab |

### 1.2 Requested / missing authorities

| Authority | Status |
|---|---|
| Dedicated Safa / Assessment Bible | **Absent** |
| Product Language Bible | **Absent** |
| Formal SOS product screen ID in Build Spec | **Absent** (escalation frozen via explicit user path + approved destinations) |
| Premium Bible (Safa depth detail) | **Absent** — Premium Contract §15 + this document freeze Free core |

**Policy:** Do not invent clinical classifiers, hotline numbers, or Premium monetization depth. Where absent, freeze conservative product-safety conventions.

### 1.3 Precedence

1. This Safa Contract freezes **V2 Safa V1** behavior.  
2. Build Spec owns the single screen ID **`SAF-01`**.  
3. Premium Contract Free-safety bans cannot be weakened.  
4. Legacy Emotion Oasis / unlimited chat is **not** approved V2 Safa behavior.  
5. Existing Edge architecture (`safa-chat` + server-side Claude) is preserved — not redesigned here.

### 1.4 Implementation posture for Slice 9.3A

This document is **decision and contract freeze only**. It does **not** authorize:

- Safa production UI/controller implementation  
- Changes to Claude / Supabase Edge / secrets  
- Premium depth implementation  
- Ads, RevenueCat, Score, Plan, Session, Reports, or shell changes  

---

## 2. Purpose

**Canonical name:** Safa · **Arabic:** صفا  

Safa provides short, contextual support when a user needs help continuing, understanding a difficult moment, or choosing a safe next action.

Safa may help the user:

1. Slow down  
2. Name the current difficulty  
3. Choose one bounded next step  
4. Return to Today, Plan, Progress, or an approved support destination  
5. Understand that uncertainty or interruption is normal  

**Required emotional outcome:** Calm support without intimacy theater.  
**Required leave outcome:** Easy exit with origin preserved.

---

## 3. Product boundary

### 3.1 Safa does not

- Diagnose or treat  
- Provide medical advice  
- Replace professional care or emergency services  
- Calculate Recovery Score  
- Rewrite Brain Profile  
- Change Recovery Plan automatically  
- Classify setbacks  
- Interpret private history without explicit, per-request approval  
- Promise recovery outcomes  
- Handle emergencies as a substitute for local emergency services  
- Become an unlimited chatbot dependency loop  
- Act as a Premium-only safety gate  
- Serve ads or Premium upsells inside the Safa experience  

### 3.2 Safa is

- Contextual  
- Calm  
- Bounded  
- Non-medical  
- Non-diagnostic  
- Safety-aware  
- Local-first where possible  
- Transparent about AI / network availability  
- Useful without Premium  
- Optional  
- Easy to leave  
- Honest about limitations  

---

## 4. Screen IDs / states

### 4.1 Frozen screen ID (Build Spec)

| ID | Name | Role |
|---|---|---|
| **SAF-01** | Contextual Safa Support | Sole V2 Safa product surface |

Build Spec catalogs **only** `SAF-01`. This contract does **not** invent new Build Spec screen IDs.

### 4.2 Subsurfaces (not new catalog IDs)

| Subsurface | Role | Presentation |
|---|---|---|
| **SAF-02 (state)** | Unavailable / Safe Fallback | State of SAF-01 (`local_fallback`, `offline`, `service_unavailable`, …) |
| **SAF-03 (state / sheet)** | Privacy and Data Boundary | Pre-send consent / privacy notice within SAF-01 (`privacy_notice`, `consent_required`) |

Routes may expose these as query-driven views of SAF-01 (see §15) without claiming new PRE-style IDs in the Build Spec catalog.

### 4.3 SAF-01 content requirements

Must include:

- Context explanation (why Safa opened; origin-aware)  
- Optional bounded support prompt / composer  
- Short response region  
- One suggested next action  
- Exit / return to origin  
- Clear AI / limitation notice  
- No infinite-feed design  

### 4.4 Exact UI states

| State | Meaning |
|---|---|
| `idle` | Opened; waiting for consent or input |
| `privacy_notice` | Disclosing AI/network use |
| `consent_required` | Explicit send consent pending |
| `ready` | May compose / send |
| `sending` | Network request in flight |
| `response_ready` | Valid structured or bounded text response shown |
| `local_fallback` | Deterministic offline / non-AI support |
| `offline` | No network |
| `timeout` | Request timed out |
| `service_unavailable` | Edge / Claude unavailable |
| `invalid_response` | Response failed validation |
| `input_too_long` | User text exceeds bound |
| `bounded_session_complete` | Turn cap reached |
| `safety_redirect` | Escalation to approved urgent path |
| `user_cancelled` | User cancelled send / closed |
| `cleared` | Active session cleared |

Every state requires: honest localized message · one safe action · no blame · no Premium pressure · no ads · no infinite retry loop · no avoidable data loss.

---

## 5. Contextual entry

### 5.1 Allowed entry (explicit user request only)

| Origin | Allowed when |
|---|---|
| Today (HOM-01) | User explicitly requests help |
| Daily Session (SES-*) | User explicitly requests clarification / support |
| Recovery Plan (PLN-01) | User explicitly asks for help understanding a step |
| Progress (PRG-01) | User explicitly asks for help with limited evidence wording |
| Weekly Summary / Artifact leave | User explicitly asks for support continuing |
| Profile (PRF-01) | Explicit Safa entry control |
| Approved difficult-moment / help control | Only if a V2 product control already exists |

Build Spec deep link: `safa` → SAF-01 **only with valid context**; else HOM-01.

Build Spec dependency note (“Session or Plan context required”) is interpreted for **auto/deep link** opens. Explicit Profile / Today help entries are allowed when the user opts in and a minimal origin context ID is attached.

### 5.2 Forbidden automatic entry

- App launch  
- Onboarding  
- Before Brain Check  
- During Profile / Score reveal animation  
- Immediately after setback classification  
- During Premium purchase / restore  
- During SOS as the only path (Safa may be secondary only if later approved)  
- Based solely on Recovery Score band  
- Based on Premium status  
- Based on missing days or low streak  

### 5.3 Shell rule

**Safa must never be a tab.** Four-tab shell remains Today · Plan · Progress · Profile.

---

## 6. Session boundary

### 6.1 Frozen V1 interaction model

| Rule | Value |
|---|---|
| Session type | One contextual support session |
| Max user messages | **3** |
| Max assistant responses | **3** |
| After bound | Offer: try suggested action · return to origin · urgent help (explicit) · start later |
| Infinite chat | **Forbidden** |
| Companion / pet mechanics | **Forbidden** |
| Dependency language | **Forbidden** |
| Easy exit | Always visible; returns to origin |

This bound is a **product-safety convention**, not a clinical rule.

Build Spec: “max bounded turns then force Back” → satisfied by §6.1 + forced return CTA at `bounded_session_complete`.

---

## 7. Input contract

### 7.1 Allowed inputs

| Input | Notes |
|---|---|
| Explicit user text | Typed into SAF-01 composer |
| User-selected contextual category | Optional chip; never pre-selected sensitive |
| Origin screen ID | Categorical (`today`, `session`, `plan`, …) |
| Language / locale | From app locale |
| User-approved short context summary | Explicitly confirmed before send |
| User-approved Plan step title | Optional, explicit |
| User-approved current Session step label | Optional, explicit |

### 7.2 Never automatically send

- Raw Brain Check answers  
- Full Brain Profile / domain values  
- Recovery Score internals / display used as AI truth  
- Raw Daily Session reflections  
- Weekly Review responses  
- WeeklyArtifact / Reports content  
- Private notes  
- Setback history  
- Personal identifiers  
- Purchase / subscription data  
- Prior Safa conversation history (other sessions)  
- Entire local database  
- Internal evidence IDs  

### 7.3 Payload allowlist (network)

When Edge is used, body fields are **allowlisted**:

| Field | Required | Notes |
|---|---|---|
| `message` | Yes | User text only; length-bounded |
| `locale` | Yes | `ar` / `en` |
| `origin` | Yes | Categorical origin id |
| `contextCategory` | No | User-selected category enum |
| `approvedContextSummary` | No | Only if user confirmed include |
| `approvedStepTitle` | No | Only if user confirmed include |
| `sessionToken` | No | Opaque ephemeral session id — not recovery data |

Existing `ClaudeAiService` currently sends `{ message }` only. Implementation may extend **only** within this allowlist; never silent expansion.

### 7.4 Bounds

| Bound | V1 freeze |
|---|---|
| Max input characters | **500** |
| Max Edge timeout | **30s** (match existing `ClaudeAiService.timeout`) |
| Max response characters (accept) | **1200** (reject/truncate to fallback if exceeded) |

---

## 8. Consent

### 8.1 Before first network-backed request in a session

Show, in clear localized copy:

1. Safa may use an AI service over the network  
2. Only the typed message and **explicitly selected** context will be sent  
3. Safa is not medical care and not emergency services  
4. The user may continue with local fallback / without Safa  
5. The user may cancel before sending  

### 8.2 Consent rules

- Understandable; no dark patterns  
- No preselected sensitive context  
- Not tied to Premium  
- No permanent blanket consent for private history  
- Sensitive context selection is **per request**  
- A general “AI notice acknowledged” may be remembered for the app session or until cleared — **not** a license to attach history  
- Decline preserves the rest of the app  
- User can clear / revoke the active Safa session  

---

## 9. Response schema

### 9.1 `SafaResponse` (implementation-ready)

| Field | Type | Notes |
|---|---|---|
| `responseId` | string | Opaque |
| `sessionId` | string | Ephemeral session |
| `responseType` | enum | See §9.2 |
| `shortAcknowledgement` | string | Localized, short |
| `boundedSupportText` | string | Localized, short |
| `suggestedAction` | string | One action label |
| `suggestedDestination` | enum | Approved destinations only |
| `safetyQualifier` | string | Limitation / non-medical qualifier |
| `generatedAt` | timestamp | UTC |
| `serviceVersionRef` | string | Internal Edge / model ref when known |
| `networkUsed` | bool | |
| `fallbackUsed` | bool | |

### 9.2 Allowed `responseType` values

- `clarification`  
- `encouragement`  
- `grounding`  
- `step_simplification`  
- `restart_support`  
- `limited_evidence_explanation`  
- `unavailable_fallback`  
- `safety_redirect`  

### 9.3 Response requirements

Short · calm · actionable · non-medical · non-diagnostic · no certainty claims · no invented user history · no manipulation · no guilt · no dependency language · **no Premium upsell** · **no ads**.

Unstructured Edge text (`reply` string) must be **validated and bounded**; if not safely mappable → `invalid_response` → local fallback.

### 9.4 Approved `suggestedDestination` values

| Destination | Maps to |
|---|---|
| `origin` | Return to entering screen |
| `today` | HOM-01 `/v2/home` |
| `plan` | PLN-01 `/v2/plan` |
| `progress` | PRG-01 `/v2/progress` |
| `session_prepare` | SES-01 when session context exists |
| `urgent_help` | Explicit urgent-help / approved SOS surface (Free) |

No destination may mutate recovery data merely by navigating.

---

## 10. Local fallback

When AI / network is unavailable, SAF-01 **must** still provide:

1. Calm acknowledgement  
2. One approved grounding option  
3. One approved “simplify the next step” option  
4. Return to Today or Plan (or origin)  
5. Explicit urgent-help path where relevant  
6. Retry without losing the typed draft when avoidable  

Fallback properties:

- Fully localized (EN / AR)  
- Offline  
- Deterministic  
- Non-medical  
- Useful to Free users  
- Independent of Premium  
- Independent of Claude / Supabase availability  

**No blank screen. No raw exception text.**

Build Spec “Offline: Static tip card” is satisfied by this fallback pack.

---

## 11. Safety escalation

### 11.1 Audit finding

- No dedicated V2 SOS screen ID is frozen in Build Spec.  
- No approved automated high-risk NLP classifier exists in root V2.  
- Legacy Emotion Oasis does not implement escalation.  

### 11.2 Frozen V1 escalation path

1. Safa does **not** diagnose emergency status.  
2. Safa does **not** invent crisis instructions or hotspot numbers via AI.  
3. V1 escalation is **user-selected**: “I need urgent help now.”  
4. Selecting that control moves to `safety_redirect` and an **approved Free** urgent-support destination (existing product resources / static localized help — **not** AI-generated hotlines).  
5. Safety access remains Free · no Premium gate · no ads · AI continuation is **never** the only safety response.  
6. If an approved classifier is later frozen in a dedicated safety contract, it may supplement — never replace — the explicit user path.

### 11.3 Hotline / emergency copy

Must come from **approved existing product privacy/support sources** only — never from model generation.

---

## 12. Free / Premium boundary

### 12.1 Permanent Free Safa core

- Contextual Safa entry  
- Local fallback  
- Safety redirect  
- One bounded support session when the service is available  
- Clarification of current Plan / Session step (with consent)  
- Return to approved surfaces  
- Privacy disclosure  
- Urgent-help access  

### 12.2 Premium may later add (separate authorization)

Under an updated Premium / Safa depth approval only:

- Continuity across sessions (explicit user opt-in)  
- Additional non-clinical context depth  
- Longer history chosen explicitly by the user  
- More support-session availability  
- Advanced **deterministic** personalization  

### 12.3 Premium must never own

Safety · crisis redirect · first useful Safa support · local fallback · urgent support · core clarification · ability to leave Safa  

**Build Spec note** (“Generative depth Premium; Free static/capped”) is reconciled as:

- Free includes **local deterministic fallback always** + **one bounded network session when available** (so Free is not hostage).  
- Premium may deepen continuity / volume **only** under §12.2 — not core safety.

Slice **9.3 implementation must not ship Premium Safa depth** unless separately authorized.

---

## 13. Data retention

| Rule | V1 freeze |
|---|---|
| Active session | In memory during use |
| Permanent raw conversation archive | **No by default** |
| Cloud conversation archive | **No** |
| Optional local summary | Only if later explicitly authorized |
| Clear session | Always available |
| Use in Score / Profile / Plan / Reports | **Forbidden** |
| Training claims on user data | **Forbidden** |
| Analytics of conversation text | **Forbidden** |
| Error logs | Must redact user content |

### 13.1 Legacy reconciliation

`EmotionOasisScreen` keeps reply text in ephemeral widget state only (no Hive box found for Safa transcripts in root V2). V2 must not expand retention beyond §13.

---

## 14. Claude / Supabase Edge boundary

### 14.1 Preserved architecture

| Element | Freeze |
|---|---|
| Edge Function | `safa-chat` |
| Model hosting | Server-side Claude only (Master: `claude-haiku-4-5`) |
| Client secrets | **Never** store production Claude keys in app / repo / `.env` |
| Client call path | Existing Supabase Functions invoke pattern |
| NVIDIA | **Not used** |

### 14.2 Runtime rules

- Timeout bounded (30s)  
- Input / response length bounded  
- Context payload allowlisted (§7.3)  
- Network response validated  
- Unsupported / empty / HTTP error → local fallback  
- No raw internal recovery IDs to AI  
- No silent model switching from the client  
- Service / model version recorded internally when Edge returns it  
- Failures classified without logging message text (match current debug policy)

### 14.3 Non-goals of this freeze

Do not implement secrets, Edge code changes, or provider swaps in Slice 9.3A.

---

## 15. Routing

### 15.1 Contextual V2 routes (freeze)

| Route | Maps to |
|---|---|
| `/v2/safa` | SAF-01 |
| `/v2/safa?view=privacy` | SAF-03 privacy/consent subsurface |
| `/v2/safa?view=unavailable` | SAF-02 fallback subsurface |
| Optional aliases | Same handlers; no new tabs |

### 15.2 Routing rules

- Not a tab  
- Origin preserved (`origin` / `returnTo` query)  
- Exit returns to origin  
- Suggested actions use approved destinations only (§9.4)  
- Deep link without context → HOM-01 (Build Spec)  
- Feature flag OFF preserves V1  
- No app-launch routing  
- No automatic Premium route  
- No navigation that mutates recovery data  

Legacy `/emotion-oasis` remains V1/legacy — **not** the V2 Safa contract surface.

---

## 16. Copy and language

### 16.1 Canonical terms

| EN | AR |
|---|---|
| Safa | صفا |

### 16.2 Tone

Calm · respectful · clear · non-judgmental · dignified · brief · supportive **without** pretending intimacy.

### 16.3 Rejected phrases / framings

- “I’m always here for you”  
- “You need me”  
- “Tell me everything”  
- “I know exactly how you feel”  
- “Your brain is damaged”  
- “You are relapsing”  
- “You have ADHD/depression/anxiety”  
- “This will heal you”  
- “I’m your therapist”  
- “Don’t leave”  
- Romantic, parental, or dependency framing  
- Diagnostic / treatment / cure / medical certainty claims  

### 16.4 Localization

Natural Modern Standard Arabic and plain global English. No hardcoded user-visible strings in V2 UI files. RTL / LTR supported.

---

## 17. Privacy

- Disclose AI / network use before first network send  
- Terms must not claim therapist or medical service  
- No automatic history transfer  
- User can leave without losing other app functionality  
- Alignment with existing privacy destinations for disclosures  
- Onboarding network disclosure (Build Spec) remains relevant when Safa ships  

---

## 18. Analytics

| Allowed (only if approved sink exists) | Forbidden |
|---|---|
| Categorical: `safa_open` {origin}, `safa_suggestion`, `safa_back` (Build Spec) | Conversation text |
| Categorical state enums / failure kinds without message bodies | Raw prompts / replies |
| | Recovery payloads, Score, Profile, purchase data |

No new analytics network beyond existing approved sinks.

---

## 19. Accessibility

- 320 logical-pixel width  
- Text scale 2.0  
- Short-height scrolling  
- ≥48 logical-pixel targets  
- Input clearly labelled  
- Send / response / suggested action / AI notice / consent / safety redirect announced  
- No color-only state  
- Logical focus order  
- RTL / LTR  
- Reduced-motion safe  
- No typing-animation dependency  
- No focus-stealing auto-scroll  
- Keyboard-safe layout  
- Errors announced  

Build Spec animation: sheet ~200ms; honor `reduceMotion`.

---

## 20. Test vectors

Implementation-ready vectors (mutation expectation default: **no recovery-data mutation**).

| # | Name | Preconditions | Entry | Context sent | UI state | Network | Fallback | Safety | Persistence | Mutation |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Today explicit | Flag ON | Today help | origin=today | ready→… | optional | if fail | none | memory | none |
| 2 | Plan explicit | Flag ON | Plan help | origin=plan | ready→… | optional | if fail | none | memory | none |
| 3 | Progress explicit | Flag ON | Progress help | origin=progress | ready→… | optional | if fail | none | memory | none |
| 4 | Profile explicit | Flag ON | Profile help | origin=profile | ready→… | optional | if fail | none | memory | none |
| 5 | Not a tab | Shell ON | inspect tabs | n/a | 4 tabs | none | n/a | n/a | n/a | none |
| 6 | No launch | cold start | — | n/a | no Safa | none | n/a | n/a | n/a | none |
| 7 | No onboarding interrupt | onboarding | — | n/a | blocked | none | n/a | n/a | n/a | none |
| 8 | No Check interrupt | Check active | auto | n/a | blocked | none | n/a | n/a | n/a | none |
| 9 | No score-reveal interrupt | PRF reveal | auto | n/a | blocked | none | n/a | n/a | n/a | none |
| 10 | No purchase interrupt | PRE-* | auto | n/a | blocked | none | n/a | n/a | n/a | none |
| 11 | Consent before network | first send | SAF-01 | pending | consent_required | blocked until OK | local OK | n/a | memory | none |
| 12 | Consent declined | notice shown | decline | none | local_fallback / exit | none | yes | n/a | none | none |
| 13 | Text only | consented | send | message+origin | response_ready | yes | if fail | n/a | memory | none |
| 14 | Plan step context | user includes step | send | +approvedStepTitle | response_ready | yes | if fail | n/a | memory | none |
| 15 | No auto Profile | send | message only | no profile | response_ready | yes | if fail | n/a | memory | none |
| 16 | No auto Score | send | message only | no score | response_ready | yes | if fail | n/a | memory | none |
| 17 | No auto WRV | send | message only | no WRV | response_ready | yes | if fail | n/a | memory | none |
| 18 | No auto Reports | send | message only | no reports | response_ready | yes | if fail | n/a | memory | none |
| 19 | Valid response | Edge OK | send | allowlisted | response_ready | success | no | n/a | memory | none |
| 20 | Timeout | delay>30s | send | allowlisted | timeout | timeout | yes | n/a | draft kept | none |
| 21 | Offline | offline | send | — | offline | none | yes | n/a | draft kept | none |
| 22 | Unavailable | Edge 5xx | send | allowlisted | service_unavailable | fail | yes | n/a | draft kept | none |
| 23 | Invalid response | bad JSON | send | allowlisted | invalid_response | fail | yes | n/a | draft kept | none |
| 24 | Input too long | >500 chars | send | truncated reject | input_too_long | none | n/a | n/a | draft kept | none |
| 25 | Local fallback pack | offline | open | — | local_fallback | none | yes | urgent optional | memory | none |
| 26 | Retry after fallback | after fail | retry | allowlisted | sending→… | retry | if fail | n/a | memory | none |
| 27 | Bound 3 turns | 3/3 used | send | — | bounded_session_complete | blocked | n/a | n/a | memory | none |
| 28 | Exit to origin | any | exit | — | closed | none | n/a | n/a | cleared | none |
| 29 | Clear session | active | clear | — | cleared | none | n/a | n/a | wiped | none |
| 30 | No raw history persist | after exit | reopen | none | idle | none | n/a | n/a | no archive | none |
| 31 | Free core | Free user | Today help | allowlisted | useful | optional | yes | Free | memory | none |
| 32 | Premium ≠ safety | Premium | urgent | — | safety_redirect | none | n/a | Free | none | none |
| 33 | Premium ≠ fallback | Premium offline | open | — | local_fallback | none | yes | Free | memory | none |
| 34 | No upsell in reply | any | response | — | no Premium CTA | any | any | n/a | memory | none |
| 35 | No ads | any | SAF-01 | — | no ad widgets | any | any | n/a | n/a | none |
| 36–42 | No mutations | send/fail/exit | various | allowlisted | any | any | any | any | memory | **no Score/Profile/Plan/Session/Progress/WRV/Reports** |
| 43 | Urgent-help | user taps | urgent | none to AI | safety_redirect | none | n/a | explicit | none | none |
| 44 | Urgent Free | Free | urgent | — | open | none | n/a | Free | none | none |
| 45 | AI not sole safety | high concern | urgent | — | no AI-only | none | yes | yes | none | none |
| 46–49 | AR / EN / RTL / LTR | locales | SAF-01 | locale | localized | optional | localized | localized | memory | none |
| 50–51 | 320 / textScale 2 | a11y | SAF-01 | — | usable | optional | usable | usable | memory | none |
| 52 | Keyboard | composer focus | SAF-01 | — | visible CTA | n/a | n/a | n/a | n/a | none |
| 53 | Screen reader | a11y | SAF-01 | — | announced | optional | announced | announced | memory | none |
| 54 | Reduced motion | flag | open | — | no required motion | n/a | n/a | n/a | n/a | none |
| 55–58 | Copy bans | audit strings | all | — | no banned phrases | any | any | any | n/a | none |
| 59 | Flag OFF | flag false | `/v2/safa` | — | V1 preserve | none | n/a | n/a | n/a | none |
| 60 | Edge preserved | inspect | — | message allowlist | — | `safa-chat` only | — | — | — | no redesign |

---

## 21. Prohibited patterns

- Safa as primary tab  
- Unlimited chat loop  
- Therapist / diagnostic / cure framing  
- Premium-only safety  
- Ads inside Safa  
- Auto-attach Score / Profile / Review / Reports  
- Silent Plan mutation  
- AI-generated emergency numbers  
- App-launch or onboarding nags  
- Dependency / “don’t leave” language  
- Redesigning secrets or Edge without separate approval  
- Treating Emotion Oasis as V2 compliance  

---

## 22. Future Safa depth

Allowed only via new frozen authority:

- Premium continuity / session volume (§12.2)  
- Optional local summaries with explicit consent  
- Approved safety classifier supplement  
- Structured `SafaResponse` Edge schema hardening  

Not allowed without new authority:

- Medical claims  
- Companion emotional-dependency product  
- Replacing Free fallback  

---

## 23. Superseding policy

| Conflict | Winner |
|---|---|
| SAF-02/03 as new Build Spec IDs vs states | **States / subsurfaces of SAF-01** |
| Unlimited legacy chat vs bounded V1 | **This contract** |
| Build Spec Free static-only vs Free useful session | **This contract §12.1** (Free fallback always + one bounded network session when available) |
| Premium Contract §15 safety bans vs monetization | **Premium Contract bans** |
| Auto domain-gap AI inputs vs minimal consent | **This contract §7** |
| Missing SOS screen ID | Explicit urgent-help + approved Free destinations (§11) |
| Later Safa Premium depth vs Free core | Later contract may deepen; **cannot shrink Free core** |

---

## Audit appendix — contradictions and debt

| ID | Finding | Severity |
|---|---|---|
| C1 | Build Spec Premium generative depth vs Free useful network session | **Reconciled** in §12 |
| C2 | Build Spec Session/Plan context required vs Profile/Today explicit help | **Reconciled** in §5.1 |
| C3 | No Build Spec SOS ID | Nonblocking; §11 explicit path |
| C4 | Legacy Emotion Oasis unbounded + hardcoded AR strings | Nonblocking; not V2 surface |
| C5 | Missing Language / Premium Bibles | Nonblocking debt |
| C6 | Claude service body is message-only today | Expected; allowlist ready for implementation |
| C7 | Nested `brain_clean_mobile` Safa tab (Master) | Out of V2 freeze scope; V2 remains contextual |

**No Build Spec contradiction blocks this freeze:** SAF-01 remains the sole catalog ID; Safa ≠ tab; offline tip / bounded turns / Edge path preserved.

---

**End of Safa Contract V1.**
