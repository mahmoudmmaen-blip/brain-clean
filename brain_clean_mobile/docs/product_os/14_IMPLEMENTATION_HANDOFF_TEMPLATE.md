# 14 — Implementation Handoff Template

Use only after Decision status is **APPROVE** or **APPROVE_WITH_GUARDRAILS**.  
This template is for Cursor/Flutter engineers. It does **not** authorize scope expansion.

---

## Handoff header

```
Feature / Change name:
Decision ID:
Status: APPROVE | APPROVE_WITH_GUARDRAILS
Owner:
Date:
Related research log:
Scorecard total:
```

---

## Goal

One sentence tied to North Star (Daily Program completion).

---

## Scope

Bullet list of allowed work.

---

## Non-goals

Explicit exclusions (no drive-by refactors, no new tabs, no package adds unless listed).

---

## Existing files allowed to change

List concrete paths under `brain_clean_mobile/` only.

---

## Files / areas forbidden to change

Default forbid unless explicitly listed:

- Root `lib/`  
- Unrelated features  
- Signing / applicationId  
- Secrets  
- Daily Program formula/gates unless this handoff is about them  
- Docs outside stated paths (if any)

---

## Routes

Affected GoRouter paths; push vs go rules if relevant.

---

## State management

Riverpod providers involved; no setState for business logic.

---

## Persistence

Hive boxes / keys; migration needs; offline behavior.

---

## Analytics

Events to add (from `11`); privacy constraints.

---

## Localization

- Strings in `app_en.arb` + `app_ar.arb` only  
- No hardcoded UI strings  
- RTL considerations  

---

## Accessibility

Targets, semantics, contrast notes.

---

## Edge cases

Missed day, offline, Pro/free, trial expired, empty states, back navigation, web if applicable.

---

## Tests

Focused tests to add/update; do not require full suite unless specified.

---

## Acceptance criteria

Checklist mapped to UX checklist (`05`) + constitution.

---

## Rollback plan

How to disable/revert safely.

---

## Git safety

- Branch name  
- No force push to main  
- No commit secrets  
- Do not change LF/CRLF on unrelated files  
- Commit only when asked  

---

## Definition of done

- [ ] Scope only  
- [ ] Analyze: no new errors  
- [ ] Targeted tests pass  
- [ ] AR/EN strings  
- [ ] Ads/paywall rules respected  
- [ ] Guardrails implemented  
- [ ] Handoff owner reviewed UX copy  
- [ ] No drive-by refactors  

---

## Engineer notes (optional)

Open questions discovered during implementation → escalate to `15`, do not invent product policy.
