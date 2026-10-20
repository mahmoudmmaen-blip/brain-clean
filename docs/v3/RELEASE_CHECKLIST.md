# Brain Clean 3.0.0 — Release checklist (manual device)

Use a **release** build (R8 on) via `build_release.ps1` / Internal app sharing.

## Fresh install
- [ ] Install on a clean device (or clear app data).
- [ ] Splash → Welcome (`/welcome`).
- [ ] Language switch AR ↔ EN on Welcome works; layout RTL/LTR correct.
- [ ] If upgrading from V2: one-time migration screen → Welcome; Pro entitlement unchanged.

## Onboarding (C02)
- [ ] Clarity Check: screen-time first → 8 questions (shuffled on re-checks), one per screen.
- [ ] Setup: goal, reminder time (name asked later in letter, not here).
- [ ] Result & Plan: Clarity band + phone-hours reframe «حوالي X ساعات…» + Start Day 1.
- [ ] Trial offer after Result when store configured and not Pro (skip / start trial).
- [ ] Completing Result does **not** re-show Welcome on relaunch (goes to Today).

## Today / Session (C04)
- [ ] Today hierarchy: one primary session CTA, persistent SOS, evening slot states (locked/open/done).
- [ ] Days practiced + streak; goal tip card; no brain-games section on Tools.
- [ ] Session: Lesson → Practice → Challenge; progress bar; X keeps progress; easy toggle.
- [ ] Completion: medium haptic; Day 3 may show in-app review (internal testing track).
- [ ] Next day unlocks only after local midnight.

## Content days 4–5 (PLAN / C03–C04)
- [ ] Day 4: notification-audit practice (free tier).
- [ ] Day 5: home-screen cleanup practice (free tier).

## SOS (C03)
- [ ] SOS hub free for everyone; never paywalled.
- [ ] Flows include bored + night; urge before/after; win can show share card.
- [ ] Never opens paywall mid-SOS.

## Share card (C03)
- [ ] Day milestone share (7/14/30) and SOS win share open share sheet; no personal answers/name.

## Paywall (C01)
- [ ] After Day 7 completion (non-Pro): paywall once with `source=day7` + personal header chips.
- [ ] Day 8+ locked hero → `/paywall?source=locked_day`.
- [ ] Settings → Subscribe / Manage / Restore; prices from RevenueCat only.
- [ ] Entitlement `Brain Clean` unlocks days 8–30; SOS never listed as paid benefit.

## Trial-ending sheet (C02)
- [ ] With a license tester near trial end (≤48h): once-per-trial sheet on Today; manage/restore CTAs.

## Usage access (C06)
- [ ] Progress ask #1 (after Day 1): sheet → Open settings / Later.
- [ ] Ask #2 only after declined #1 + SOS win (urge drop ≥ 2); never a 3rd ask.
- [ ] With access: UsageSummaryCard shows yesterday / 7-day / «من A إلى B»; without access: self-report only, no nag.
- [ ] Day-7 paywall hours chip only when real usage from/to available.

## Program / Progress (C05)
- [ ] Program: 4 weeks, day tiles (done / today / future / Pro lock).
- [ ] Progress: clarity/hours charts, calendar, stats, mood; empty state has CTA.

## Settings / Graduation / Backup (C07)
- [ ] Settings: name, reminder, evening toggle, AR/EN, dark/light, biometric, usage enable, Pro, backup, letter (if any), privacy, contact, reset, version `3.0.0`.
- [ ] Backup export → `.bcb` share; import with passphrase; wrong passphrase leaves data unchanged.
- [ ] Reset clears v3 data → Welcome; Pro entitlement unaffected.
- [ ] Graduation (Day 30): clarity/hours/days/letter/rules/share/«ماذا بعد؟».
- [ ] Letter read-only + optional name prompt.

## After Day 30 (C08)
- [ ] Today: «أكملت البرنامج» + Tools + monthly Clarity Check + Restart (DayProgress only; Clarity history kept).

## Notifications (C08)
- [ ] Daily reminder only if today not done («يومك X جاهز — 5 دقائق فقط»).
- [ ] Evening 21:00 if enabled and not done.
- [ ] Clarity re-check days 7/14/21/30 replace daily copy when due.
- [ ] Max 2/day (20-20-20 excluded); reschedule on settings change / day complete / app start.

## Focus timer + sound
- [ ] Tools → Focus: countdown; ambient rain/waves/forest/white/brown; screen stays awake.

## Locales / themes / a11y
- [ ] Kill app → reopen lands on Today (if onboarded).
- [ ] Biometric lock (if enabled) gates resume.
- [ ] Switch AR and EN across Today + session + paywall + progress; Western digits 0-9.
- [ ] Light and dark themes: contrast OK, primary CTA readable.
- [ ] Text scale ~130% on a small phone (≈360×640): no overflow on Today / Session / Paywall / Progress.
- [ ] Icon-only buttons have tooltips/semantics; tap targets ≥ 48×48.

## Regression spot-checks
- [ ] Reset all data from Settings returns to onboarding.
- [ ] Privacy policy + contact links open.
- [ ] No banned medical / IQ / dialect copy on visible screens.
- [ ] Package `com.brainclean.mobile`; version name `3.0.0` / code `37`.
