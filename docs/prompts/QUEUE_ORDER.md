# Brain Clean — Task queue (Cursor Agent)

Start message (same every time):
> Read docs/prompts/RULES.md and docs/prompts/QUEUE_ORDER.md, then execute the task marked NEXT. Stop when done.

Status: NEXT = do now · WAITING · REVIEW = done by Cursor, Claude is reviewing · DONE = approved.
Only Claude changes WAITING → NEXT and REVIEW → DONE.

| # | File | Status | Build |
|---|---|---|---|
| C01 | C01_paywall.md | DONE | no |
| C02 | C02_onboarding_trial.md | DONE | no |
| C03 | C03_content_sos_share.md | REVIEW | no |
| C04 | C04_today_tools.md | WAITING | no |
| C05 | C05_program_progress.md | WAITING | no |
| C06 | C06_usage_data.md | WAITING | no |
| C07 | C07_settings_graduation_backup.md | WAITING | no |
| C08 | C08_notifications_polish.md | WAITING | no |
| C09 | C09_release.md | WAITING | yes (ask first) |
| C10 | C10_maintain_mode_V3_1.md | WAITING (after launch) | yes (ask first) |

Notes
- Source of truth for decisions: docs/v3/PLAN_AFTER_REVIEW_2026-10-16.md (overrides older docs).
- P01–P05 are superseded. P01 work already on disk (lib/v3/ui/paywall/*) is continued in C01.
- One task = one commit. No push. Never build while Vireo is building.
