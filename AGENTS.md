# AGENTS.md — Brain Clean (Cursor agent)

You are the **executor** for Brain Clean. Claude is the planner/reviewer; Mahmoud is the owner.
You receive one task at a time from the runner (`tools/runner/brainclean_runner.ps1`), which reads `.runner/inbox/*.json`.

## Every task
1. Read `docs/prompts/RULES.md` (binding), then `docs/v3/PLAN_AFTER_REVIEW_2026-10-16.md`, then the task file named in the prompt (e.g. `docs/prompts/C01_paywall.md`).
2. Do ONLY that task. Never start another task, even if QUEUE_ORDER shows more.
3. Finish exactly as RULES.md says: analyze clean → tests green → `docs/prompts/CXX_CHANGES.md` → set the task's status to REVIEW in `docs/prompts/QUEUE_ORDER.md` → ONE commit → stop.
4. Last line of your answer: `RESULT: DONE <task id>` or `RESULT: BLOCKED <task id> — <reason>`.

## Gate checks (stop with RESULT: BLOCKED instead of guessing)
- The task needs a secret, a key, a password, or a Play Console / RevenueCat change.
- The task says "Build: yes" (Mahmoud must confirm Vireo is not building — the runner never builds).
- A test can only pass by weakening it, or analyze can't be made clean.
- The working tree had uncommitted changes you don't understand (exception: C01 continues the uncommitted paywall files on purpose).

## Never
`git push`, `git reset`, `git rebase`, `git clean`, `git checkout -- .`, force flags, deleting files not listed in the task, editing `.env` / keystores / `key.properties` / signing config / `build_release.ps1`, touching any folder outside this repo (especially `N:\vireo`).
