# Runner setup (Brain Clean) — reusable in any project

## What it is
`tools/runner/brainclean_runner.ps1` watches `.runner/inbox/`. Each `*.json` task moves to `running/`, is executed by the Cursor CLI agent (`cursor-agent -p "<prompt>" --force`), then its log + result go to `done/`. One task at a time. The runner never builds and never pushes.

## Files
- `AGENTS.md` (repo root): agent role, gate checks, "never" list.
- `docs/prompts/RULES.md` (binding rules), `docs/prompts/Cxx_*.md` (tasks), `docs/prompts/QUEUE_ORDER.md` (status).
- `.cursor/cli.json`: allow/deny for the CLI agent (push, reset, delete, secrets denied).
- `.runner/inbox|running|done/` (git-ignored).

## Task file (`.runner/inbox/C01.json`)
{ "id": "C01", "title": "Short title", "prompt": "Read AGENTS.md and docs/prompts/RULES.md, then execute docs/prompts/C01_paywall.md exactly. ...", "timeoutMinutes": 90 }

## Result (`.runner/done/C01.result.json`)
status = DONE | BLOCKED | FAILED | TIMEOUT | CHECK_COMMITS | ALERT_PUSHED | ALERT_BRANCH_CHANGED, plus commits, heads, pushed flag, uncommitted file count. Full output: `done/C01.log`.

## One-time setup
1. Install the Cursor CLI (cursor.com/cli) and run `cursor-agent login` once (Mahmoud; no keys in files).
2. Copy `AGENTS.md`, `.cursor/cli.json`, `tools/runner/brainclean_runner.ps1`; add the `.runner/` lines to `.gitignore`.
3. In Cursor's terminal at the repo root:
   powershell -ExecutionPolicy Bypass -File .\tools\runner\brainclean_runner.ps1
4. Stop: create an empty `.runner\STOP` file (or Ctrl+C).

## Workflow
Claude writes the task → drops ONE json into inbox → runner executes → Claude reviews commit + CHANGES → marks DONE in QUEUE_ORDER → drops the next json. Build tasks (C09, C10) are run by Mahmoud only after confirming Vireo is not building.
