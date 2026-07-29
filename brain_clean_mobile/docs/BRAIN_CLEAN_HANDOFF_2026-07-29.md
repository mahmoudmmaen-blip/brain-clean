# Brain Clean — Project Handoff

**Generated:** 2026-07-29 09:50 +03:00  
**Repository:** https://github.com/mahmoudmmaen-blip/brain-clean  
**Flutter project:** rain_clean_mobile/  
**Branch:** $branchExpected  
**Current version:** 1.2.3+16  
**AppConfig version:** 1.2.3  
**Latest implementation commit before this handoff:** $latestCommit  
**Commit subject:** Bump version to 1.2.3+16 for production candidate

## 1. Product

Brain Clean is an Arabic-first digital wellbeing and daily recovery companion for users experiencing distraction, mental fog and excessive digital use. It is not a medical diagnosis or treatment app.

North Star: **Daily Program**.

Daily Program steps:

1. Start of day
2. Water
3. Movement
4. Stillness
5. Single-focus task
6. Mood
7. Optional journal
8. Day close

The app is local-first, does not require an account, supports Arabic RTL and English, and uses a calm non-punitive experience.

## 2. Main navigation

Five main tabs:

- Home
- Exercises
- Safa
- Journey
- More

## 3. Current implementation

- Flutter + Riverpod + GoRouter.
- Hive local encrypted storage.
- RevenueCat monthly/yearly Pro subscriptions.
- Pro removes all ads.
- Google AdMob banner ads only.
- No interstitial, rewarded, app-open or native ads.
- UMP consent gating implemented.
- Ads are excluded from sensitive routes.
- Daily Program core remains free.
- Privacy Policy is live.
- No account and no cloud sync in the current release.

## 4. Safa

The Internal Testing build 14 (1.2.1) failed to connect Safa because the AAB was built without:

- SUPABASE_URL
- SUPABASE_ANON_KEY

The client was hardened in commit e882a96.

Build 15 (1.2.2) was rebuilt successfully with:

- Supabase Project URL
- Supabase publishable key
- RevenueCat public Android SDK key
- AdMob Android App ID
- AdMob banner unit ID

Do not include server secrets in Flutter. CLAUDE_API_KEY remains server-side in the Supabase Edge Function.

Edge Function:

- safa-chat

## 5. Google Play status

- Internal Testing active.
- Current tested release: 15 (1.2.2).
- Production access request: under review in the last confirmed Play Console screenshot.
- Production was still inactive.
- Do not assume Production access is approved until Play Console confirms it.
- Build 16 (1.2.3) is the next production candidate.
- Upload build 16 to Internal Testing and test it before promoting to Production.

## 6. Ads and privacy

Banner ads may appear only on normal free routes such as Home, Exercises, Journey and More.

Ads must not appear in:

- Daily Program
- Safa
- Emotion or worry flows
- Focus/calm flows
- Day close
- Pro paywall
- Any sensitive intervention screen

Do not click live ads during testing.

Public policy URL:

https://mahmoudmmaen-blip.github.io/brain-clean/privacy-policy/

Contact:

brainclean.app@gmail.com

## 7. Required runtime build values

Required at release build time:

- SUPABASE_URL
- SUPABASE_ANON_KEY — publishable/anon client key only
- REVENUECAT_API_KEY — public Android SDK key only
- ADMOB_ANDROID_APP_ID
- ADMOB_ANDROID_BANNER_AD_UNIT_ID

Never commit or paste:

- Supabase service_role
- Supabase sb_secret_
- AI provider secrets
- RevenueCat secret API keys

No real values are included in this handoff.

## 8. Git rules

- Work only inside rain_clean_mobile/.
- Use branch 1.2-safe-ads-rc.
- Do not modify root lib/.
- Do not merge to main automatically.
- Do not change signing or application ID.
- Do not change Daily Program behavior without a separate plan.
- Restore macos/Flutter/GeneratedPluginRegistrant.swift if Android builds modify it automatically.
- Every uploaded AAB requires a new version code.

## 9. Checks

Known focused checks:

- lutter analyze has 0 errors and 98 pre-existing warnings/info.
- App config tests: 7 passed.
- Safa tests: 11 passed.
- Ads tests: 18 passed.
- Local monetization tests: 8 passed.
- Daily Program tests: 11 passed.

When running analyze for the release helper, use:

lutter analyze --no-fatal-warnings --no-fatal-infos

Warnings must be recorded, but only real errors should stop this production candidate.

## 10. Next steps

1. Confirm build 16 (1.2.3) completes successfully.
2. Push this branch and handoff document to GitHub.
3. Upload build 16 to Internal Testing.
4. Install from Google Play and verify version 1.2.3.
5. Test Safa first.
6. Test Free ads and sensitive-route exclusions.
7. Test Pro purchase and Restore Purchases.
8. Confirm Data Safety, Ads declaration and Advertising ID status.
9. Wait for Production access approval.
10. Promote only after Internal Testing passes.

## 11. Prompt for the next chat

Read docs/BRAIN_CLEAN_HANDOFF_2026-07-29.md first.

Continue from branch 1.2-safe-ads-rc and version 1.2.3+16.

Do not rebuild the product plan from scratch. First verify:

- latest Git commit
- working tree status
- Internal Testing status
- Production access status
- whether build 16 has been tested on a real Android device

Give one practical next step at a time.
