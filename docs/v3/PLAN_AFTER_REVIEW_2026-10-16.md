# Brain Clean V3 — Final plan after 3-round review (Claude × Kimi K3, 16 Oct 2026)

This overrides older notes where they conflict. Convert each V3.0 item into a P-task before coding.

## V3.0 — must ship (ordered by impact)
1. Real usage data (opt-in): Android UsageStatsManager, on-device only. Ask at first Progress-tab open; re-ask once after first SOS where urge drops ≥ 2. Max 2 asks. Self-report stays as fallback.
   Copy (AR): «لنعرض لك ساعات استخدامك الحقيقية بدلًا من التقدير، نحتاج إذن «الوصول إلى بيانات الاستخدام» من إعدادات الهاتف. بياناتك تبقى على جهازك فقط، ولا تُرسَل إلى أي مكان.» Buttons: «فتح الإعدادات» / «لاحقًا».
   Store listing: add one line about screen-time tracking. Data Safety stays "not collected".
2. Week 1 early wins: notification audit Day 9 → Day 4, home-screen cleanup Day 8 → Day 5 (both tier free). Pause-breath → Day 9, attention anchor → Day 8 (tier pro). Update content_integrity_test.
3. Onboarding: screen-time question first; 8 items kept (shuffled on re-checks); Result reframe «حوالي X ساعات يوميًا = نحو Y يومًا في السنة على الموبايل» (Y = round(hours*365/24)); name field removed (asked in the letter).
4. Onboarding trial offer: shown once after Result, dismissible full step. Yearly only, 14-day free trial offer (so trial covers Week 2 Pro content). CTA «ابدأ 14 يومًا مجانًا» + equal-weight «أتابع بالنسخة المجانية».
   Mandatory: Day 12 in-app screen «تجربتك تنتهي بعد يومين» with user's stats + exact charge date and amount.
5. Day 7 paywall: header chips with app-measured numbers (days practiced, urges beaten, real hours if granted «من 6.2 إلى 5.1 ساعة»), Clarity «من 42 إلى 58» as support. Line: «الأسبوع الأول كان للوعي. الأسابيع الثلاثة القادمة للتغيير الفعلي.» 3 benefits (see C01) — NOT SOS (always free), NOT exercise library. Yearly preselected with trial badge. DECISION (Claude, 16 Oct): ONE trial offer only — 14 days on yearly — used both at onboarding and Day 7 (simpler Play config, trial covers Pro weeks). Visible X after 2 s. No dark patterns.
6. SOS v2: bored flow starts with the user's replacement deck (breathing optional); after 23:00 sleep flow first + dim UI; second rating one tap; shareable «من 8 إلى 4» card.
7. Today hierarchy: one primary button (today's session), persistent SOS button, evening check-in as a fixed slot that changes state, everything else below.
8. Pricing (Play per-country, RevenueCat current offering, nothing hardcoded):
   SA/Gulf 19 SAR/mo · 99 SAR/yr · 249 SAR lifetime | EG 99 EGP/mo · 399 EGP/yr · 999 EGP lifetime | RoW $4.99 · $29.99 · $69.99. Trial on yearly only (14 days).
9. Progression: missed days never reset; hero metric = «أيام التدريب» (count); streak small; 1 rest day / 7. No parallel days.
10. RTL/Arabic polish: keep bundled Tajawal (Arabic) + Inter (decision: no font swap, Tajawal is already a proper Arabic face); week starts Saturday for AR locales; RTL-correct charts/arrows; Western digits; «من X إلى Y».
11. In-app review (Play In-App Review): after first SOS win or Day 3 completion; never on paywall day.
12. Encrypted backup export/import in Settings (share sheet). Brain games hidden.

## V3.1 (ship within 3–4 weeks of launch, before anyone reaches Day 31)
- Maintain mode after Day 30: weekly challenge (12 below, each with a base + hard variant; hard after first cycle), monthly Clarity Check, monthly real-usage comparison, ONE weekly notification.
- Track 2 by goal ("Deep Focus" / "Better Sleep") — do not promise it on the paywall or store before it ships.
- Reminder presets «بعد الفجر / بعد العمل / بعد العشاء» as labels for custom times.
- Egypt intro price experiment via RevenueCat.

## Later
Ramadan mode (before ~8 Feb 2027) · backend/account sync only if data justifies · Track 3+.

## 12 Maintain challenges (review copy before use)
1 صباح بلا شاشة — no phone first 30 min after waking, 5 days.
2 وضع رمادي مسائي — grayscale after 21:00 daily.
3 أبعِد تطبيقًا عن الشاشة الرئيسية — remove your #1 trigger app from home screen.
4 وجبات بلا موبايل — every meal with phone in another room.
5 مكالمة بدل التصفح — replace 3 evening scroll sessions with a call.
6 الموبايل ينام خارج الغرفة — charge outside the bedroom, 4 nights.
7 جلسة تركيز يومية — one 20-min focus session, 5 days.
8 تنبيهات من البشر فقط — keep only notifications from real people.
9 مشي بعد العشاء — 15-min walk after dinner, 4 days.
10 تصفح مقصود — scrolling only in one planned 15-min window per day.
11 نصف يوم بلا اتصال — half a day offline at the weekend.
12 مراجعة المحفزات — write top 3 triggers + one counter-move each.

## Open disagreements
- Backup export won't stop reinstall churn (Kimi: <10% export). Kept as cheap safety net.
- 8 vs 6 Clarity items: keep 8 now, A/B test 6 when volume allows.
- Lifetime wording: "all current features + tracks released in the first year" (no open-ended promise).

## Estimates (Kimi, final plan)
D7 8–11% · D30 2.5–4% · install→paid 2–3% · month-2 renewal 50–60% (with Maintain) · rating 4.3–4.6 · P(1,000 payers in 12 months, no ads) ≈ 20% (needs ~40k installs).
