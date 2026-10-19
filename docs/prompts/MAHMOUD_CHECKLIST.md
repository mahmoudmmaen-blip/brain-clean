# What only Mahmoud does (Play Console / RevenueCat) — not code

Before C09 build:
1. Play Console → Monetize → Subscriptions → yearly (`brainclean_yearly`) base plan → add ONE offer: free trial **14 days**, eligibility "new customer acquisition". Activate.
2. Prices per country (base plans + lifetime in-app product):
   - Saudi Arabia: 19 SAR / 99 SAR / 249 SAR · Other Gulf: equivalent via Play conversion, then round.
   - Egypt: 99 EGP / 399 EGP / 999 EGP.
   - Rest of world (USD base): $4.99 / $29.99 / $69.99.
3. RevenueCat: check the current offering has monthly, annual, lifetime packages (no code change needed for price changes).
4. License testers: add your test Gmail to test trial + "trial ends" sheet.

At release:
5. Store listing: use docs/store/STORE_LISTING.md (includes the screen-time line). Screenshots on Arabic UI.
6. Data safety: no change (usage data stays on device = not collected). If Play asks about PACKAGE_USAGE_STATS, answer: digital wellbeing — shows the user their own screen time on-device.
7. Make the GitHub repo private (recommended earlier).
