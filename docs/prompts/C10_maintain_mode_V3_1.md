# C10 — Maintain mode (V3.1, after 3.0.0 is live)

Build: **yes** (ask "Is Vireo building now?" first)
Commit message: `v3.1: maintain mode after day 30`
PLAN V3.1. Must ship within 3–4 weeks of the 3.0.0 launch.

- Move `docs/prompts/content/maintain_challenges.json` → `assets/content/` (register; add integrity test: 12 challenges, title/base/hard with ar+en).
- After Day 30 (replaces the C08 temporary state): Today shows «تحدي هذا الأسبوع» (rotates every 7 days from graduation date; after 12 weeks use `hard`), accept + mark done, «أيام التدريب» keeps counting, SOS/focus/breathing unchanged.
- Monthly Clarity Check (every 30 days after Day 30) continuing the same chart; with usage data: «ساعاتك هذا الشهر مقارنة بالشهر الأول».
- ONE weekly notification on challenge start: «تحديك هذا الأسبوع: …». Daily reminder stops after Day 30.
- Maintain mode is Pro (free users after Day 30 keep SOS, focus 10/25, breathing basic, and see one locked card → paywall source `maintain`).
- Tests: rotation, hard after 12 weeks, monthly check scheduling, one notification/week, free vs Pro states.
- Version 3.1.0+38.
