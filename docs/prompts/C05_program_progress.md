# C05 — Program tab + Progress tab

Build: **no**
Commit message: `v3: program tab and progress tab`
Spec: §4.9, §4.11, §5.4. Data: `lib/v3/data/*`, `lib/v3/domain/program_engine.dart`, `lib/v3/application/*`.

## Program tab — `lib/v3/ui/program/program_screen.dart` (replace `V3TabPlaceholder` for `/program`)
- 4 week sections from `program.json` (title + goal). Week 4 shows days 22–30.
- Tiles: done ✓ / today (highlighted) / future (lock) / Pro lock (day ≥ 8, not Pro, gold lock).
- Done → `/program/day/:n` read-only review (`program_day_review_screen.dart`): lesson title + paragraphs + key idea, practice title + steps, the user's saved inputs for that day.
- Future → bottom sheet «يفتح بعد إكمال يوم X». Pro lock → `/paywall?source=program`.

## Progress tab — `lib/v3/ui/progress/progress_screen.dart` (replace placeholder for `/progress`)
Real data only:
1. Clarity line chart (`fl_chart`) at days with results; latest value big + «من X إلى Y منذ اليوم الأول».
2. Phone hours: first estimate vs latest (self-reported). Leave a clearly separated slot `UsageSummaryCard` that C06 fills with real usage data (render nothing for now).
3. 30-day calendar grid: done / partial / missed / today / future. Week starts Saturday for Arabic locale, Monday otherwise. Grid direction follows text direction.
4. Stats: «أيام التدريب», current + best streak, challenges done, focus minutes, «رغبات تجاوزتها».
5. Evening mood mini chart (last 14 days).
- Charts must render correctly in RTL (x-axis from right in Arabic).
- Empty state (Day 1 not completed): ONE card «أكمل يومك الأول لتبدأ رحلتك» + ONE button → `/today`.

## Tests — `test/v3/program_progress_test.dart`
tile states (done/today/future/Pro-locked/Pro-unlocked); future sheet; done review shows saved input; empty state has exactly one button; chart points = number of results; stats match seeded data; missed day marked; Arabic calendar starts Saturday.
