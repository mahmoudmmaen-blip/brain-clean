# Brain Clean V3 — Product Spec (single source of truth)

> This document replaces every older V1/V2 contract, slice report and "frozen" spec in `docs/`.
> When this spec and older docs disagree, **this spec wins**. Do not keep code alive only because an old contract mentions it.

---

## 1. What the app is (one sentence)

**A 30-day program, 10–15 minutes a day, that helps young Arabic-speaking adults take back their time and focus from their phone.**

Every screen must serve that sentence. If a screen, number or feature doesn't, delete it.

### Principles
1. **One action per screen.** Each screen has one obvious primary button.
2. **One number.** The only score shown to users is the **Clarity Score (مؤشر الصفاء)**, 0–100, from the Clarity Check. No BCI, no BC score, no Recovery Score, no XP levels, no "brain profile".
3. **Content first.** The value is the program content (`assets/content/*.json`), not tests or gimmicks.
4. **Kind, never guilt.** Skipping is fine, bad days are normal, no penalties, no shame copy.
5. **Honest.** No medical, IQ or "scientifically proven" claims. Never advertise a feature that doesn't work.
6. **Offline-first.** Everything works without internet. No cloud features in V3.

---

## 2. Keep vs delete

### Keep (reuse, don't rewrite)
- `lib/core/theme/*` — dark palette, `AppColors`, design constants, bundled fonts (Tajawal/Inter).
- `lib/core/l10n/*` — ARB pipeline (UI strings only; long content lives in JSON, see §5).
- `lib/core/security/*` — biometric lock, root detection, secure storage, Hive encryption.
- `lib/core/services/app_notification_service.dart` — local notifications.
- `lib/features/v2_premium/*` + `lib/features/pro/application/subscription_service_provider.dart` — RevenueCat purchase/restore logic and `isProUserProvider`. **Keep the entitlement id `Brain Clean` and product ids `brainclean_monthly` / `brainclean_yearly` / `brainclean_lifetime` unchanged.** Rebuild only the paywall UI.
- `lib/features/focus/ambient_sound_player.dart` + `assets/sounds/*` — for the focus timer.
- Games, re-skinned as "Brain games" in Tools, with neutral descriptions: `n_back_game.dart`, `number_memory_game.dart`, `color_word_game.dart`, `pattern_logic_game.dart` (+ Go/No-Go if present).
- `lib/features/settings` — keep language, theme, biometric lock, notifications, **Reset all data**, privacy policy link, restore purchases. Remove anything tied to deleted features.
- `build_release.ps1`, signing, R8/edge-to-edge config, `android/` setup.

### Delete (after V3 screens are live and tests are moved)
V1 + V2 product surfaces and their scoring systems:
`bci`, `dashboard`, `detox`, `diagnostic`, `interactive_diagnostic`, `brain_check`, `brain_profile`, `brain_rot_index`, `quick_tests`, `cognitive_tests`, `recovery`, `recovery_plan`, `daily_program`, `daily_session`, `progress` (old), `reports`, `v2_reports`, `weekly_review`, `v2_onboarding`, `onboarding` (V1), `home` (V1), `v2_shell`, `pro_modules`, `emotions`, `gamification`, `pomodoro` (merged into Focus timer), `v2_safa` (hidden until a real backend exists — see §11), `share` (rebuild small, see §6.9), plus nested `brain_clean_mobile/`, `index.html` at repo root, `cursor_automation.py`, `oop install supabase`, `tasks/`, old `docs/BRAIN_CLEAN_V2_*`.
Also delete: `V2FeatureBoundary`, `V2_ENABLED` dart-define (V3 is the only product), `StartupDestination` V1/V2 branching, all routes under `/v2/*` and V1 routes.

Tests for deleted features are deleted with them. New V3 tests are added (see §10).

---

## 3. Navigation

**First run:** Welcome → Clarity Check → Setup → Result & Plan → Day 1 session → Today.

**Main app: bottom bar with 4 tabs**

| Tab | AR | EN | Icon |
|---|---|---|---|
| Today | اليوم | Today | home |
| Program | البرنامج | Program | map / route |
| Tools | الأدوات | Tools | toolbox / spa |
| Progress | التقدم | Progress | chart |

- **Settings ("أنا / Me")** opens from an avatar/gear icon at the top of Today. It is not a tab.
- **Pro is not a tab.** The paywall opens only from locked items, from Settings, and once after Day 7 (§7).
- Routes (go_router): `/welcome`, `/check`, `/setup`, `/result`, `/today`, `/program`, `/program/day/:n`, `/session/:n`, `/tools`, `/tools/exercise/:id`, `/tools/focus`, `/tools/games/:id`, `/sos`, `/sos/:flowId`, `/progress`, `/settings`, `/paywall?source=`, `/letter`, `/graduation`.

---

## 4. Screens (exact content)

### 4.1 Welcome `/welcome`
- App mark, title: **«استعد وقتك وتركيزك»** / "Take back your time and focus".
- Subtitle: «برنامج 30 يومًا، 10 دقائق يوميًا» / "A 30-day program, 10 minutes a day".
- 3 small lines with icons: «افهم عاداتك» · «غيّر بيئتك» · «ابنِ بدائل حقيقية».
- Primary: «ابدأ» / "Start". Secondary text link: language switch (AR/EN).
- One line, small: «ليس علاجًا طبيًا» / "Not medical treatment".

### 4.2 Clarity Check `/check` (also used for re-checks)
- Source: `assets/content/clarity_check.json`.
- Intro card → screen-time question → 8 questions, **one per screen**, tap an answer = auto-advance (no Continue button). Back arrow allowed. Progress dots at top.
- Takes about 60 seconds. On re-checks (Day 7/14/21/30) show "مقارنةً بآخر مرة" after finishing.

### 4.3 Setup `/setup` (one scrollable screen)
- First name (optional, text).
- Main goal (single choice chips): «تركيز أفضل» / «نوم أفضل» / «تصفح أقل» / «هدوء أكثر».
- Daily reminder time (time picker, default 20:00).
- Primary: «جهّز برنامجي».

### 4.4 Result & Plan `/result`
- Big Clarity Score number + band label (from `bands`) + band text.
- 4 small area bars (Focus, Phone control, Sleep, Calm), no extra numbers.
- Card: «برنامجك: 30 يومًا · 4 مراحل» with the 4 week titles in a row.
- Primary: «ابدأ اليوم الأول (5 دقائق)» → opens `/session/1`.
- After Day 1 session completes → `/today`. Onboarding is marked complete **when the user lands on `/result`** (never show onboarding again after that, even if they quit before Day 1).

### 4.5 Today `/today` (home)
Top to bottom, nothing else:
1. Header: «مساء الخير، [name]» (or «أهلًا 👋»), gear icon (Settings) on the left side in RTL.
2. Row: streak flame + number · «اليوم X من 30» + thin progress bar (X/30, **not** reversed).
3. **Hero card — today's day:** week label (e.g. «الأسبوع 1 · الوعي»), lesson title, «~10 دقائق», primary button:
   - not started: «ابدأ يوم X»
   - in progress: «أكمل»
   - done today: card turns calm/green «أنجزت يوم X ✓ — اليوم التالي يفتح غدًا» + small «راجع درس اليوم».
   - Day locked behind Pro (day ≥ 8, not Pro): «افتح بقية البرنامج» → paywall.
4. **Today's challenge** card (from `challenge`), with a checkbox the user can tick any time during the day.
5. **SOS button** (always visible, full width, outlined): «عندي رغبة أفتح الموبايل» → `/sos`.
6. Evening only (after 18:00) and if day done: **Evening check-in** card (§4.8) if not yet done.
7. Small card: Clarity Score + «فحص الصفاء القادم: يوم 14».

### 4.6 Day session `/session/:n`
A 3-step player with a top progress bar (1/3, 2/3, 3/3) and a close (X) button. Leaving keeps progress.
1. **Lesson** — title, the 3 paragraphs, then the key idea in a highlighted box. Button «فهمت، التالي».
2. **Practice** — exercise from `practiceId`: title, "why" (2 lines), numbered steps, toggle «النسخة السهلة» (shows `easy`), and the right control by `mode`:
   - `steps`: checklist of steps; button «أنجزت التمرين».
   - `guided`: animated breathing circle / countdown for `guided_seconds`.
   - `timer` / `focus_timer`: big countdown, optional ambient sound picker (rain, waves, forest, white, brown), pause/stop; screen stays on.
   - If `input` is set: render the small input form (see §5.3) and save it.
   - Bonus exercise (`bonusId`), if present: small card «تمرين إضافي (اختياري)».
3. **Today's challenge** — show the challenge text with «سأفعلها اليوم» (accept). Then completion screen.
- **Completion screen:** check animation + light haptic, «أحسنت! أكملت يوم X» + key idea again + «العودة لليوم». If `clarityCheck: true` → before completion, run the Clarity Check re-check flow. If `graduation: true` → go to `/graduation`.
- **Clarity Check runs at most once per day.** Inside a session, the day flag `clarityCheck` decides; the exercise flag `triggers_clarity_check` is used only when `ex_week_review` is opened from Tools.
- **Skipping:** each step has «تخطَّ» (text button). A day counts as completed when the user finishes the lesson **and** either finishes the practice or uses the easy version. Skipping never removes points or shows guilt copy.

### 4.7 SOS `/sos` and `/sos/:flowId`
- Source: `sos.json`. **Always free.** One tap from Today.
- List of 4 big buttons (urge, bored, stressed, can't sleep). Each runs its steps:
  `text` (auto-advance after `seconds`, tap to skip), `rate` (1–10 slider), `breath` (animated circle using `pattern`; `double_sigh` = two inhales + long exhale; `dim_screen` lowers brightness via overlay), `show_why` (user's why statement from Day 7 or default), `suggest_replacement` (user's replacement list for that duration, else defaults).
- End screen: «أحسنت. مرّت الموجة.» + if rated: «من X إلى Y». Buttons: «العودة» / «ابدأ تمرين تركيز».
- Log each SOS use (date, flow, before/after) for Progress.

### 4.8 Evening check-in (bottom sheet, from Today or 21:00 notification)
- «كيف كان يومك مع الموبايل؟» 5 faces (1–5).
- «هل أنجزت تحدي اليوم؟» نعم / جزئيًا / لا.
- Today's `reflection` question + optional short note.
- Save. No score, no judgment.

### 4.9 Program `/program`
- 4 week sections (title + goal). Each shows its 7 days (week 4 shows 9: days 22–30) as tiles:
  done ✓ · today (highlighted) · locked (future) · Pro lock (≥ 8, not Pro).
- Tapping a done day → read-only review of the lesson + practice (`/program/day/:n`).
- Tapping a future day → small sheet «يفتح بعد إكمال يوم X».

### 4.10 Tools `/tools`
Sections:
1. **Focus timer** — presets 10 / 25 / 50 min (50 = Pro), ambient sounds, Do-Not-Disturb hint. Logs focus minutes.
2. **Breathing** — «التنهيدة المزدوجة» (free), «تنفّس 4-6» (Pro).
3. **Exercise library** — all 33 exercises grouped by `category`, filter chips by category. Free/Pro badge from `tier`. Locked → paywall.
4. **Brain games** — existing games, described neutrally: «تمارين ذهنية قصيرة وممتعة». No IQ, no "proven", no "intelligence".
5. **20-20-20 reminder** toggle (local notification every 20 min during chosen hours) — free.

### 4.11 Progress `/progress`
Only real data, no placeholders:
1. **Clarity Score** line chart (points at days 1/7/14/21/30) + latest value + change since Day 1.
2. **Estimated daily phone hours** (from `q_hours`) first vs latest.
3. **30-day calendar grid**: done / partially / missed / today / future.
4. Stats row: current streak · best streak · days completed · challenges done · focus minutes · SOS waves surfed.
5. **Evening mood** mini chart (last 14 days).
Empty state (before Day 1 is done): one card «أكمل يومك الأول لتبدأ رحلتك» + button to Today. Nothing else.

### 4.12 Settings `/settings`
Name · reminder time · evening check-in toggle · language · theme (dark/light) · biometric app lock · Premium status / restore purchases · privacy policy (URL from current app) · contact email `brainclean.app@gmail.com` · **Reset all data** (confirm dialog) · app version (from `AppConfig.appVersion`).

### 4.13 Paywall `/paywall?source=`
- Headline: «افتح البرنامج الكامل» / "Unlock the full program".
- Sub: «أكملت الأسبوع الأول. 23 يومًا من التغيير الحقيقي تنتظرك.» (when source = day7), generic otherwise.
- **Only real benefits:**
  - «أيام 8 إلى 30 كاملة: البيئة، البدائل، والتثبيت»
  - «كل التمارين في الأدوات (33 تمرينًا)»
  - «جلسات تركيز 50 دقيقة وتنفّس 4-6»
  - «فحص الصفاء ومتابعة تقدّمك حتى يوم 30»
- Plans from RevenueCat offerings (monthly, yearly with "save X%"). Show price from the store, never hard-coded.
- Footer: «إلغاء في أي وقت من Google Play» · Restore purchases · Terms/Privacy links.
- **Free forever:** Days 1–7, SOS, Clarity Check, focus timer 10/25, double sigh, 20-20-20, brain games, evening check-in.

### 4.14 Graduation `/graduation` (Day 30)
Day-1 vs Day-30 Clarity Score (big), phone hours before/after, days completed, the user's Day-7 letter (if written), then «اكتب قواعدك» (links to maintenance rules if not done), share card button, «ماذا بعد؟» → keep using Tools + monthly Clarity Check reminder.

### 4.15 Letter `/letter`
Shows the saved future letter (from Day 7 bonus) — reachable from Graduation and Settings → «رسالتي».

---

## 5. Content & data

### 5.1 Content files (bundled assets)
`assets/content/program.json`, `exercises.json`, `clarity_check.json`, `sos.json`.
- Each text is `{ "ar": "...", "en": "..." }`. A `ContentRepository` loads them once, picks the current locale, falls back to `en`.
- **UI labels** (buttons, titles) go in ARB. **Long content** stays in JSON. Adding a new language later = add a key per text object (`"es"`, `"fr"`…), no code change.
- Add a test that every text object has both `ar` and `en`, every `practiceId`/`bonusId` exists, days 1–7 use `tier: free` exercises, and days are exactly 1..30.

### 5.2 Local data (Hive, encrypted box `v3_state`)
```
UserProfile { name?, goal, reminderTime, eveningCheckIn: bool, onboardingDone: bool, createdAt, locale }
DayProgress  { day, startedAt?, lessonDone, practiceDone, usedEasy, challengeAccepted, challengeDone?, completedAt? }
ClarityResult { takenAt, programDay, score, areas{focus,control,sleep,calm}, hoursEstimate, answers{} }
EveningCheckIn { date, mood 1..5, challenge: yes|partly|no, note? }
SosLog { at, flowId, before?, after? }
FocusLog { at, minutes, completed }
UserInputs { screenAudit?, triggers[], whyStatement?, replacements{5:[],15:[],60:[]}, ifThen[], relapsePlan?, identity?, rules[], futureLetter? }
```

### 5.3 Inputs per `input` key
`screen_audit` (hours + 3 apps + pickups), `trigger_pick` (multi-select of 5 feelings), `urge_rating_before_after`, `time_pick`, `why_statement` (text), `replacement_list` (3 lists of up to 3), `if_then` (up to 3 pairs), `relapse_plan`, `identity_statement`, `maintenance_rules` (up to 3), `future_letter` (multiline), `week_review` (3 short texts + triggers Clarity Check).

### 5.4 Program rules
- `currentDay` = number of completed days + 1 (max 30).
- **One new day per calendar day:** after completing day X, day X+1 unlocks at the user's local midnight. Missing days doesn't reset anything; the user simply continues.
- **Streak** = consecutive calendar days with a completed program day. **One free "rest day" per 7 days** keeps the streak (no UI guilt, just «يوم راحة ✓»).
- Clarity Check runs at onboarding (Day 1 baseline) and on days with `clarityCheck: true` (7, 14, 21, 30).
- After Day 30: program stays readable; Today shows «أكملت البرنامج 🎉» + Tools + a monthly Clarity Check reminder; offer «أعد البرنامج» (resets DayProgress only, keeps history).

### 5.5 Migration from current users (2.0.x)
On first V3 launch: if old Hive boxes exist, show one screen «Brain Clean أصبح أبسط وأقوى. برنامج جديد بانتظارك» → normal onboarding. Do not import old scores. Premium status comes from RevenueCat (unchanged). Then delete old boxes.

---

## 6. Behavior details

### 6.1 Notifications (local)
- Daily reminder at `reminderTime`: «يومك X جاهز — 10 دقائق فقط» (only if today not done).
- Evening check-in 21:00 if enabled and not done: «كيف كان يومك مع الموبايل؟»
- Re-check days: «اليوم فحص الصفاء — شاهد تقدّمك».
- Never: guilt, "you lost", streak-loss threats, more than 2 notifications a day.

### 6.2 Haptics & motion
Light haptic on completing a step/day, check animation on completion, breathing circle animation. Respect "reduce motion".

### 6.3 Accessibility
48dp targets, text scales to 130% without overflow, RTL/LTR correct, semantics labels on icons. Accessibility alternatives are semantics only, **never visible copy**.

### 6.4 Share card (Day 7, 14, 30)
Simple image: app mark + «أكملت X يومًا من برنامج الصفاء» + Clarity change. Uses `share_plus`. No personal answers.

---

## 7. Monetization

- Free: Days 1–7 + everything listed in §4.13 "Free forever".
- Paywall moments: (a) after Day 7 completion screen, once; (b) tapping any Pro lock; (c) Settings. Never during SOS, never mid-session.
- **Recommended prices (change in Play Console):** monthly **19 SAR**, yearly **149 SAR**, with a **7-day free trial** on yearly. Current 49/399 SAR is high for the target audience and makes the paywall harder. (Prices are set in Play Console; the app reads them from RevenueCat.)
- No ads in V3. (If ads are added later: one banner on Tools/Progress for free users only, never in sessions or SOS, with UMP consent, and the Data safety form must be updated.)

---

## 8. Copy rules
- Simple Modern Standard Arabic everywhere. No dialect words (مو، عشان، ليش، ازاي…).
- Second person, warm, short sentences. Max 2 lines for any helper text.
- Banned words/claims: علاج، شفاء، تشخيص (except "ليس تشخيصًا")، IQ، ذكاء (as a measured trait)، مثبت علميًا، تلف دماغي، يزيد الذكاء، cure, treat, diagnose, proven, IQ, intelligence, brain damage.
- Allowed phrasing: «تشير دراسات إلى…», «كثيرون يلاحظون…».
- Numbers: Western digits (0-9) in both languages for consistency.

---

## 9. Visual design
Keep the current dark theme (`#0B0B0B` background, mint `#2ED3A6`-family accent, gold for Pro) and fonts. Rules:
- One accent color per screen for the primary action. Gold only for Pro.
- Cards: 20px radius, 16px padding, 12px gap. Page padding 20px.
- Type: H1 28/34 bold, H2 22/28 bold, body 16/24, caption 13/18.
- Light theme must also look correct (all colors from `AppPalette`).

---

## 10. Quality gates (must pass before release)
- `flutter analyze` clean, `flutter test` green.
- New tests: content integrity (§5.1), Clarity scoring (formula + reverse items + bands), program rules (unlock at midnight, streak + rest day, currentDay), onboarding never re-shows after `/result`, Pro gating (day 8+ locked when not Pro, SOS never locked), paywall shows only the 4 real benefits.
- Golden/smoke: Today in AR and EN, session player each `mode`, SOS flow, Progress empty + filled.
- Manual device test on a release build (R8 on): purchase sheet opens with prices, restore works, notifications fire, sounds play, no text overflow.

---

## 11. Not in V3 (later, separate decisions)
- Safa AI chat (needs Supabase restored + `SUPABASE_*` dart-defines + privacy/Data-safety update). Hidden completely in V3.
- Real screen-time via Usage Access permission.
- Home-screen widget.
- More languages (content structure already supports it).
