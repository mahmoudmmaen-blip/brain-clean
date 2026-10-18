# C02 — Onboarding v2 + one-time trial offer + "trial ends" screen

Build: **no**
Commit message: `v3: onboarding v2, one-time trial offer, trial-ending notice`
Spec: §4.1–4.4 + PLAN items 3 and 4. Depends on C01 (trial passthrough).

## 1. Onboarding changes
- Screen-time question is the FIRST question (confirm order; fix if not).
- Clarity re-checks (days 7/14/21/30): shuffle the 8 items with a seed from the check date (baseline keeps the file order). Scoring unchanged.
- Setup: REMOVE the name field (name is asked later in Settings/letter). Keep goal chips + reminder time.
- Result: add the reframe card under the score: «تقضي حوالي X ساعات يوميًا = نحو Y يومًا كاملًا في السنة» / "About X h a day = about Y full days a year", Y = round(hours × 365 / 24). Use the screen-time answer.

## 2. One-time trial offer (after Result, before Day 1)
- New screen `lib/v3/ui/paywall/trial_offer_screen.dart`, route `/offer`. Shown ONCE per install (flag in v3 box), only if: not Pro, store configured, yearly offering has `trialConfirmed`. Otherwise skip straight to `/session/1`.
- Layout: «ابدأ قويًا من اليوم الأول» · «جرّب البرنامج كاملًا 14 يومًا مجانًا، ثم X سنويًا» (period + price from store) · yearly card only · CTA «ابدأ 14 يومًا مجانًا» · equal-size text button «أتابع بالنسخة المجانية» · billing line + restore.
- Both buttons continue to `/session/1`. Purchase uses the same PremiumController.

## 3. "Trial ends soon" notice
- Read RevenueCat CustomerInfo for entitlement `Brain Clean`: if `periodType == trial` and expiration is within 48 h → show ONCE (per trial) a bottom sheet on Today: «تجربتك تنتهي بعد يومين» + user's numbers (days practiced, urges beaten) + «سيُخصم X في تاريخ Y» (price from store, date from expiration, local format, Western digits) + buttons «متابعة» and «إدارة الاشتراك» (Play subscriptions page).
- Expose this through a small provider (`trialStatusProvider`) so it is testable with a fake.

## Tests — `test/v3/onboarding_trial_test.dart`
first question is screen time; no name field on setup; result reframe 6 h → 91 days; re-check order differs from baseline but scores match for the same answers; offer shown once then never; offer skipped when Pro / no trial / store not configured; trial-ending sheet appears at < 48 h, not at 5 days, and only once.
