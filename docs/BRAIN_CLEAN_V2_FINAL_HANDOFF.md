# Brain Clean V2 — Final Handoff

**Single authoritative re-entry document**  
**File:** `docs/BRAIN_CLEAN_V2_FINAL_HANDOFF.md`  
**Closure baseline HEAD:** `425147e6f8c5cc2a45c93af9c99a046608ba3969`  
**Final closure verdict:** `DEVELOPMENT_CLOSED_PRODUCTION_PENDING`

Read this file first when reopening the project.

---

## 1. Project identity

| Field | Value |
|---|---|
| Product | Brain Clean V2 |
| Workspace | `C:\Users\FUTURE\Documents\GitHub\brain-clean-v2` |
| Primary branch | `v2/product-rebuild` |
| Platform focus at closure | Android Google Play |

---

## 2. Current state

| Classification | Value |
|---|---|
| Development | **DEVELOPMENT_COMPLETE** |
| Closed Testing | **CLOSED_TEST_ACTIVE_NOT_V2_QUALIFIED** (`2.0.1+18`; startup defect observed on store install) |
| Production | **PRODUCTION_PENDING_GOOGLE_PLAY** |

**Not in Production.** Do not claim public Production publication.

---

## 3. Branch and HEAD

```
Branch: v2/product-rebuild
HEAD:   425147e6f8c5cc2a45c93af9c99a046608ba3969
Subject: build(android): bump closed test release to 2.0.1+18
```

---

## 4. Version and package

| Field | Value |
|---|---|
| Version | `2.0.1+18` |
| Version code | `18` |
| `applicationId` | `com.brainclean.mobile` |
| `namespace` | `com.brainclean.mobile` |

---

## 5. Completed product surfaces (V2)

- V2 navigation shell (Today · Plan · Progress · Profile)
- Brain Check
- Recovery Score V1
- Brain Profile
- Recovery Plan V1
- Today + Daily Session
- Progress (foundation + PRG-01 experience)
- Weekly Review + WeeklyArtifact (+ stored future adaptation signal)
- Reports (contracted surfaces; Premium archive depth gated)
- Premium + RevenueCat (build-time public key injection)
- Safa contextual safety (Free core)
- Arabic / English localization + accessibility hardening
- Android package alignment to Play id

---

## 6. Monetization status

- RevenueCat integrated for release builds via dart-define public SDK key
- Keys/secrets **not** committed
- Closed Testing available for subscription sandbox with Play installer truth
- Live Production purchase validation **pending Production**

---

## 7. Google Play status

| Track | Version | Status |
|---|---|---|
| Internal Testing | `2.0.0+17` | Historical V2 internal prep |
| Closed Testing | `2.0.1+18` | **Active but NOT V2-qualified** — version 18 store build exposed startup → Legacy `/home`; startup correction is local-only until a new version is uploaded and Play-verified |
| Production | — | Waiting period / not approved / not created |

---

## 8. Testing status

- Automated Flutter analyze/tests green at release engineering gates
- Device/store qualification evidence captured in Phase 10.x reports (bounded)
- **Closed Testing `2.0.1+18` is NOT V2-qualified:** store install exposed a startup defect (cold start landed on Legacy `/home` even with `V2_ENABLED=true`)
- Startup correction is implemented locally (splash + biometric → `/v2/home` when V2 shell enabled)
- A **new store version** and Play-installed V2 visual verification are still required before claiming V2 Closed Test qualification
- See `docs/ROOT_BUILD_AUTHORITY.md` — Play builds must come from repository root only

---

## 9. Signing and secret-handling rules

- Reuse approved upload keystore
- Keep `android/key.properties` and `*.jks` **gitignored and untracked**
- Never print keystore passwords, private keys, RevenueCat secrets, or receipts into docs/commits
- Use placeholders like `<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>` in documentation

---

## 10. Exact safe build command template

```bat
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=V2_ENABLED=true --dart-define=REVENUECAT_ANDROID_API_KEY=<REVENUECAT_ANDROID_PUBLIC_SDK_KEY>
```

Do not commit the AAB or the real key.

---

## 11. Important file paths

| Path | Role |
|---|---|
| `docs/ROOT_BUILD_AUTHORITY.md` | **Play build cwd authority** — root only; never nested `brain_clean_mobile/` |
| `pubspec.yaml` | Version `2.0.1+18` |
| `android/app/build.gradle.kts` | `applicationId` / `namespace` / signing wiring |
| `android/key.properties` | Local signing (ignored) |
| `android/app/*.jks` | Upload keystore (ignored) |
| `lib/` | V2 product code (root) |
| `docs/` | Contracts + release/qualification reports |
| `CHANGELOG.md` | Version changelog |

---

## 12. Documents index

| Document | Purpose |
|---|---|
| `docs/BRAIN_CLEAN_V2_FINAL_HANDOFF.md` | **This file** — re-entry authority |
| `docs/FINAL_RELEASE_STATUS.md` | Canonical state machine |
| `CHANGELOG.md` | Completed version history notes |
| `docs/RELEASE_NOTES_2.0.1.md` | EN/AR store notes + DRAFT Production |
| `docs/VERSION_HISTORY.md` | Track sequence 1.2.3+16 → 2.0.0+17 → 2.0.1+18 |
| `docs/BACKUP_AND_RECOVERY_CHECKLIST.md` | Backup / restore checklist |
| `docs/MAINTENANCE_GUIDE.md` | Build / bump / rollback operations |
| `docs/KNOWN_ISSUES_AND_DEBT.md` | Blockers vs nonblocking debt |
| `docs/PRODUCTION_DAY_CHECKLIST.md` | Steps after Play unlocks Production |
| Product contracts (`docs/BRAIN_CLEAN_V2_*_CONTRACT_V1.md`) | Product law |
| Phase 10.x reports | Store/monetization qualification evidence |

---

## 13. Outstanding work

1. Complete Google Play production-access waiting period.
2. Finish store-installed Closed Testing smoke + billing confidence as needed.
3. Execute `docs/PRODUCTION_DAY_CHECKLIST.md` only after access unlocks.
4. Optionally schedule ads contract later (currently deferred).
5. Create Git production tag **only after** Production approval.

---

## 14. Production-day sequence (summary)

1. Confirm access unlocked + tester requirement satisfied.  
2. Review vitals / declarations / subscriptions.  
3. Create Production release with approved bundle.  
4. Submit → wait for review.  
5. Production install + purchase/restore validation.  
6. Tag Git after approval.  

Details: `docs/PRODUCTION_DAY_CHECKLIST.md`.

---

## 15. What must never be changed casually

- Package id `com.brainclean.mobile`
- Upload signing identity (without official Play key process)
- Version code reuse
- Committing secrets / AABs
- Claiming Production before Play approval

---

## 16. How to resume the project

1. Open this handoff.  
2. `git checkout v2/product-rebuild` and verify HEAD (or intentional later release commit).  
3. Restore encrypted keystore + `key.properties`.  
4. `flutter pub get` → `flutter analyze` → `flutter test`.  
5. Read `docs/FINAL_RELEASE_STATUS.md` + `docs/KNOWN_ISSUES_AND_DEBT.md`.  
6. If Production unlocked → `docs/PRODUCTION_DAY_CHECKLIST.md`.  
7. If still waiting → keep Closed Testing healthy; avoid unnecessary code churn.

---

## 17. Final closure verdict

```
DEVELOPMENT_CLOSED_PRODUCTION_PENDING
```

Coding on the V2 development program may stop.  
Operations continue only for Closed Testing health and eventual Production-day execution.
