# 15 — Open Questions & Conflicts

**Status:** Living register  
**Created:** 2026-07-29  
**Method:** Compared Product OS authoritative context vs `docs/BRAIN_CLEAN_MASTER.md`, `brain_clean_mobile/docs/BRAIN_CLEAN_HANDOFF_2026-07-29.md`, `brain_clean_mobile/store_metadata.md`, privacy docs, and prior product audits.  
**Rule:** Old documents are **not** automatically correct.

---

## Conflict index

| ID | Issue | Priority |
|----|-------|----------|
| C01 | Home dashboard vs Today/Daily Program entry | Critical |
| C02 | BCI scientific marketing vs invented-index honesty | Critical |
| C03 | Brain games positioning / transfer claims | Critical |
| C04 | Safa contextual coach vs dedicated tab + paywall | Critical |
| C05 | Ads on recovery product vs trust/constitution | High |
| C06 | Free vs Pro matrix contradictions across docs | High |
| C07 | Cloud/Supabase/Safa vs “no account / local only” messaging | High |
| C08 | Recovery vs Detox vs Accountability duplication | High |
| C09 | Accountability penalties vs no-shame principle | High |
| C10 | Daily Program step count / schema drift | Medium |
| C11 | Master doc version/status staleness | Medium |
| C12 | Store metadata vs evidence framework | High |
| C13 | Documentation volume vs “never build encyclopedia” | Low–Medium |
| C14 | Missing analytics taxonomy in shipping reality | High |
| C15 | Missing formal user research corpus | High |
| C16 | Adaptive Day types: designed vs visible in UI | Medium |
| C17 | App blocker / friction tools: never-build v1 vs future | Medium |
| C18 | SOS destination UX (grid vs triage) | Medium |

---

## C01 — Home vs Today

**Issue:** Constitution says Home exists to enter Daily Program; audits find Home is a multi-feature warehouse.  

**Evidence/source:** Master IA table; product audit; Home card stack (DP + metrics + tools).  

**Why it matters:** Exhausted users lose “What now?” → North Star fails.  

**Options:**  
A) Make default route Daily Program  
B) Rebuild Home as Today (one CTA)  
C) Keep Home; progressively hide modules  

**Recommended direction:** A + B staged (experiment first).  

**Risk of delay:** Continued activation/retention leak.  

**Owner decision required:** Yes.

---

## C02 — BCI positioning

**Issue:** Master admits BCI is invented motivational index; Journey treats live BCI as hero; store copy calls it a scientific clarity measure.  

**Evidence/source:** Master science section; Journey BCI hero; `store_metadata.md` BCI blurb.  

**Why it matters:** Scientific trust risk; Lumosity-like exposure; conflicts with “no invented clinical truth.”  

**Options:**  
A) Reframe as Consistency / Completion index with plain language  
B) Demote to Journey detail with disclaimer  
C) Remove from marketing entirely  

**Recommended direction:** A + B; rewrite store copy.  

**Risk of delay:** Misleading ASO; user distrust.  

**Owner decision required:** Yes.

---

## C03 — Brain games

**Issue:** Master states brain-training games lack real-life transfer; product still includes game hubs and store mentions XP/games energy.  

**Evidence/source:** Master “what doesn’t work”; Games hub / cognitive hubs in app IA.  

**Why it matters:** False hope; weak ROI; policy/marketing risk if overclaimed.  

**Options:**  
A) Reframe as micro-break only; strip enhancement copy  
B) Reduce to crossword + 1 break activity  
C) Keep suite behind Pro as entertainment (honest labeling)  

**Recommended direction:** A immediately; B as product simplification.  

**Risk of delay:** Brand confusion (“brain training app”).  

**Owner decision required:** Yes.

---

## C04 — Safa tab vs contextual coach

**Issue:** Master: Safa appears during journey, not isolated tab. Shipping: Safa tab; trial → paywall patterns risk bait-and-switch feel.  

**Evidence/source:** Master feature roles; handoff Safa/Pro notes; Safa tab UX audit.  

**Why it matters:** Emotional trust; monetization ethics; IA clarity.  

**Options:**  
A) Keep tab but soft-land into chat; no embedded full paywall body  
B) Demote tab; entry from DP/mood/SOS  
C) Hybrid: tab for Pro users; free get contextual only  

**Recommended direction:** Guardrails now (A); evaluate B.  

**Risk of delay:** Churn at trial expiry; brand cynicism.  

**Owner decision required:** Yes.

---

## C05 — Ads vs recovery trust

**Issue:** Manifesto recovers attention; free tier shows banners on Home/Exercises/Journey/More.  

**Evidence/source:** Handoff ads policy; Product OS monetization ethics.  

**Why it matters:** Even compliant ads can feel like the problem user came to escape.  

**Options:**  
A) Keep strict exclusions (shipping) + monitor  
B) Reduce ad surfaces further  
C) Ads-free free tier with other monetization  

**Recommended direction:** Keep exclusions as hard law; measure trust; consider B.  

**Risk of delay:** Subtle brand damage.  

**Owner decision required:** Yes (long-term ads strategy).

---

## C06 — Free vs Pro contradictions

**Issue:** Store metadata free/Pro split (themes, Safa, anxiety unit, reports) may not match constitution (“mood/crisis not aggressively paywalled”) or shipping RevenueCat entitlements.  

**Evidence/source:** `store_metadata.md`; constitution; handoff “DP free”.  

**Why it matters:** Play listing honesty; user anger; ethics.  

**Options:** Audit shipping gates → single source of truth table.  

**Recommended direction:** Produce Free/Pro matrix from code + RC dashboard; update store + OS.  

**Risk of delay:** False advertising risk.  

**Owner decision required:** Yes.  
**Open question:** Exact current gate list — **do not invent**.

---

## C07 — Local-only vs Supabase/Safa cloud

**Issue:** Handoff: no account / no cloud sync in current release; Safa needs Supabase dart-defines; privacy/store text historically mixed “local only” vs cloud when enabled.  

**Evidence/source:** Handoff §§1,4,7; Privacy Policy “when enabled”; store Data Safety table claiming no collection.  

**Why it matters:** Data Safety / privacy accuracy.  

**Options:** Align Data Safety + privacy + store with actual Safa network calls.  

**Recommended direction:** Treat Safa AI messages as processed when enabled; update declarations.  

**Risk of delay:** Policy inconsistency.  

**Owner decision required:** Yes.

---

## C08 — Recovery / Detox / Accountability duplication

**Issue:** Multiple systems for support/accountability/detox metaphors.  

**Evidence/source:** Master routes; SOS → recovery; detox feature; accountability.  

**Why it matters:** Cognitive overload; maintenance cost; user confusion.  

**Options:** MERGE into Support path; deprecate detox metaphor (“dopamine detox” language).  

**Recommended direction:** MERGE plan; single SOS triage.  

**Risk of delay:** Continued IA sprawl.  

**Owner decision required:** Yes.

---

## C09 — Accountability penalties

**Issue:** Score penalties conflict with “remind, never scold” and emotional safety.  

**Evidence/source:** Product audit; master principle 7.  

**Why it matters:** Shame → avoidance of app after hard days.  

**Options:** Remove penalties; optional reflection only.  

**Recommended direction:** REJECT penalty framing.  

**Risk of delay:** Silent churn.  

**Owner decision required:** Yes.

---

## C10 — Daily Program step schema drift

**Issue:** Master lists 7 steps; handoff lists 8 including single-focus task; adaptive day types may be incomplete in UI.  

**Evidence/source:** Master journey; handoff steps; DP service evolution.  

**Why it matters:** Docs/engineering drift; QA confusion.  

**Options:** Single canonical step list in Constitution appendix.  

**Recommended direction:** Handoff/shipping schema wins until master updated.  

**Risk of delay:** Doc thrash.  

**Owner decision required:** Confirm canonical list.  
**Open question:** Exact shipped step keys/order — verify in code when implementing.

---

## C11 — Master doc staleness

**Issue:** Master header still shows 1.0.0+9 / older test counts; product is 1.2.3+16 on safe-ads branch.  

**Evidence/source:** Master header vs handoff/pubspec.  

**Why it matters:** Agents/humans trust wrong version reality.  

**Options:** Update master; or mark master “constitution only” and handoff as ops truth.  

**Recommended direction:** Split: Constitution truth vs Release truth; update versions.  

**Owner decision required:** Yes (doc ownership).

---

## C12 — Store metadata vs evidence framework

**Issue:** Store copy: “scientific BCI”, anxiety “scientific questions”, Safa predicts weakness — may overclaim.  

**Evidence/source:** `store_metadata.md`.  

**Why it matters:** Trust + policy + science honesty.  

**Recommended direction:** Rewrite under `03` Accepted/Softened rules before production push.  

**Owner decision required:** Yes.

---

## C13 — Documentation volume

**Issue:** Master never-build warns against encyclopedia docs; Product OS adds many files.  

**Why it matters:** Process vs shipping balance.  

**Recommended direction:** Product OS is decision infrastructure; keep research_logs lean; don’t duplicate master.  

**Owner decision required:** Acknowledge exception.

---

## C14 — Missing analytics taxonomy

**Issue:** Framework proposes events; shipping instrumentation reality unknown in this doc pass.  

**Open question:** What events exist today?  

**Owner decision required:** Engineering audit.

---

## C15 — Missing user research corpus

**Issue:** No structured interview repository referenced in docs.  

**Open question:** Sources of truth for pain validation beyond constitution assumptions.  

**Owner decision required:** Research plan.

---

## C16 — Adaptive Day visibility

**Issue:** Designed in master; unclear if user-visible Light/Recovery days ship.  

**Open question:** Implementation status.  

**Owner decision required:** Product + eng verify.

---

## C17 — Blockers / friction tools

**Issue:** Never-build app blocker for v1; competitors (Opal/One Sec) lean on friction.  

**Options:** Stay out; optional OS-level shortcuts later; ethical friction experiments.  

**Owner decision required:** Strategy call.

---

## C18 — SOS UX

**Issue:** FAB may open dense recovery grid vs short triage.  

**Recommended direction:** 3-choice triage experiment.  

**Owner decision required:** Yes.

---

## Decisions that require Product Owner approval (summary)

1. Today/default routing strategy (C01)  
2. BCI naming + store rewrite (C02, C12)  
3. Games portfolio honesty (C03)  
4. Safa IA + monetization guardrails (C04, C06)  
5. Long-term ads strategy (C05)  
6. Data Safety accuracy for Safa (C07)  
7. MERGE recovery systems (C08)  
8. Kill score penalties (C09)  
9. Canonical DP steps (C10)  
10. Doc ownership: master vs handoff vs Product OS (C11, C13)

---

## Recommended first use of Product OS

1. Owner reviews this file (`15`)  
2. Resolve Critical conflicts C01–C04  
3. Update store/science copy under `03`  
4. Only then open implementation handoffs (`14`)
