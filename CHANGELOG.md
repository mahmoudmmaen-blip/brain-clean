# Changelog

All notable release versions for Brain Clean (mobile) are summarized here.

Format notes:

- Version line uses Flutter `versionName+versionCode` (example: `2.0.1+23`).
- Entries describe **completed, verified** work only.
- Google Play **Production** claims are listed only after Production publication (none yet for V2).

---

## 2.0.1+23

**Status:** Current Android binary in `pubspec.yaml` (not Production; Play ingest of this code not claimed)  
**Package:** `com.brainclean.mobile`  
**Branch baseline:** `main`

### Why this version code

- Closed Testing `2.0.1+18` was not V2-qualified (store install landed on Legacy `/home` despite `V2_ENABLED=true`).
- Intermediate Android codes 19–22 covered branding, Advertising ID declaration, and store-prep binaries.
- Current line is `2.0.1+23` (`versionName` 2.0.1, `versionCode` 23) so Play can accept a new binary above 18.

### Product on this line (vs +18)

- V2 product rebuild merged onto `main` (four-tab shell: Today · Plan · Progress · Profile).
- Settings Morning Light rebuild; logout/delete use shared `showConfirmDialog` / `showAppSnackBar` from PR #18 (V2 UI unchanged).
- Weekly Review 7-day activity summary.
- Privacy policy includes AdMob / Pro billing disclosure (EN + AR).
- Local V2 startup routing correction (`StartupDestination` → `/v2/home` when V2 is enabled).
- Android `applicationId` remains `com.brainclean.mobile`; UI version constant stays `AppConfig.appVersion = 2.0.1`.

### Quality

- `flutter analyze` clean and the full `flutter test` suite green at the `main` health-check gate.
- Ads remain **deferred** on the V2 root path (no `google_mobile_ads` on the root V2 release surface).
- Play release builds still require `--dart-define=V2_ENABLED=true` and the gitignored upload keystore.

### Explicitly not claimed

- Google Play **Production** publication.
- Confirmed Closed Testing / Play console ingest of `2.0.1+23` (upload is a separate operator step).

---

## 2.0.1+18

**Status:** Google Play **Closed Testing** (not Production; not V2-qualified)  
**Package:** `com.brainclean.mobile`  
**Branch baseline:** `v2/product-rebuild` @ `425147e`

### Brain Clean V2 product rebuild

- V2 product rebuild on Flutter with gated / V2-enabled startup path (`V2_ENABLED=true` for release builds as configured).
- Canonical four-tab V2 navigation shell: Today · Plan · Progress · Profile.

### Core recovery loop

- Brain Check (resumable questionnaire).
- Recovery Score V1 (deterministic, explainable; non-medical).
- Brain Profile reveal from completed Brain Check.
- Recovery Plan V1 generation and reveal.
- Today home and Daily Session player (minimum / standard paths).
- Progress foundation and PRG-01 proof experience.
- Weekly Review (local ISO week, WRV-01 / WRV-02) with WeeklyArtifact and adaptation signal storage (no automatic plan mutation).
- Reports surfaces for weekly artifacts / longitudinal evidence per contracts (archive depth respects Free/Premium gates).

### Support, Premium, localization

- Premium / post-proof experience with RevenueCat production wiring via build-time dart-define (keys never committed).
- Safa contextual safety experience (bounded Free-core support; ad-free on Safa).
- Arabic (RTL) and English (LTR) localization for V2 surfaces.
- Accessibility hardening (scrollability, tap targets, large text, semantics expectations in automated coverage).

### Android store identity and release engineering

- Android package reconciliation to Google Play identity `com.brainclean.mobile`.
- Existing approved upload keystore reused; secrets remain gitignored.
- Google Play Internal Testing preparation at `2.0.0+17`.
- Closed Testing bump to `2.0.1+18`.

### Quality

- Full automated Flutter test suite green at release engineering gates (see phase/store reports for counts per run).
- Ads remain **deferred** on the V2 root path (no `google_mobile_ads` dependency on root V2 release surface).

### Explicitly not claimed

- Google Play **Production** publication.
- Guaranteed recovery, clinical diagnosis, or medical treatment outcomes.

---

## 2.0.0+17

**Status:** Google Play **Internal Testing** preparation / signed V2 internal bundle  
**Package at that moment:** initially legacy example id; later reconciled to `com.brainclean.mobile` before Closed Testing identity finalization (see Version History)  
**Commits (store engineering):** `550ebcd`, `e9f82bf`

### Summary

- First V2 internal-test oriented signed release engineering pass at version `2.0.0+17`.
- Signed AAB verification and Internal Testing readiness documented in Phase 10.4 / 10.4R reports.

---

## 1.2.3+16

**Status:** Legacy Google Play store line (pre-V2 product rebuild track)  
**Note:** Historical Play release referenced for continuity; V2 closed-test line supersedes for V2 rollout planning.

Legacy feature set is not re-listed here as V2 completed work.
