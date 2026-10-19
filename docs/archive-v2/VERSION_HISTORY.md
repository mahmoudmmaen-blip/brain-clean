# Version History — Brain Clean Mobile

Honest release sequence for store planning. Missing hashes are not invented.

| Version | Package identity | Track / purpose | Status | Confirmed local commits |
|---|---|---|---|---|
| **1.2.3+16** | Legacy Play line (historical) | Public store (legacy product) | Historical baseline before V2 rebuild track | Not re-audited in this closure pack; referenced as prior Play continuity only |
| **2.0.0+17** | Was `com.example.brain_clean_mobile` during internal prep; later aligned | Internal Testing / signed V2 internal bundle | Internal Testing preparation | `550ebcd` prepare internal test 2.0.0+17 · `e9f82bf` verify signed V2 internal test bundle |
| **2.0.1+18** | `com.brainclean.mobile` | Closed Testing V2 | Closed Testing uploaded; **not V2-qualified** | `803cdca` package identity aligned to Play · `425147e` bump closed test release to 2.0.1+18 |
| **2.0.1+19–+22** | `com.brainclean.mobile` | Intermediate Android store-prep codes | Historical bumps (branding, AD_ID, release finalize) | `90d1e9b` +19 · `f3b66a2` +20 · `2cd0b01` +22 |
| **2.0.1+23** | `com.brainclean.mobile` | Current Android binary in `pubspec.yaml` | Code prepared; Play ingest **not claimed** | `5c22040` prepare Android release 23 · later `main` V2 merge |

---

## Notes

### 1.2.3+16

- Purpose: maintain continuity with the previously published Play listing before V2 rebuild.
- Not the V2 product feature baseline.

### 2.0.0+17

- Purpose: first V2-oriented signed release engineering for Internal Testing.
- Package identity later reconciled for Play (`com.brainclean.mobile`) before Closed Testing continued under the Play app id.

### 2.0.1+18

- Purpose: Closed Testing release of Brain Clean V2 with Play package identity `com.brainclean.mobile`.
- Status: Closed Testing was active; **not V2-qualified** (store install landed on Legacy `/home`).
- Production: **not published**.

### 2.0.1+23

- Purpose: current Android store binary (`versionName` 2.0.1, `versionCode` 23) on `main`.
- Status: **code prepared**; do not claim Play console ingest until an operator upload is confirmed.
- Production: **not published**.

---

## Production

No V2 Production version row exists yet. After Play grants production access and a Production release is approved, add a new row here with version, package, track = Production, status = Live, and the production Git tag once created.
