# Brain Clean V3 — برومتات Cursor بالترتيب

**طريقة الاستخدام:**
1. انسخ مجلد `v3` كما هو إلى مجلد المشروع على جهازك: `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2\v3_input\`
2. الصق البرومت 0 في Cursor (وضع Agent). انتظر حتى ينتهي ويرسل التقرير.
3. أرسل لي التقرير، ثم انتقل للبرومت التالي. **برومت واحد في كل مرة.**
4. لا ترفع أي شيء إلى Google Play قبل نهاية البرومت 6.

---

## البرومت 0 — التجهيز والمحتوى

```
We are rebuilding Brain Clean as V3. The full spec is in v3_input/V3_PRODUCT_SPEC.md — read it completely first. It is the single source of truth and overrides every older doc/contract in docs/.

Do this phase only, then stop and report:

1. Create branch v3/rebuild from improvements/ux-rebuild (version 2.0.6+36).
2. Move v3_input/V3_PRODUCT_SPEC.md and v3_input/V3_CURSOR_PROMPTS.md to docs/v3/. Move v3_input/content/*.json to assets/content/. Delete v3_input/.
3. Register assets/content/ in pubspec.yaml.
4. Create lib/v3/content/: Dart models + a ContentRepository (Riverpod provider) that loads program.json, exercises.json, clarity_check.json and sos.json once, and returns localized strings for the current locale with fallback to "en". Text objects are {"ar": "...", "en": "..."}; lists are {"ar": [...], "en": [...]}.
5. Add test/v3/content_integrity_test.dart: days are exactly 1..30; every text object has ar+en; every practiceId/bonusId exists in exercises; days 1-7 only use tier "free" exercises; steps ar/en lengths match; clarity check has 8 questions + scale of 5.
6. Do NOT change any existing screens yet. flutter analyze clean, flutter test green.
7. Commit "v3: content + content repository" and push the branch. Report: files created, test results.
```

---

## البرومت 1 — البيانات والقواعد

```
Continue on branch v3/rebuild. Follow docs/v3/V3_PRODUCT_SPEC.md sections 5.2, 5.3, 5.4 exactly.

1. Create lib/v3/data/: encrypted Hive box "v3_state" (reuse the existing secure key/encryption helpers in lib/core/security) with the models from spec §5.2 (UserProfile, DayProgress, ClarityResult, EveningCheckIn, SosLog, FocusLog, UserInputs). Plain classes + manual JSON maps are fine; avoid new code generation if not needed.
2. Create lib/v3/domain/:
   - ClarityScoring: formula from clarity_check.json (reverse items, 0-100, area scores, band lookup).
   - ProgramEngine: currentDay, isDayUnlocked(day, now) (next day unlocks at local midnight after completing the previous one), isDayCompleted rules (lesson done + practice done or easy used), streak with one free rest day per 7 days, isProLocked(day, isPro) (day >= 8 and not Pro), nextClarityCheckDay, program finished state.
3. Riverpod providers for all of the above (lib/v3/application/).
4. Unit tests in test/v3/ for: clarity scoring (all-best = 100, all-worst = 0, reverse items, bands, areas), unlock at midnight, missed days don't reset, streak + rest day, Pro lock (day 7 free, day 8 locked, SOS never locked), currentDay caps at 30.
5. No UI changes yet. analyze clean, tests green. Commit "v3: data + program engine" and push. Report test list.
```

---

## البرومت 2 — البداية (Onboarding) والتنقل الجديد

```
Continue on v3/rebuild. Spec: docs/v3/V3_PRODUCT_SPEC.md §3, §4.1–4.4, §8, §9.

1. Create a NEW router for V3 in lib/v3/routing/ with the routes in spec §3. Make main.dart/app use only this router. V3 is the only product: remove usage of V2FeatureBoundary, V2_ENABLED and StartupDestination from startup (leave the old files on disk for now; they'll be deleted in prompt 6). Splash + biometric lock still run first.
2. Build screens in lib/v3/ui/onboarding/: Welcome, Clarity Check (one question per screen, tap = auto-advance, progress dots, back arrow; first the screen-time question), Setup (one scrollable screen: optional name, goal chips, reminder time), Result & Plan (score, band, 4 area bars, 4 week titles, button "ابدأ اليوم الأول (5 دقائق)").
3. Mark onboardingDone = true when /result is shown. On later launches go straight to /today. If onboardingDone is false, always start at /welcome.
4. Clarity Check screen must be reusable for re-checks (mode: baseline / recheck) — in recheck mode show "compared to last time" at the end.
5. All UI labels in ARB (AR + EN). Simple MSA, no dialect. Use existing theme tokens. Light haptic on answer tap.
6. Temporary: /today can be a placeholder screen with the 4-tab shell (Today, Program, Tools, Progress) — real screens come next.
7. Widget tests: onboarding happy path; relaunch after /result goes to /today (never back to onboarding); check scoring saved to box.
8. analyze clean, tests green. Bump to 3.0.0+37. Build with build_release.ps1. Commit + push. Report with screenshots-worth description of each screen.
```

---

## البرومت 3 — اليوم + جلسة اليوم + مراجعة المساء

```
Continue on v3/rebuild. Spec §4.5, §4.6, §4.8, §6.2.

1. Today screen exactly as spec §4.5 (header + gear → /settings, streak + "اليوم X من 30" bar, hero day card with its 4 states, challenge card with checkbox, SOS button, evening check-in card after 18:00, small Clarity card). Nothing else on Today.
2. Day session player /session/:n as spec §4.6: 3 steps (Lesson → Practice → Challenge) with top progress, X to leave (progress kept), "تخطَّ" on each step, "النسخة السهلة" toggle. Practice renders by exercise.mode: steps (checklist), guided (breathing circle/countdown), timer and focus_timer (big countdown + ambient sound picker using the existing AmbientSoundPlayer, keep screen awake). Render input forms for every `input` key in spec §5.3 and save to UserInputs. Bonus exercise card when bonusId exists.
3. Completion screen with check animation + haptic. If day.clarityCheck → run the Clarity Check in recheck mode before completion. If day.graduation → go to /graduation (placeholder ok until prompt 5). After Day 7 completion → open paywall once with source=day7 (only if not Pro).
4. Evening check-in bottom sheet (§4.8), saved to EveningCheckIn.
5. Pro gating: day >= 8 and not Pro → hero card shows "افتح بقية البرنامج" → /paywall?source=locked_day.
6. Tests: Today states (not started / in progress / done / locked), session completes day and unlocks next day only after midnight, easy version counts as complete, skipping never reduces anything, day 7 triggers recheck.
7. analyze clean, tests green, build, commit, push. Report.
```

---

## البرومت 4 — زر الطوارئ (SOS) والأدوات

```
Continue on v3/rebuild. Spec §4.7, §4.10.

1. SOS: /sos list of the 4 flows from sos.json, and /sos/:flowId runner supporting step types text, rate, breath (pattern [in,hold,out,hold] or "double_sigh"; dim_screen overlay), show_why (UserInputs.whyStatement or a default line), suggest_replacement (UserInputs.replacements for that duration, else default_replacements). End screen with "من X إلى Y" when rated. Log SosLog. SOS is NEVER locked behind Pro. Show the safety line in the stress flow.
2. Tools tab: Focus timer (10/25 free, 50 Pro; ambient sounds; logs FocusLog), Breathing (double sigh free, 4-6 Pro), Exercise library (all exercises grouped by category, filter chips, Free/Pro badge, locked → paywall, opening an exercise uses the same practice renderer as the session), Brain games (reuse existing n_back, number_memory, color_word, pattern_logic, go/no-go if present — re-skin titles/descriptions neutrally, remove any IQ/intelligence/proven wording), 20-20-20 reminder toggle.
3. Tests: SOS accessible for non-Pro, each step type renders, replacement fallback, focus log saved, Pro exercises locked for free users.
4. analyze clean, tests green, build, commit, push. Report.
```

---

## البرومت 5 — البرنامج، التقدم، الإعدادات، الاشتراك، التخرج

```
Continue on v3/rebuild. Spec §4.9, §4.11–4.15, §6.1, §6.4, §5.5, §7.

1. Program tab: 4 week sections with goals and day tiles (done / today / future / Pro lock); done day → read-only review; future → "يفتح بعد إكمال يوم X".
2. Progress tab: Clarity line chart (fl_chart), phone hours first vs latest, 30-day calendar grid, stats row (current/best streak, days done, challenges done, focus minutes, SOS waves), evening mood mini chart. Empty state = one card + one button. No placeholders, no fake data.
3. Settings: exactly the items in §4.12, including Reset all data (clears v3_state after confirm) and "رسالتي" (/letter).
4. Paywall: rebuild UI only, keep PremiumController / RevenueCat logic and ids. Headline "افتح البرنامج الكامل", ONLY the 4 real benefits in §4.13, prices from offerings, restore, cancel-anytime line, terms/privacy links. Source-specific subtitle for day7.
5. Graduation (/graduation) and Letter (/letter) per §4.14–4.15. Share card per §6.4 with share_plus.
6. Notifications per §6.1 (daily reminder only if today not done; evening 21:00 if enabled; recheck days). Max 2 per day. Reschedule when settings change.
7. Migration per §5.5: if old boxes exist → one "أصبح أبسط وأقوى" screen → onboarding; then delete old boxes. Premium unaffected.
8. Tests for each screen's states + migration + notification scheduling logic.
9. analyze clean, tests green, build, commit, push. Report.
```

---

## البرومت 6 — الحذف والتنظيف والإصدار

```
Continue on v3/rebuild. Spec §2 (Delete list), §8, §10.

1. Delete every legacy feature folder and file listed in spec §2 "Delete", their routes, providers, Hive adapters/boxes (except what migration needs to detect + delete old boxes), ARB keys no longer used, and their tests. Delete brain_clean_mobile/, root index.html, cursor_automation.py, "oop install supabase", tasks/, old docs/BRAIN_CLEAN_V2_* files. Keep docs/v3/ and docs/privacy-policy/.
2. Remove V2FeatureBoundary, V2_ENABLED (also from build_release.ps1), StartupDestination V1/V2 logic, Safa UI and routes (keep supabase/ folder untouched for later).
3. Remove unused dependencies from pubspec.yaml (e.g. confetti, google_fonts if unused, crypto/uuid if unused). Keep purchases_flutter, hive, local_auth, flutter_secure_storage, flutter_local_notifications, audioplayers, fl_chart, share_plus, go_router, riverpod.
4. Copy audit: grep all ARB + JSON + Dart strings for the banned words in spec §8 and dialect words; fix any hit. Ensure Western digits.
5. Run the quality gates in spec §10: analyze clean, all tests green, add any missing V3 tests listed there.
6. Version 3.0.0+37 (AppConfig.appVersion = '3.0.0'). Build release with build_release.ps1 (R8 on). Report AAB size before/after cleanup.
7. Write docs/v3/RELEASE_CHECKLIST.md: manual device test steps (fresh install onboarding, day 1 session, SOS, focus timer with sound, paywall prices, restore, notifications, relaunch, AR + EN, light + dark).
8. Commit + push. Give me: deleted folders list, final lib/ structure, test count, AAB path.
```

---

## بعد البرومت 6 (أنا وأنت)

1. تجربة على الموبايل عبر **Internal app sharing** باتباع `RELEASE_CHECKLIST.md`.
2. تغيير الأسعار في Play Console (19 ريال شهري / 149 سنوي + 7 أيام تجربة) — اختياري لكن أنصح به.
3. رفع 3.0.0 إلى Production.
4. تحديث صفحة المتجر: وصف جديد + 6 صور جديدة (سأكتبها لك).
