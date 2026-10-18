# Brain Clean — Rules for every task (Cursor Agent)

Read this file before every task. These rules override anything else.

## How a task starts
Mahmoud sends: `Read docs/prompts/RULES.md and docs/prompts/QUEUE_ORDER.md, then execute the task marked NEXT. Stop when done.`
→ Open QUEUE_ORDER.md, find the ONE row with status **NEXT**, read that task file fully, do it, stop. Never start a second task.
Before coding, read `docs/v3/PLAN_AFTER_REVIEW_2026-10-16.md` (it overrides older docs where they conflict) and the spec sections the task names in `docs/v3/V3_PRODUCT_SPEC.md`.

## Scope
- Work ONLY inside this repo. Never open or modify `N:\vireo` or any other project.
- Branch: `v3/rebuild`. Do not create/switch branches.

## Forbidden
- `git push`, `git reset`, `git rebase`, `git checkout -- .`, `git clean`, `git stash drop`, any `--force`.
- Deleting files/folders unless the task lists them by path.
- Editing `.env`, `key.properties`, `*.jks`, `*.keystore`, or any secret; never print secrets.
- Changing RevenueCat entitlement `Brain Clean` or product ids `brainclean_monthly` / `brainclean_yearly` / `brainclean_lifetime`.
- Touching signing config in `android/app/build.gradle.kts` or `build_release.ps1` unless the task says so.
- Hard-coding prices, fake data, placeholder screens reported as "done".

## Time limits
- `flutter test --timeout 60s`. Run the task's new/changed tests first, then the full suite once.
- Any command hanging > 3 minutes: stop it, note it in CHANGES, continue.

## Finish every task the same way
1. `flutter analyze` → 0 issues.
2. `flutter test --timeout 60s` → all green.
3. Build ONLY if the task says "Build: yes".
4. Write `docs/prompts/CXX_CHANGES.md`: files changed, what was NOT done and why, deviations, last lines of analyze, test counts, and `git log -1 --stat` (after commit).
5. In `docs/prompts/QUEUE_ORDER.md` change this task's status to **REVIEW** (do not touch other rows).
6. Exactly ONE commit with the message written in the task file (include CHANGES + QUEUE_ORDER). Then STOP.

## Honesty
- Never weaken/skip/delete a test to make it pass. A truthful "not done" beats a fake "done".

## Copy rules (all user-facing text)
- Simple Modern Standard Arabic + English. UI text in ARB, content in `assets/content/*.json`. No dialect (مو، عشان، ليش، ازاي).
- Banned: علاج، شفاء، تشخيص (except «ليس تشخيصًا»)، IQ، ذكاء as a measured trait، مثبت علميًا، تلف دماغي، cure, treat, diagnose, proven, intelligence, brain damage.
- Western digits 0-9 everywhere. Changes are written «من X إلى Y» (never arrows).
- SOS is free forever for everyone. Never list it as a paid benefit, never put a paywall in front of it.
