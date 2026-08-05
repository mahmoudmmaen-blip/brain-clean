# Production Day Checklist

Execute **only after** Google Play enables production access / “Apply for production” is available and you intend to publish.

**Do not run this checklist prematurely.** Closed Testing `2.0.1+18` is not Production.

---

## A. Eligibility

- [ ] Confirm production-access waiting period is complete in Play Console
- [ ] Confirm **Apply for production** (or equivalent) is unlocked
- [ ] Confirm Closed Testing retained **≥12** opted-in testers for the required duration as Play displays it
- [ ] Confirm package is still `com.brainclean.mobile`
- [ ] Confirm the candidate version code is intentional (`18` or a newer bumped code)

---

## B. Console health and declarations

- [ ] Review Android Vitals (crashes / ANRs) for Closed Testing cohort
- [ ] Review pre-launch report findings; resolve launch blockers
- [ ] Verify **Data Safety** form matches shipped behavior
- [ ] Verify **App Access** instructions (if login/gated areas exist)
- [ ] Verify **Ads** declaration (V2 root currently ships **without** root AdMob integration — keep declaration truthful)
- [ ] Verify **Content Rating** questionnaire completeness
- [ ] Verify privacy-policy URL loads and matches listing

---

## C. Monetization readiness

- [ ] Play subscriptions active for Monthly / Annual
- [ ] RevenueCat products linked for Android package `com.brainclean.mobile`
- [ ] Entitlement + offering reviewed in RevenueCat dashboard
- [ ] Public SDK key available in secure build environment only
- [ ] No secret keys committed in Git

---

## D. Create Production release

- [ ] Create Production release in Play Console
- [ ] Promote / add the approved signed bundle
- [ ] Verify version name + version code on the release
- [ ] Review countries / pricing / tax settings
- [ ] Complete release notes (see `docs/RELEASE_NOTES_2.0.1.md` DRAFT → finalize)
- [ ] Submit for review
- [ ] Wait for Google review decision

---

## E. Post-approval validation

- [ ] Confirm Production availability in target countries
- [ ] Fresh install from **Production** (not sideload)
- [ ] Confirm installer is Play
- [ ] Smoke: onboarding / Today / session / Progress / Weekly Review (as applicable)
- [ ] Sandbox or licensed test **purchase** Monthly
- [ ] **Restore** path on reinstall / second session
- [ ] Confirm Free core remains usable without purchase
- [ ] Monitor crashes and ANRs for 24–72 hours

---

## F. Git closure after Production approval only

- [ ] Create annotated production Git tag **only after** Production approval / availability  
  Example shape: `v2.0.1+18-play-production` (exact name operator choice)
- [ ] Update `docs/VERSION_HISTORY.md` with Production row
- [ ] Update `docs/FINAL_RELEASE_STATUS.md` state away from `PRODUCTION_PENDING_GOOGLE_PLAY`
- [ ] **Do not** tag before approval

---

## G. Hard stops

Stop and do **not** publish if:

- Package id mismatches Play app
- Signing identity is wrong / new unexpected key without Play process
- Data Safety / privacy policy mismatch
- Subscriptions not active
- Vitals shows unmanaged crash storm
- Review rejected without remediation
