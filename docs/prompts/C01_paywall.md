# C01 — Paywall that sells honestly (purchase, trial, restore)

Build: **no**
Commit message: `v3: paywall with real purchase, 14-day yearly trial, personal day-7 header`
Spec: §4.13, §7 + PLAN_AFTER_REVIEW items 5 and 8.

## Starting point (already on disk, uncommitted — CONTINUE, do not rewrite)
- `lib/v3/ui/paywall/v3_paywall_screen.dart` (uses `premiumControllerProvider`, `hydrate`, `purchaseSelected`, `restore`, `selectProduct`) and `lib/v3/ui/paywall/paywall_price_math.dart`, plus new `v3Paywall*` ARB keys.
- Purchase layer to REUSE: `lib/features/v2_premium/**`, `lib/features/pro/**` (`SubscriptionService`, `isProUserProvider`).

## 1. Trial passthrough (store → offering)
- `SubscriptionPremiumStorePort.loadOfferings()` currently forces `trialConfirmed: false`. Extend `SubscriptionService.loadOfferings()` / its plan model to carry the RevenueCat Google `defaultOption` free phase (`storeProduct.defaultOption?.freePhase?.billingPeriod`, e.g. `P2W`). If a free phase exists → `trialConfirmed: true`, `trialLabel` = localized «14 يومًا مجانًا» / "14 days free" built from the real period (days = ISO period parsed; never hard-code 14). Otherwise unchanged.
- Purchase stays `purchasePlan(productId)`; RevenueCat applies the default option (the trial) automatically.

## 2. Paywall layout (top → bottom), one `SingleChildScrollView` + CTA pinned in a bottom `SafeArea` bar
1. Close **X** top-start, appears after 2 seconds (visible, normal size). No countdowns or hidden close.
2. **Personal header** (only when `source == day7` or `locked_day`): title «أسبوع كامل من التدريب» + up to 3 chips from REAL local data:
   - «X أيام تدريب» (completed days), «X رغبات تجاوزتها» (SosLog where after < before, or completed flows), and — only if usage data exists (C05) — «ساعات الموبايل: من A إلى B».
   - Under the chips, small: «فحص الصفاء: من 42 إلى 58» (first vs latest ClarityResult) if ≥ 2 results.
   - If no data at all → show only the days chip. Never show zero-value chips.
   Other sources: headline «افتح البرنامج الكامل» / "Unlock the full program".
3. One line: «الأسبوع الأول كان للوعي. الأسابيع الثلاثة القادمة للتغيير الفعلي.» (day7 only).
4. EXACTLY 3 benefits (ARB AR+EN):
   1. «أيام 8 إلى 30 كاملة: البيئة، البدائل، والتثبيت»
   2. «جلسات تركيز 50 دقيقة وتنفّس 4-6»
   3. «فحص الصفاء في الأيام 14 و21 و30 ومقارنة تقدّمك»
   (No SOS, no exercise library, no brain games.)
5. Plans from the store: yearly (preselected, visually primary) → monthly → lifetime. Price text = store `priceString`. Yearly shows «وفّر X%» (from real monthly vs yearly, hide if a price is missing), «≈ X شهريًا» (yearly ÷ 12 inserted into the store price format; hide if parsing fails), and the trial badge only if `trialConfirmed`.
6. CTA: trial confirmed & yearly selected → «ابدأ 14 يومًا مجانًا» (period from store) with small line «لن يُخصم أي مبلغ قبل نهاية التجربة · إلغاء في أي وقت من Google Play». Otherwise «اشترك».
7. Footer: «استعادة المشتريات» · Privacy (external browser, URL already in code/ARB) · Terms.
- States: loading (spinner on CTA, disabled), error (friendly + retry), cancelled (silent), pending (message), success → Pro true → pop (or go `/today`).
- Offerings empty/failed → «تعذّر تحميل الأسعار الآن» + «حاول مرة أخرى». Already Pro → «أنت مشترك ✓» + «إدارة الاشتراك» (Play subscriptions page).
- Use theme colors (`AppColors.of(context)`), not hard-coded dark colors. Works in light + dark, RTL + LTR, text scale 1.3.
- Never shown during SOS or mid-session; day-7 trigger only from the completion screen, once.

## Tests — `test/v3/paywall_test.dart` (fake store port)
exactly 3 benefits and none mentions SOS; prices come from fake offerings (grep: no "19", "99", "149", "249" literals in lib/v3 paywall code); savings % for monthly "19.00 SAR" / yearly "99.00 SAR" = 57 and «≈ 8.25»; trial badge + trial CTA only when trialConfirmed; purchase success → Pro → day 8 unlocked (ProgramEngine); cancel → no error; restore → Pro; offerings fail → retry; already Pro state; day7 header shows real counts and hides zero chips; close X appears after 2 s.

## Do NOT
Change ids/keys/build script. Touch Program/Progress/Settings.
