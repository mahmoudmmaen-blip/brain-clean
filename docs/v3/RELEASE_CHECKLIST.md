# Brain Clean 3.0.0 — Release checklist (manual device)

Use a **release** build (R8 on) via `build_release.ps1` / Internal app sharing.

## Fresh install
- [ ] Install on a clean device (or clear app data).
- [ ] Splash → Welcome (`/welcome`).
- [ ] Language switch AR ↔ EN on Welcome works; layout RTL/LTR correct.

## Onboarding
- [ ] Clarity Check: intro → screen-time → 8 questions, one per screen, tap advances.
- [ ] Setup: name optional, goal, reminder time, evening check-in toggle.
- [ ] Result & Plan shows Clarity Score band + Start Day 1.
- [ ] Completing Result does **not** re-show Welcome on relaunch (goes to Today).

## Day 1 session
- [ ] Today: streak bar, hero “not started”, challenge checkbox, SOS, Clarity card.
- [ ] Open session: Lesson → Practice → Challenge; progress at top; X keeps progress; تخطَّ works.
- [ ] Easy version toggle completes the day.
- [ ] Completion animation + haptic; next day unlocks only after midnight.

## SOS
- [ ] SOS opens from Today without Pro gate.
- [ ] Flow completes; never opens paywall mid-SOS.

## Focus timer + sound
- [ ] Tools → Focus (or session focus_timer): big countdown.
- [ ] Ambient sound picker plays rain/waves/forest/white/brown noise.
- [ ] Screen stays awake during timer.

## Paywall
- [ ] After Day 7 completion (non-Pro): paywall once with `source=day7`.
- [ ] Day 8+ locked hero → `/paywall?source=locked_day`.
- [ ] Settings → Pro → paywall; **prices** load from RevenueCat (monthly/yearly/lifetime).
- [ ] Purchase sheet opens; Restore purchases works; entitlement `Brain Clean` unlocks days 8–30.

## Notifications
- [ ] Daily reminder only if today not done.
- [ ] Evening 21:00 only if evening check-in enabled.
- [ ] Max 2 notifications/day; changing settings reschedules.

## Relaunch / themes / locales
- [ ] Kill app → reopen lands on Today (if onboarded).
- [ ] Biometric lock (if enabled) gates resume.
- [ ] Switch AR and EN across Today + session; no overflow.
- [ ] Light and dark themes: text contrast OK, primary CTA readable.

## Regression spot-checks
- [ ] Reset all data from Settings returns to onboarding.
- [ ] Privacy policy link opens.
- [ ] No banned medical / IQ / dialect copy on visible screens.
