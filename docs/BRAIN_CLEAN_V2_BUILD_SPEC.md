# Brain Clean V2 — Build Specification

**Document ID:** `BRAIN_CLEAN_V2_BUILD_SPEC`  
**File:** `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md`  
**Status:** ENGINEERING CONTRACT — BINDING  
**Date:** 2026-08-01  
**Role:** Chief Product Delivery Architect  

**Rule:** Implementation only. Nothing may be implemented outside screen/system IDs in this document.  
**Precedence:** This file beats Master Specs on conflicts of *scope*; Master Specs fill UX detail where this file is silent.  
**Language lock:** Product Language Bible (EN/AR). Tab 4 = **Profile** (not “Me”).  
**Shell tabs:** `Today | Plan | Progress | Profile`.

**Out of scope for new work (do not implement as V2 product surfaces):**  
Exercises tab · Games hub · Cognitive hub · BCI hero · XP/Achievements carnival · Dopamine Detox OS · Home warehouse quick-actions · Safa primary tab · Pro unlock paywall mid-Session · Diagnosis/anxiety-screening theater · Streak shame · Score penalties.

---

# 0A. ID catalog (complete)

| ID | Name |
|---|---|
| SYS-01 | Splash |
| SYS-02 | Biometric lock |
| NAV-SHELL | 4-tab shell |
| NAV-TODAY | Tab: Today → HOM-01 |
| NAV-PLAN | Tab: Plan → PLN-01 |
| NAV-PROGRESS | Tab: Progress → PRG-01 |
| NAV-PROFILE | Tab: Profile → PRF-01 |
| ONB-01…ONB-10 | Onboarding |
| CHK-01…CHK-04, CHK-02B, CHK-02C | Brain Check |
| PRF-01, PRF-02 | Brain Profile |
| PLN-00, PLN-01 | Recovery Plan |
| HOM-01 | Today Home |
| SES-01…SES-04 | Today's Session |
| PRG-01 | Progress |
| WRV-01 | Weekly Review |
| RPT-01, RPT-02 | Reports |
| SAF-01 | Safa contextual |
| PRE-01…PRE-03 | Premium |
| SET-01, SET-02 | Settings |
| NTF-01…NTF-03 | Notifications |
| MOD-01…MOD-03 | Maintenance / Vacation / Restart gates |

---

# 0. Global engineering rules

| ID | Rule |
|---|---|
| G1 | One purpose · one primary CTA · Screen Constitution fields satisfied |
| G2 | No ads on: Check, Session, Safa, Weekly Review, Monthly Report, Restart, Onboarding, MOD-* |
| G3 | Free core: Lite Check path, Profile basics, Plan, Today's Session, Progress four answers, first Weekly Review |
| G4 | Offline: local durable write for Check answers, Session marks, reflection; sync queue when online |
| G5 | Analytics: no PII in event props; no medical labels |
| G6 | Accessibility: ≥48dp primary controls; WCAG AA; RTL/LTR; `reduceMotion` |
| G7 | Animations default ≤300ms; honor reduceMotion |
| G8 | Errors: user-safe copy; Retry + safe Leave; never raw exceptions |
| G9 | Premium: Appreciation only post-proof; Session never gated; UI name **Premium** (entitlement may stay legacy id) |
| G10 | Regression: each screen AC must have automated or checklist tests before merge |
| G11 | V1 routes may remain behind flag until Wave 9; must not be default entry once V2 flag on |
| G12 | No destructive Hive wipe without product approval + export path |
| G13 | Preserve: package id, signing, RC restore, privacy/ads consent, RTL/LTR |

**Shared because-string:** `plan.today.because` single source → HOM-01 Action, PRF-01 Why, PLN-01 Today, SES-01.

**Required data objects (implement):** `MeasurementEvent` · `ProfilePack` · `RecoveryPlan` · `TodayAct` · `SessionMarked` · `WeeklyArtifact` · `ImprovementConfidence` · `EntitlementState`

---

# 0B. System & navigation

## SYS-01 Splash

| Field | Spec |
|---|---|
| **ID** | `SYS-01` |
| **Purpose** | Hydrate storage; route to ONB or HOM-01 |
| **Dependencies** | Hive/bootstrap |
| **Inputs** | `onboarding.completed`, biometric flag |
| **Outputs** | Nav ONB-01 or HOM-01 or SYS-02 |
| **Business Rules** | No marketing carousel; no Premium |
| **Components** | Brand splash |
| **Widgets** | None |
| **Navigation** | → SYS-02 / ONB-01 / HOM-01 |
| **Animations** | ≤300ms |
| **Accessibility** | Decorative |
| **Offline** | Full |
| **Loading** | Self |
| **Errors** | Retry hydrate → fail-safe HOM/ONB |
| **Empty State** | N/A |
| **Analytics Events** | `app_open` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Never stuck on splash > timeout with Retry |
| **Regression Tests** | Cold start with/without onboarding flag |

## SYS-02 Biometric lock

| Field | Spec |
|---|---|
| **ID** | `SYS-02` |
| **Purpose** | Gate app when biometric enabled |
| **Dependencies** | Secure settings |
| **Inputs** | unlock result |
| **Outputs** | HOM-01 |
| **Business Rules** | Skip for ONB if first run policy requires; never on PRE purchase sheet alone |
| **Components** | Lock UI, Unlock CTA |
| **Widgets** | None |
| **Navigation** | → HOM-01 |
| **Animations** | — |
| **Accessibility** | CTA labeled |
| **Offline** | Full |
| **Loading** | Auth wait |
| **Errors** | Retry / device settings |
| **Empty State** | N/A |
| **Analytics Events** | `biometric_unlock_ok|fail` |
| **Premium Behaviour** | Optional Premium feature; unlock must work if enabled |
| **Acceptance Criteria** | Failed auth never wipes data |
| **Regression Tests** | Enabled redirect; unlock to Today |

## NAV-SHELL

| Field | Spec |
|---|---|
| **ID** | `NAV-SHELL` |
| **Purpose** | Host exactly four tabs |
| **Dependencies** | onboarding.completed |
| **Inputs** | branch index |
| **Outputs** | Child screen |
| **Business Rules** | Tabs: Today, Plan, Progress, Profile only; **no** Exercises/Safa/More tabs; Safa ≠ tab |
| **Components** | NavigationBar×4, body shell |
| **Widgets** | Optional OS Session cue → HOM-01/SES-01 |
| **Navigation** | Tab switch preserves stack per tab |
| **Animations** | Platform default |
| **Accessibility** | Selected tab announced |
| **Offline** | Full |
| **Loading** | Child |
| **Errors** | Child |
| **Empty State** | Child |
| **Analytics Events** | `nav_tab` {tab} |
| **Premium Behaviour** | Banner ads only if Free and route allowed (never G2 list) |
| **Acceptance Criteria** | 4 destinations only when V2 flag on |
| **Regression Tests** | No fifth tab; sacred routes hide ads |

## NAV-TODAY / NAV-PLAN / NAV-PROGRESS / NAV-PROFILE

| Field | Spec |
|---|---|
| **ID** | `NAV-TODAY` → `HOM-01`; `NAV-PLAN` → `PLN-01`; `NAV-PROGRESS` → `PRG-01`; `NAV-PROFILE` → `PRF-01` |
| **Purpose** | Tab roots |
| **Dependencies** | NAV-SHELL |
| **Inputs** | — |
| **Outputs** | Root screen |
| **Business Rules** | Labels: Today/اليوم · Plan/الخطة · Progress/التقدّم · Profile/ملف الذهن |
| **Components** | Tab chrome only |
| **Widgets** | None |
| **Navigation** | Root IDs above |
| **Animations** | — |
| **Accessibility** | — |
| **Offline** | — |
| **Loading** | — |
| **Errors** | — |
| **Empty State** | — |
| **Analytics Events** | via `nav_tab` |
| **Premium Behaviour** | — |
| **Acceptance Criteria** | Deep link lands correct tab |
| **Regression Tests** | RTL order |

## MOD-01 Maintenance gate

| Field | Spec |
|---|---|
| **ID** | `MOD-01` |
| **Purpose** | Enter Maintenance mode |
| **Dependencies** | Stability signals or user opt-in |
| **Inputs** | confirm |
| **Outputs** | `mode=maintenance` → HOM-01 |
| **Business Rules** | Opt-in; no shame; 3–5 Sessions/week OK |
| **Components** | Copy, Confirm, Dismiss |
| **Widgets** | None |
| **Navigation** | → HOM-01 |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Full |
| **Loading** | — |
| **Errors** | — |
| **Empty State** | — |
| **Analytics Events** | `mode_maintenance_enter` |
| **Premium Behaviour** | None required |
| **Acceptance Criteria** | HOM-01 Place shows Maintenance |
| **Regression Tests** | — |

## MOD-02 Vacation gate

| Field | Spec |
|---|---|
| **ID** | `MOD-02` |
| **Purpose** | Shrink ritual |
| **Dependencies** | User opt-in |
| **Inputs** | confirm |
| **Outputs** | `mode=vacation` |
| **Business Rules** | Micro Session; quiet notifs |
| **Components** | Copy, Confirm, Dismiss |
| **Widgets** | None |
| **Navigation** | → HOM-01 |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Full |
| **Loading** | — |
| **Errors** | — |
| **Empty State** | — |
| **Analytics Events** | `mode_vacation_enter` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | One-tap return to normal |
| **Regression Tests** | — |

## MOD-03 Restart gate

| Field | Spec |
|---|---|
| **ID** | `MOD-03` |
| **Purpose** | Re-entry after gap |
| **Dependencies** | Gap detection or open after miss streak |
| **Inputs** | gapDays |
| **Outputs** | Micro SES-01 |
| **Business Rules** | Zero debt; no Full Check wall; no Premium hostage |
| **Components** | WelcomeCopy, PrimaryStartMicro, OptionalLiteCheck |
| **Widgets** | None |
| **Navigation** | → SES-01 micro or CHK pulse |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Full |
| **Loading** | — |
| **Errors** | — |
| **Empty State** | — |
| **Analytics Events** | `mode_restart_start` |
| **Premium Behaviour** | Soft Appreciation forbidden here |
| **Acceptance Criteria** | Micro Session completable |
| **Regression Tests** | NTF-03 opens MOD-03/HOM restart |

---

# 1. Onboarding

## ONB-01 Welcome

| Field | Spec |
|---|---|
| **ID** | `ONB-01` |
| **Purpose** | Show promise; enter FTE |
| **Dependencies** | None |
| **Inputs** | Locale |
| **Outputs** | `onboarding.step=expectations` |
| **Business Rules** | No Premium; no ads; Language Bible promise only |
| **Components** | BrandMark, Title, Body, PrimaryButton, optional LanguageToggle |
| **Widgets** | None |
| **Navigation** | → `ONB-02` |
| **Animations** | Fade-in 300ms |
| **Accessibility** | H1 title; CTA 48dp |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `onb_welcome_view`, `onb_welcome_continue` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Continue advances; AR/EN render; no unlock copy |
| **Regression Tests** | Locale switch keeps step; back exits app/system |

## ONB-02 Expectations

| Field | Spec |
|---|---|
| **ID** | `ONB-02` |
| **Purpose** | Contract: 5-min Session, non-medical, honest progress |
| **Dependencies** | ONB-01 |
| **Inputs** | None |
| **Outputs** | `onboarding.step=consent` |
| **Business Rules** | Exactly 3 expectations; no guaranteed results |
| **Components** | Title, ExpectationList(3), Footnote, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `ONB-03` |
| **Animations** | Stagger rows ≤200ms |
| **Accessibility** | List semantics |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `onb_expectations_view`, `onb_expectations_accept` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | CTA requires view; copy matches master |
| **Regression Tests** | Back → ONB-01 |

## ONB-03 Consent

| Field | Spec |
|---|---|
| **ID** | `ONB-03` |
| **Purpose** | Required non-medical + terms; optional analytics |
| **Dependencies** | ONB-02 |
| **Inputs** | Checkbox states |
| **Outputs** | `consent.nonMedical`, `consent.terms`, `consent.analytics?` |
| **Business Rules** | CTA disabled until required true; analytics default off or explicit opt-in |
| **Components** | ConsentRow×N, TermsLink, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `ONB-04` |
| **Animations** | Checkbox 100ms |
| **Accessibility** | Labeled checkboxes |
| **Offline** | Persist local |
| **Loading** | N/A |
| **Errors** | Disabled CTA + hint |
| **Empty State** | N/A |
| **Analytics Events** | `onb_consent_submit` (flags booleans only) |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Cannot proceed without required; terms open |
| **Regression Tests** | Kill app preserves unchecked until submit |

## ONB-04 Privacy

| Field | Spec |
|---|---|
| **ID** | `ONB-04` |
| **Purpose** | Privacy summary matching live policy |
| **Dependencies** | ONB-03 |
| **Inputs** | Policy URL |
| **Outputs** | `onboarding.step=ritual` |
| **Business Rules** | Must disclose network features if product has Safa/ads/sync |
| **Components** | Title, Body, PolicyLink, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `ONB-05`; Policy → browser/in-app |
| **Animations** | 200ms fade |
| **Accessibility** | Link role |
| **Offline** | Cached summary; link retry |
| **Loading** | Policy fetch optional |
| **Errors** | Link fail → cached + Continue allowed |
| **Empty State** | N/A |
| **Analytics Events** | `onb_privacy_view`, `onb_privacy_policy_open` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Copy matches shipped policy truths |
| **Regression Tests** | Offline continue works |

## ONB-05 Ritual window

| Field | Spec |
|---|---|
| **ID** | `ONB-05` |
| **Purpose** | Select morning/afternoon/evening cue |
| **Dependencies** | ONB-04 |
| **Inputs** | Selection enum |
| **Outputs** | `settings.ritualWindow` |
| **Business Rules** | One primary window; Decide later allowed |
| **Components** | SelectableCard×3, PrimaryButton, TextButton |
| **Widgets** | None |
| **Navigation** | → `ONB-06` |
| **Animations** | Selection scale 0.98 |
| **Accessibility** | Radiogroup |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `onb_ritual_set`, `onb_ritual_skip` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Saved value readable in Settings |
| **Regression Tests** | Skip leaves null window |

## ONB-06 Brain Check intro

| Field | Spec |
|---|---|
| **ID** | `ONB-06` |
| **Purpose** | Safety + start Lite Check |
| **Dependencies** | ONB-05 |
| **Inputs** | None |
| **Outputs** | Navigate `CHK-01` mode=lite source=onboarding |
| **Business Rules** | Non-medical line required |
| **Components** | Title, Body, MetaDuration, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `CHK-FLOW` |
| **Animations** | 240ms rise |
| **Accessibility** | H1 |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `onb_check_intro_start` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Starts Lite only |
| **Regression Tests** | Back → ONB-05 |

## ONB-07 Post-Check Profile reveal

| Field | Spec |
|---|---|
| **ID** | `ONB-07` |
| **Purpose** | First Profile mirror after Lite Check |
| **Dependencies** | `CHK-FLOW` complete → ProfilePack |
| **Inputs** | ProfilePack |
| **Outputs** | `onboarding.step=plan` |
| **Business Rules** | Show Strengths + Needs focus; disclaimer; no severity |
| **Components** | ProfileStrengths, ProfileNeedsFocus, Disclaimer, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `ONB-08` |
| **Animations** | Chip stagger ≤300ms |
| **Accessibility** | Section headings |
| **Offline** | Use local pack |
| **Loading** | If pack building → `CHK-03` |
| **Errors** | Retry build |
| **Empty State** | Impossible if gated |
| **Analytics Events** | `onb_profile_reveal_view`, `onb_profile_continue` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Matches PROFILE five-answer subset |
| **Regression Tests** | Resume lands here if Check done Plan not |

## ONB-08 Plan reveal

| Field | Spec |
|---|---|
| **ID** | `ONB-08` |
| **Purpose** | Show first Recovery Plan with Because |
| **Dependencies** | ProfilePack → Engine plan |
| **Inputs** | RecoveryPlan |
| **Outputs** | Persist plan; `onboarding.step=today` |
| **Business Rules** | ≥1 Because line; starter fallback if Engine fail |
| **Components** | PlanHeader, BecauseList, TodayPreview, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `ONB-09` |
| **Animations** | 240ms card fade |
| **Accessibility** | Because list |
| **Offline** | Local plan |
| **Loading** | `PLN-00` building |
| **Errors** | Starter plan + continue |
| **Empty State** | N/A |
| **Analytics Events** | `onb_plan_reveal_view`, `onb_plan_continue` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Because cites Check signal |
| **Regression Tests** | Engine timeout → starter still has because |

## ONB-09 Today handoff + first Session

| Field | Spec |
|---|---|
| **ID** | `ONB-09` |
| **Purpose** | Start or schedule first Today's Session |
| **Dependencies** | Plan ready |
| **Inputs** | TodayAct, ritualWindow |
| **Outputs** | Navigate `SES-FLOW` or schedule reminder |
| **Business Rules** | Micro default if readiness unknown/low; Notif permission non-blocking |
| **Components** | MiniHomeAction, PrimaryButton, TextButton Remind |
| **Widgets** | None |
| **Navigation** | → `SES-FLOW` or `ONB-10` |
| **Animations** | Home Action 240ms |
| **Accessibility** | CTA labeled |
| **Offline** | Session if cached |
| **Loading** | Act fetch skeleton |
| **Errors** | Retry act |
| **Empty State** | Missing act → regenerate plan |
| **Analytics Events** | `onb_today_start`, `onb_today_defer` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Start opens SES; defer sets SESSION_READY |
| **Regression Tests** | Defer → Today shows ready CTA |

## ONB-10 Complete

| Field | Spec |
|---|---|
| **ID** | `ONB-10` |
| **Purpose** | Flag onboarding done; leave-success |
| **Dependencies** | Session marked OR deferred |
| **Inputs** | completionMode enum |
| **Outputs** | `onboarding.completed=true` → `HOM-01` |
| **Business Rules** | Never show Premium |
| **Components** | SuccessCopy, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `HOM-01` |
| **Animations** | Soft check 250ms |
| **Accessibility** | H1 success |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `onb_complete` |
| **Premium Behaviour** | Hidden |
| **Acceptance Criteria** | Flag set; next cold start skips ONB |
| **Regression Tests** | Mid-flow kill resumes correct step |

**Onboarding resume map:** Persist `onboarding.step`; Check item index via `CHK-FLOW`.

---

# 2. Brain Check

## CHK-01 Intro

| Field | Spec |
|---|---|
| **ID** | `CHK-01` |
| **Purpose** | Non-medical intro; choose/start mode |
| **Dependencies** | Consent (or prior) |
| **Inputs** | `mode=lite|full|pulse`, `source` |
| **Outputs** | Start `CHK-02` |
| **Business Rules** | Default onboarding=lite; show duration estimate |
| **Components** | Title, Body, NonMedicalLine, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `CHK-02` |
| **Animations** | 240ms |
| **Accessibility** | H1 |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `check_intro_view`, `check_start` {mode,source} |
| **Premium Behaviour** | Full deepen not paywalled on first path |
| **Acceptance Criteria** | Non-medical visible |
| **Regression Tests** | mode respected |

## CHK-02 Item

| Field | Spec |
|---|---|
| **ID** | `CHK-02` |
| **Purpose** | Capture one self-report item |
| **Dependencies** | Item bank Assessment Bible |
| **Inputs** | itemId, stem, scale, index, chapter? |
| **Outputs** | Answer persisted; next item or adaptive or complete |
| **Business Rules** | Untimed; Back allowed; autosave ≤300ms; no score-so-far; chapter progress for Full not 17/40 anxiety if n large |
| **Components** | ProgressHeader, Stem, AnswerControl, NextButton, BackButton, PauseButton |
| **Widgets** | None |
| **Navigation** | Next item / `CHK-02B` break / `CHK-04` |
| **Animations** | 200ms locale-direction slide; reduceMotion crossfade |
| **Accessibility** | “Question i of n” / “Part c of 4” |
| **Offline** | Local answers |
| **Loading** | N/A |
| **Errors** | Save fail banner; keep answers |
| **Empty State** | N/A |
| **Analytics Events** | `check_item_answer` {itemId, index} no raw PHI |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Autosave+resume same index |
| **Regression Tests** | Kill mid-item resume; Back restores prior |

## CHK-02B Micro-break (Full)

| Field | Spec |
|---|---|
| **ID** | `CHK-02B` |
| **Purpose** | Calm between chapters |
| **Dependencies** | Full chapter boundary |
| **Inputs** | chapterIndex |
| **Outputs** | Continue |
| **Business Rules** | No timer |
| **Components** | CalmCopy, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `CHK-02` |
| **Animations** | 300ms fade |
| **Accessibility** | Live region optional |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `check_break_continue` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Continue resumes next chapter |
| **Regression Tests** | — |

## CHK-02C Resume gate

| Field | Spec |
|---|---|
| **ID** | `CHK-02C` |
| **Purpose** | Continue vs start over |
| **Dependencies** | Incomplete draft |
| **Inputs** | draft |
| **Outputs** | Resume index or wipe confirm |
| **Business Rules** | Start over requires confirm |
| **Components** | Title, ContinueButton, StartOverButton |
| **Widgets** | None |
| **Navigation** | → `CHK-02` or reset |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | No draft → CHK-01 |
| **Analytics Events** | `check_resume`, `check_restart` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Answers preserved on continue |
| **Regression Tests** | Start over wipes draft only after confirm |

## CHK-03 Building Profile

| Field | Spec |
|---|---|
| **ID** | `CHK-03` |
| **Purpose** | Score MeasurementEvent → ProfilePack |
| **Dependencies** | Completed answers |
| **Inputs** | MeasurementEvent |
| **Outputs** | ProfilePack |
| **Business Rules** | No “brain scan” copy; timeout → error |
| **Components** | Loader, StatusText |
| **Widgets** | None |
| **Navigation** | → `PRF-01` or `ONB-07` |
| **Animations** | Indeterminate calm |
| **Accessibility** | polite live region |
| **Offline** | Local score |
| **Loading** | Self |
| **Errors** | Retry; keep event |
| **Empty State** | N/A |
| **Analytics Events** | `check_build_ok`, `check_build_fail` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Pack fields non-null for answered domains |
| **Regression Tests** | Lite confidence flag set |

## CHK-04 Completion beat

| Field | Spec |
|---|---|
| **ID** | `CHK-04` |
| **Purpose** | Relief before build |
| **Dependencies** | Last item answered |
| **Inputs** | mode |
| **Outputs** | → CHK-03 |
| **Business Rules** | Soft celebration only |
| **Components** | Copy, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `CHK-03` |
| **Animations** | Soft check 250ms |
| **Accessibility** | — |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `check_complete` {mode} |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Always precedes build |
| **Regression Tests** | — |

**Adaptive:** Engine inserts deepeners per Assessment Bible; UX same `CHK-02` + soft motivation line; analytics `check_adaptive_shown`.

---

# 3. Brain Profile

## PRF-01 Profile

| Field | Spec |
|---|---|
| **ID** | `PRF-01` |
| **Purpose** | Five answers: strengths, needs focus, why session, improved, needs work |
| **Dependencies** | ProfilePack |
| **Inputs** | ProfilePack, Plan, deltas, κ, sessionDone |
| **Outputs** | Nav intents |
| **Business Rules** | Disclaimer; Needs focus ≠ Needs work clone; shared because; no BCI |
| **Components** | Title, DisclaimerChip, StrengthsBlock, NeedsFocusBlock, WhySessionCard, ImprovedBlock, NeedsWorkBlock, DomainList?, SecondaryLinks |
| **Widgets** | None |
| **Navigation** | CTA→`SES-FLOW`/`CHK-01`; secondary→`PLN-01`/`PRG-01` |
| **Animations** | Stagger ≤320ms |
| **Accessibility** | Five headings; 48dp rows |
| **Offline** | Last pack + badge |
| **Loading** | Skeleton five blocks |
| **Errors** | Retry; keep last |
| **Empty State** | CTA Start Brain Check |
| **Analytics Events** | `profile_view`, `profile_cta` {cta} |
| **Premium Behaviour** | Diff entry below fold only; five answers Free |
| **Acceptance Criteria** | 5s QA five answers; because matches Home |
| **Regression Tests** | Empty→Check; stale banner; RTL |

## PRF-02 Domain sheet

| Field | Spec |
|---|---|
| **ID** | `PRF-02` |
| **Purpose** | Plain domain definition |
| **Dependencies** | PRF-01 tap |
| **Inputs** | domainId |
| **Outputs** | Dismiss |
| **Business Rules** | Non-medical definition only |
| **Components** | Sheet, Body, Close |
| **Widgets** | None |
| **Navigation** | Close |
| **Animations** | Sheet 200ms |
| **Accessibility** | Focus trap |
| **Offline** | Full |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `profile_domain_open` {domainId} |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | No diagnosis language |
| **Regression Tests** | — |

---

# 4. Recovery Plan

## PLN-00 Building

| Field | Spec |
|---|---|
| **ID** | `PLN-00` |
| **Purpose** | Generate plan |
| **Dependencies** | ProfilePack |
| **Inputs** | ProfilePack, goals |
| **Outputs** | RecoveryPlan |
| **Business Rules** | Timeout → starter with because |
| **Components** | Loader, Text |
| **Widgets** | None |
| **Navigation** | → `PLN-01` |
| **Animations** | Calm loader |
| **Accessibility** | live region |
| **Offline** | Local engine |
| **Loading** | Self |
| **Errors** | Fallback starter |
| **Empty State** | N/A |
| **Analytics Events** | `plan_build_ok`, `plan_build_fallback` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Always emits plan object |
| **Regression Tests** | Fallback has ≥1 because |

## PLN-01 Plan

| Field | Spec |
|---|---|
| **ID** | `PLN-01` |
| **Purpose** | Personal path + Because + Today preview |
| **Dependencies** | RecoveryPlan |
| **Inputs** | Plan, mode, readiness |
| **Outputs** | Nav Session/Today; resize micro flag |
| **Business Rules** | Built-from-Check chip; 1–3 Because; adaptation banner when `plan.version` bumped |
| **Components** | PlanHeader, BecauseList, TodayOnPlanCard, PathSnapshot, AdaptsCopy, TextLinks |
| **Widgets** | None |
| **Navigation** | CTA→`SES-FLOW` or `HOM-01`; Check→`CHK-01` |
| **Animations** | Because stagger ≤300ms |
| **Accessibility** | — |
| **Offline** | Last plan |
| **Loading** | Skeleton |
| **Errors** | Retry / starter |
| **Empty State** | Start Brain Check |
| **Analytics Events** | `plan_view`, `plan_start_session`, `plan_adapted_view` |
| **Premium Behaviour** | Soft fit depth below; path Free |
| **Acceptance Criteria** | Belief QA: not generic template |
| **Regression Tests** | Shared because sync with Home/Profile |

---

# 5. Home (shell for Today)

## HOM-01 Today Home

| Field | Spec |
|---|---|
| **ID** | `HOM-01` |
| **Purpose** | Answer Where / What now / Improving |
| **Dependencies** | Plan optional; Profile optional |
| **Inputs** | place, todayAct, proofSnapshot, flags |
| **Outputs** | Nav Session/Check/Review/Plan/Progress |
| **Business Rules** | Cards 0–4 only; one filled CTA; Signal muted if session incomplete; no warehouse |
| **Components** | IdentityStrip, PlaceCard, ActionCard, ProofGlance, SignalCard? |
| **Widgets** | Optional home screen Session cue (OS) |
| **Navigation** | CTA per HOME state matrix; Place→PLN-01; Proof→PRG-01 |
| **Animations** | Action 240–300ms; Proof pulse on return Mark |
| **Accessibility** | Focus order Identity→Place→Action→Proof→Signal |
| **Offline** | Cached act + Offline badge |
| **Loading** | Skeletons ≤1.5s then last-known |
| **Errors** | Retry on Action |
| **Empty State** | Action=Start Brain Check |
| **Analytics Events** | `home_view` {state}, `home_cta` {state} |
| **Premium Behaviour** | Session Free; Monthly signal Premium; no Home paywall |
| **Acceptance Criteria** | 5s Q1–Q3; CTA no scroll |
| **Regression Tests** | DONE_TODAY no second primary; miss zero debt |

---

# 6. Today's Session

## SES-01 Prepare

| Field | Spec |
|---|---|
| **ID** | `SES-01` |
| **Purpose** | One objective; start act |
| **Dependencies** | TodayAct |
| **Inputs** | practice, objective, because, duration, micro |
| **Outputs** | `session.phase=act` |
| **Business Rules** | One CTA Start; text smaller; no ads |
| **Components** | Close, Eyebrow, ObjectiveLine, Title, Because, Meta, TextSmaller, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → `SES-02`; Close→HOM-01 |
| **Animations** | 240ms fade |
| **Accessibility** | Objective heading |
| **Offline** | If act cached |
| **Loading** | Prepare skeleton |
| **Errors** | Missing act → PLN/HOM |
| **Empty State** | Redirect |
| **Analytics Events** | `session_prepare_view`, `session_start` {practiceId,micro} |
| **Premium Behaviour** | Free |
| **Acceptance Criteria** | Single objective visible |
| **Regression Tests** | DONE_TODAY deep link → SES-04 leave copy |

## SES-02 Act

| Field | Spec |
|---|---|
| **ID** | `SES-02` |
| **Purpose** | Execute one practice |
| **Dependencies** | SES-01 |
| **Inputs** | practice type UI |
| **Outputs** | complete/partial → SES-03 |
| **Business Rules** | Pause allowed; early end → Reflect; no Mark yet |
| **Components** | PracticePlayer (timer/urge/breath/write/single-task), PauseButton |
| **Widgets** | None |
| **Navigation** | → `SES-03`; Help→`SAF-01` |
| **Animations** | 200ms crossfade |
| **Accessibility** | Timer moderated announcements |
| **Offline** | Full for local practices |
| **Loading** | N/A |
| **Errors** | Practice fail → end early Reflect |
| **Empty State** | N/A |
| **Analytics Events** | `session_act_complete` {partial} |
| **Premium Behaviour** | Free |
| **Acceptance Criteria** | Always enters Reflect |
| **Regression Tests** | Pause/resume; Safa returns here |

## SES-03 Reflect

| Field | Spec |
|---|---|
| **ID** | `SES-03` |
| **Purpose** | Mandatory short reflection |
| **Dependencies** | Act end |
| **Inputs** | promptId, chips, note? |
| **Outputs** | reflection payload + mark request |
| **Business Rules** | One prompt; optional note/chip; skip note allowed; no fake % |
| **Components** | Title, Prompt, ChipRow?, NoteField?, PrimaryButton, TextSkipNote |
| **Widgets** | None |
| **Navigation** | → persist → `SES-04` |
| **Animations** | 200ms calm |
| **Accessibility** | Chips 48dp |
| **Offline** | Queue mark |
| **Loading** | Saving |
| **Errors** | `SES-03E` Retry / Leave anyway |
| **Empty State** | N/A |
| **Analytics Events** | `session_reflect_save` {chip?,partial} |
| **Premium Behaviour** | Free |
| **Acceptance Criteria** | Cannot skip phase entirely without Save/Skip-note path |
| **Regression Tests** | Partial chip available |

## SES-04 Leave

| Field | Spec |
|---|---|
| **ID** | `SES-04` |
| **Purpose** | Leave-success |
| **Dependencies** | Mark saved or leave-anyway |
| **Inputs** | success flag |
| **Outputs** | HOM-01 Done + proof pulse |
| **Business Rules** | Copy life-first; no second practice CTA |
| **Components** | SuccessCopy, PrimaryClose, TextProgress? |
| **Widgets** | None |
| **Navigation** | Close→HOM-01; Progress→PRG-01 |
| **Animations** | Soft check 250ms |
| **Accessibility** | — |
| **Offline** | Local mark |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `session_leave` |
| **Premium Behaviour** | Free |
| **Acceptance Criteria** | Home state SESSION_DONE |
| **Regression Tests** | Economy one primary mint only |

---

# 7. Progress

## PRG-01 Progress

| Field | Spec |
|---|---|
| **ID** | `PRG-01` |
| **Purpose** | Improving / Why / Compared to / Next |
| **Dependencies** | Snapshots optional |
| **Inputs** | Δ, κ, T, anchors, due flags |
| **Outputs** | Nav Next destination |
| **Business Rules** | Words-first; graph only if four-question test; one Next CTA; score disclaimer |
| **Components** | BetterBlock, WhyBlock, ComparedBlock, NextCard, RhythmDots?, ScoreRow, ReviewEntry? |
| **Widgets** | Optional proof glance widget → PRG-01 |
| **Navigation** | Next→SES/WRV/CHK/HOM |
| **Animations** | 200ms fade |
| **Accessibility** | Headings; text equiv for graph |
| **Offline** | Last-known + badge |
| **Loading** | Skeleton |
| **Errors** | Retry |
| **Empty State** | CTA Session/Check |
| **Analytics Events** | `progress_view` {verdict}, `progress_next` {dest} |
| **Premium Behaviour** | Archive/Diff soft entry; four answers Free |
| **Acceptance Criteria** | Compared-to anchor always named when verdict≠early |
| **Regression Tests** | REVIEW_DUE next priority; no dual CTA |

---

# 8. Weekly Review

## WRV-01 Weekly Review

| Field | Spec |
|---|---|
| **ID** | `WRV-01` |
| **Purpose** | Interpret week; create Weekly Artifact; propose adaptation |
| **Dependencies** | Week snapshots / Marks |
| **Inputs** | weekId, Δ7, attributions, κ |
| **Outputs** | WeeklyArtifact; optional PlanAdaptation draft |
| **Business Rules** | Honest flat/dip; non-medical; first Review Free; no ads |
| **Components** | WeekSummary, AttributionList, ArtifactCard, AdaptPropose?, PrimaryDone, SoftPremiumEntry? |
| **Widgets** | None |
| **Navigation** | Done→HOM-01/PRG-01; Premium→`PRE-01` if eligible |
| **Animations** | Artifact reveal 250ms once |
| **Accessibility** | — |
| **Offline** | If local week data |
| **Loading** | Build week |
| **Errors** | Retry |
| **Empty State** | Not enough data → HOM Session |
| **Analytics Events** | `weekly_review_open`, `weekly_artifact_save`, `weekly_adapt_accept|dismiss` |
| **Premium Behaviour** | Soft Appreciation after artifact (cap rules); archive depth Premium |
| **Acceptance Criteria** | Artifact persisted; adapt explains metrics |
| **Regression Tests** | Incomplete Session: Home Signal muted until done |

---

# 9. Reports

## RPT-01 Weekly Artifact detail

| Field | Spec |
|---|---|
| **ID** | `RPT-01` |
| **Purpose** | View saved Weekly Artifact |
| **Dependencies** | Artifact id |
| **Inputs** | artifact |
| **Outputs** | Share? (disclaimer) |
| **Business Rules** | Non-medical disclaimer on share |
| **Components** | ArtifactView, ShareButton?, Close |
| **Widgets** | None |
| **Navigation** | Back→PRG-01 |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Local artifact |
| **Loading** | Fetch |
| **Errors** | Retry |
| **Empty State** | None → WRV or HOM |
| **Analytics Events** | `artifact_view`, `artifact_share` |
| **Premium Behaviour** | Ongoing archive may Soft-gate after first Free |
| **Acceptance Criteria** | Disclaimer present on share |
| **Regression Tests** | — |

## RPT-02 Monthly Report

| Field | Spec |
|---|---|
| **ID** | `RPT-02` |
| **Purpose** | Month chapter evidence |
| **Dependencies** | Month data; Premium for full chapters per Premium Bible |
| **Inputs** | monthId |
| **Outputs** | View/export |
| **Business Rules** | Correlational language only; Free may see teaser |
| **Components** | ChapterView, Export?, SoftUpgrade? |
| **Widgets** | None |
| **Navigation** | Back→PRG-01; Upgrade→PRE-01 |
| **Animations** | 200ms |
| **Accessibility** | — |
| **Offline** | Cached if any |
| **Loading** | Build |
| **Errors** | Retry |
| **Empty State** | Not ready |
| **Analytics Events** | `monthly_report_view` |
| **Premium Behaviour** | Full chapter Premium; teaser Free |
| **Acceptance Criteria** | No medical claims |
| **Regression Tests** | Teaser doesn’t lock Progress four answers |

---

# 10. Safa

## SAF-01 Contextual coach

| Field | Spec |
|---|---|
| **ID** | `SAF-01` |
| **Purpose** | Unstick **this** Session/Plan step then release |
| **Dependencies** | Session or Plan context required |
| **Inputs** | contextId, planPhase, struggleFlags, domain gaps |
| **Outputs** | Suggestion; dismiss → prior |
| **Business Rules** | Not therapist; no diagnosis; no foresight claims; max bounded turns then force Back; no ads; Free tips/capped vs Premium depth per Premium Bible |
| **Components** | HeaderSafa, MessageList, Composer?, SuggestionCard, BackToSessionButton |
| **Widgets** | None |
| **Navigation** | Back→SES-02/SES-01/PLN-01; never tab root |
| **Animations** | Sheet 200ms |
| **Accessibility** | — |
| **Offline** | Static tip card for practice |
| **Loading** | Cancelable wait |
| **Errors** | Fallback tip |
| **Empty State** | No context → refuse open; HOM-01 |
| **Analytics Events** | `safa_open` {context}, `safa_suggestion`, `safa_back` |
| **Premium Behaviour** | Generative depth Premium; Free static/capped |
| **Acceptance Criteria** | Always visible Back to Session; leave-success |
| **Regression Tests** | Deep link without context → Today |

---

# 11. Premium

## PRE-01 Appreciation sheet

| Field | Spec |
|---|---|
| **ID** | `PRE-01` |
| **Purpose** | Earned upgrade after proof |
| **Dependencies** | proofContext=artifact|monthly|adapt |
| **Inputs** | offerings, proofEcho |
| **Outputs** | purchase | dismiss+cooldown |
| **Business Rules** | V1–V4 only; Not now equal; ≤1 auto/week; 14d after dismiss; banned windows enforced |
| **Components** | ProofEcho, DesireTitle, BenefitRows(4), CompareFreePremium, Price, PrimarySubscribe, SecondaryNotNow, Legal |
| **Widgets** | None |
| **Navigation** | Success→prior; Not now→prior |
| **Animations** | No urgency pulse |
| **Accessibility** | Optional offer announcement |
| **Offline** | Cannot purchase; dismiss |
| **Loading** | Offerings skeleton |
| **Errors** | Purchase fail calm |
| **Empty State** | No SKU → Not now |
| **Analytics Events** | `premium_offer_show` {reason}, `premium_subscribe_tap`, `premium_dismiss`, `premium_purchase_ok|fail` |
| **Premium Behaviour** | Self |
| **Acceptance Criteria** | Desire QA; Free core visible |
| **Regression Tests** | Block show from Session/Check/Onboarding |

## PRE-02 Success

| Field | Spec |
|---|---|
| **ID** | `PRE-02` |
| **Purpose** | Confirm Premium active |
| **Dependencies** | Purchase ok |
| **Inputs** | entitlement |
| **Outputs** | Return prior |
| **Business Rules** | No upsell chain |
| **Components** | SuccessCopy, PrimaryButton |
| **Widgets** | None |
| **Navigation** | → prior / HOM-01 |
| **Animations** | Soft |
| **Accessibility** | — |
| **Offline** | Entitlement cache |
| **Loading** | N/A |
| **Errors** | N/A |
| **Empty State** | N/A |
| **Analytics Events** | `premium_success_view` |
| **Premium Behaviour** | Active |
| **Acceptance Criteria** | Ads removed where applicable |
| **Regression Tests** | — |

## PRE-03 Manage

| Field | Spec |
|---|---|
| **ID** | `PRE-03` |
| **Purpose** | Manage / cancel / restore |
| **Dependencies** | Settings |
| **Inputs** | entitlement |
| **Outputs** | Play manage intent |
| **Business Rules** | Easy cancel; no guilt copy |
| **Components** | Status, ManagePlayButton, RestoreButton, ResubscribeButton |
| **Widgets** | None |
| **Navigation** | Back→SET-01 |
| **Animations** | — |
| **Accessibility** | — |
| **Offline** | Show status cache; manage needs network |
| **Loading** | — |
| **Errors** | Restore fail message |
| **Empty State** | Free status + Resubscribe→PRE-01 only if eligible else soft |
| **Analytics Events** | `premium_manage_open`, `premium_cancel_intent` |
| **Premium Behaviour** | — |
| **Acceptance Criteria** | Free core message on cancel path |
| **Regression Tests** | — |

---

# 12. Settings

## SET-01 Settings hub

| Field | Spec |
|---|---|
| **ID** | `SET-01` |
| **Purpose** | Control ritual, language, privacy, notifs, Premium, data |
| **Dependencies** | Profile tab |
| **Inputs** | settings store |
| **Outputs** | Updated settings |
| **Business Rules** | Canonical labels; privacy actions real |
| **Components** | SettingsList rows |
| **Widgets** | None |
| **Navigation** | → SET-02 Notifications, PRE-03, Policy, Ritual, Language, Clear data confirm |
| **Animations** | — |
| **Accessibility** | List |
| **Offline** | Local settings |
| **Loading** | — |
| **Errors** | Save fail |
| **Empty State** | N/A |
| **Analytics Events** | `settings_open`, `settings_change` {key} |
| **Premium Behaviour** | Manage row |
| **Acceptance Criteria** | Ritual window editable |
| **Regression Tests** | Language switch preserves data |

## SET-02 Notifications settings

| Field | Spec |
|---|---|
| **ID** | `SET-02` |
| **Purpose** | Toggle notification types |
| **Dependencies** | SET-01; OS permission |
| **Inputs** | toggles |
| **Outputs** | `notif.session`, `notif.weekly`, `notif.return` |
| **Business Rules** | No streak toggles exist; OS permission explain |
| **Components** | SwitchRows, OpenOsSettings |
| **Widgets** | None |
| **Navigation** | Back |
| **Animations** | — |
| **Accessibility** | Switch labels |
| **Offline** | Local |
| **Loading** | — |
| **Errors** | Permission denied state |
| **Empty State** | N/A |
| **Analytics Events** | `notif_settings_change` |
| **Premium Behaviour** | None |
| **Acceptance Criteria** | Disabled types never schedule |
| **Regression Tests** | — |

---

# 13. Notifications (system delivery)

## NTF-01 Session reminder

| Field | Spec |
|---|---|
| **ID** | `NTF-01` |
| **Purpose** | Ritual cue for Today's Session |
| **Dependencies** | ritualWindow; user toggle; OS perm |
| **Inputs** | schedule |
| **Outputs** | Deep link `today` / Session |
| **Business Rules** | Invitational copy only; skip if SESSION_DONE; quiet hours if set |
| **Components** | OS notification |
| **Widgets** | N/A |
| **Navigation** | → HOM-01 / SES-01 |
| **Animations** | N/A |
| **Accessibility** | OS |
| **Offline** | Local schedule |
| **Loading** | N/A |
| **Errors** | Schedule fail silent |
| **Empty State** | N/A |
| **Analytics Events** | `notif_session_sent`, `notif_session_open` |
| **Premium Behaviour** | Same |
| **Acceptance Criteria** | No streak language |
| **Regression Tests** | Toggle off → no send |

## NTF-02 Weekly Review available

| Field | Spec |
|---|---|
| **ID** | `NTF-02` |
| **Purpose** | Notify Review due |
| **Dependencies** | Review due; toggle |
| **Inputs** | weekId |
| **Outputs** | Deep link `weekly_review` |
| **Business Rules** | Max once per due week |
| **Components** | OS notification |
| **Widgets** | N/A |
| **Navigation** | → WRV-01 or PRG-01 |
| **Animations** | N/A |
| **Accessibility** | OS |
| **Offline** | — |
| **Loading** | N/A |
| **Errors** | — |
| **Empty State** | N/A |
| **Analytics Events** | `notif_weekly_sent`, `notif_weekly_open` |
| **Premium Behaviour** | Same |
| **Acceptance Criteria** | Calm copy |
| **Regression Tests** | — |

## NTF-03 Gentle return

| Field | Spec |
|---|---|
| **ID** | `NTF-03` |
| **Purpose** | Invite after gap |
| **Dependencies** | Gap≥threshold; toggle |
| **Inputs** | gapDays |
| **Outputs** | Deep link Restart/Today |
| **Business Rules** | No guilt; micro Session framing |
| **Components** | OS notification |
| **Widgets** | N/A |
| **Navigation** | → HOM-01 Restart state |
| **Animations** | N/A |
| **Accessibility** | OS |
| **Offline** | — |
| **Loading** | N/A |
| **Errors** | — |
| **Empty State** | N/A |
| **Analytics Events** | `notif_return_sent`, `notif_return_open` |
| **Premium Behaviour** | Same |
| **Acceptance Criteria** | Banned phrases absent |
| **Regression Tests** | — |

---

# 14. Deep links (contract)

| Intent | Target ID | Rules |
|---|---|---|
| `today` | HOM-01 / SES-01 | Respect DONE_TODAY |
| `progress` | PRG-01 | — |
| `plan` | PLN-01 | — |
| `profile` | PRF-01 | — |
| `check` | CHK-01 | — |
| `weekly_review` | WRV-01 | Else PRG-01 |
| `premium` | PRE-01 | Only if eligible else HOM-01 |
| `safa` | SAF-01 | Require context else HOM-01 |
| `maintenance` | MOD-01 | — |
| `vacation` | MOD-02 | — |
| `restart` | MOD-03 | — |

Legacy V1 paths may redirect to nearest V2 ID until Wave 9; redirects must be listed in PR.

---

# 15. Cross-cutting analytics registry

Allowed event names are only those listed on screens above plus:

| Event | When |
|---|---|
| `app_open` | Cold/warm start `{onboardingComplete,mode}` |
| `entitlement_change` | Premium status |
| `nav_tab` | Tab change `{tab}` |
| `v2_flag` | Feature flag toggle (debug/internal only) |

Props: enums/ids/booleans/counts only — no free-text answers, no health diagnoses.

---

# 16. Contract enforcement

1. PR must cite screen **ID**(s) from §0A.  
2. New UI without ID → **reject**.  
3. Master Spec conflict → update **this** Build Spec first, then implement.  
4. QA signs AC + Regression Tests per ID.  
5. Feature flags may hide IDs; may not invent parallel product screens.  
6. V1 islands listed in header **Out of scope** must not gain new features; only migrate or delete per wave.  
7. Package identity, signing, secrets, RC restore, ads consent, privacy, RTL/LTR are immutable without explicit release authority.

---

# 17. Minimum shippable V2 loop (AC for “V2 on”)

User can: ONB → CHK Lite → PRF → PLN → HOM → SES (with Reflect) → PRG → WRV Artifact → optional PRE-01 → leave.  
Nav has exactly four tabs. Safa only via SAF-01. No BCI/Pro/Daily Program user-facing strings on V2 surfaces.

---

**Status:** `V2_BUILD_SPEC_ENGINEERING_CONTRACT`  
**File:** `docs/BRAIN_CLEAN_V2_BUILD_SPEC.md`

**One-line contract:**  
If it isn’t an ID in `BRAIN_CLEAN_V2_BUILD_SPEC`, it doesn’t ship.
