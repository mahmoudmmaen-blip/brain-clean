# Brain Clean V2 — Phase 10.4R Signed AAB Rebuild Report

**Document ID:** `BRAIN_CLEAN_V2_PHASE_10_4R_SIGNED_AAB_REPORT`  
**File:** `docs/BRAIN_CLEAN_V2_PHASE_10_4R_SIGNED_AAB_REPORT.md`  
**Status:** `SIGNED_AAB_BUILD_BLOCKED`  
**Date:** 2026-08-04  
**Branch:** `v2/product-rebuild`  
**Base HEAD:** `550ebcd573a26956d3f92e00ed06afb2911c1565`

---

## 1. Preflight

| Check | Result |
|---|---|
| Branch | `v2/product-rebuild` |
| HEAD | Exact match `550ebcd…` |
| Tree | Clean (tracked) |
| Version | `2.0.0+17` |
| Phase 10.4 commit | Present |
| Source keystore | Found (metadata only) |
| Source `key.properties` | Found (metadata only) |

## 2. Signing source metadata (no secrets)

| Source | Size (bytes) | UTC mtime |
|---|---:|---|
| Legacy `brain-clean-release-key.jks` | 2768 | 2026-07-02T07:43:04Z |
| Legacy `key.properties` | 134 | 2026-07-02T07:56:18Z |

## 3. Secret-copy result

| Item | Result |
|---|---|
| Keystore copy SHA-256 match | **YES** |
| `key.properties` copy SHA-256 match | **YES** |
| Destination keystore | `android/app/brain-clean-release-key.jks` |
| Destination properties | `android/key.properties` |
| `storeFile` relative path | `brain-clean-release-key.jks` (resolves under `android/app/`) |
| Required prop keys present (alias/passwords non-empty) | **YES** (values not printed) |
| Source files modified | **No** |

## 4. Git-ignore verification

| Path | Ignored? |
|---|---|
| `android/key.properties` | **YES** (`android/.gitignore` + root) |
| `android/app/brain-clean-release-key.jks` | **YES** (`**/*.jks`) |
| Staged | **No** |

## 5. Release signing configuration

Root `android/app/build.gradle.kts` reads `android/key.properties` and selects release signing when complete; debug fallback only if properties/keystore incomplete.

With copies in place, `canSignRelease` prerequisites are satisfied for the next build.

## 6. RevenueCat key handling — **BLOCKER**

| Step | Result |
|---|---|
| Interactive `Read-Host` | Non-interactive agent shell — blocked |
| Process / User / Machine env | **Empty** |
| Operator asserted “set outside” | Env still not visible to agent shell after retry |
| Format | `REVENUECAT_ANDROID_KEY_FORMAT=INVALID` |
| Build started | **No** (stopped at Part 4) |

Part 4 requires stop before building when format is invalid.

## 7. Artifact cleanup

Not executed (stopped before Part 5–7). Prior debug AAB may still exist under `/build` (gitignored).

## 8. AAB / signing verification

| Item | Status |
|---|---|
| Signed AAB | **Not built** |
| Certificate match | **NOT_TESTED** |
| Debug-signing exclusion | **NOT_TESTED** |

## 9. Security

| Check | Result |
|---|---|
| Secrets committed | **No** |
| Passwords/alias/key printed | **No** |
| Signing files tracked | **No** |
| Original `brain-clean` sources unchanged | **Yes** (read-only copy) |

## 10. Exact next steps to unblock

In an environment the agent/build can inherit:

1. `$env:REVENUECAT_ANDROID_API_KEY = Read-Host "Paste RevenueCat Android public SDK key"`  
2. Re-invoke Phase 10.4R (signing copies can remain).  
3. Expect: delete old AAB → validate suite → `flutter build appbundle --release` with `V2_ENABLED=true` + RC dart-define → fingerprint match vs legacy keystore → report `SIGNED_V2_INTERNAL_TEST_AAB_READY(_WITH_DEVICE_DEBT)`.

## 11. Google Play upload

**Must not begin** until a release-signed, RC-keyed AAB exists.

## 12. Phase 10.3R

Still required after Play installation of a properly signed Internal Testing build.

---

**End of Phase 10.4R report (blocked).**
