# C09 — Release build 3.0.0

Build: **yes** — BEFORE building, STOP and ask Mahmoud in chat: "Is Vireo building now?" Build only after he answers no.
Commit message: `v3: release 3.0.0 (+37)`

1. Version `3.0.0+37` in pubspec and `AppConfig.appVersion`.
2. Full `flutter analyze` + `flutter test --timeout 60s`.
3. Update `docs/v3/RELEASE_CHECKLIST.md` with manual tests for everything added in C01–C08: onboarding v2 + trial offer, day 4/5 content, SOS bored/night, share card, review prompt (internal testing), usage access ask/deny, paywall day 7 header, trial-ending sheet (use a license tester), backup export/import, AR + EN, light + dark, text scale.
4. `.\build_release.ps1`. Write AAB path + size in CHANGES.
