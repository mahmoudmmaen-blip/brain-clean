# C08 — Notifications, migration, after Day 30, polish, cleanup

Build: **no**
Commit message: `v3: notifications, migration, after-program, polish and cleanup`
Spec: §5.4, §5.5, §6.1, §8 + PLAN item 10.

## 1. Notifications (`lib/v3/application/notification_scheduler.dart`, reuse `app_notification_service.dart`)
- Daily reminder at reminderTime only if today not done: «يومك X جاهز — 5 دقائق فقط».
- Evening 21:00 if enabled and not done: «كيف كان يومك مع الموبايل؟».
- Re-check days 7/14/21/30: «اليوم فحص الصفاء — شاهد تقدّمك».
- Max 2/day (20-20-20 excluded). Reschedule on settings change, day completion, app start.

## 2. Migration (§5.5)
Pre-V3 Hive boxes exist → one screen «Brain Clean أصبح أبسط وأقوى. برنامج جديد بانتظارك» → `/welcome` → delete old boxes (reuse existing legacy cleanup). Once. Pro unaffected.

## 3. After Day 30 (temporary until Maintain mode in V3.1)
Today: «أكملت البرنامج» + Tools shortcut + monthly Clarity Check button + «أعد البرنامج» (resets DayProgress only, keeps history).

## 4. Polish (all V3 screens)
- Haptics: light on chip/answer taps, medium on day completion.
- Empty states: one short line + one button, never blank.
- Accessibility: tooltips/Semantics on icon-only buttons (ARB), tap targets ≥ 48×48.
- RTL: directional icons (`Icons.adaptive.arrow_back`, `matchTextDirection`), progress bars fill from the start side.
- Animations ≤ 300 ms; skip when `MediaQuery.disableAnimations`.
- Fonts: keep Tajawal (Arabic) + Inter (Latin) already bundled; make sure every Arabic text style resolves to Tajawal (no system fallback).
- Western digits: force `NumberFormat` with `en` digits in Arabic locale for all numbers/dates.

## 5. Cleanup
- Zero usages of `V3SimplePlaceholder` / `V3TabPlaceholder` → delete `lib/v3/ui/placeholders/v3_simple_placeholder.dart` and `lib/v3/ui/shell/v3_tab_placeholder.dart`.
- If nothing under `lib/` imports `supabase_flutter`, remove it from pubspec (leave the `supabase/` folder untouched).
- Copy audit: grep `lib/`, `assets/content/`, ARB for the banned words in RULES; list hits + fixes in CHANGES (zero hits must also be reported).

## Tests — `test/v3/notifications_polish_test.dart`
reminder skipped when done; max 2/day; migration once; after-day-30 state; restart keeps ClarityResults; Today/Session/Paywall/Progress at textScaler 1.3 on 360×640 with no overflow; digits are 0-9 in Arabic.
