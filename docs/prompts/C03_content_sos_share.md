# C03 — Early wins in Week 1 + SOS v2 + share card + review prompt

Build: **no**
Commit message: `v3: week-1 early wins, SOS v2, share card, in-app review`
Spec: §4.7, §6.4 + PLAN items 2, 6, 11.

## 1. Content reorder (`assets/content/program.json`, `exercises.json`)
- Day 4 practice: `ex_pause_breath` → `ex_notif_audit`; Day 9: `ex_notif_audit` → `ex_pause_breath`.
- Day 5 practice: `ex_attention_anchor` → `ex_home_screen`; Day 8: `ex_home_screen` → `ex_attention_anchor`.
- Move each day's lesson/challenge WITH its practice so every day stays coherent (swap the whole day objects' content for 4↔9 and 5↔8, keep `day` numbers and week membership; adjust lesson wording only if it references "last week"/"yesterday" wrongly).
- Tiers: `ex_notif_audit`, `ex_home_screen` → `free`. `ex_pause_breath`, `ex_attention_anchor` stay `free` (allowed on Pro days).
- Content integrity test must still pass (days 1–7 only free exercises).

## 2. SOS v2 (`lib/v3/ui/sos/*`, `assets/content/sos.json`)
- `sos_bored`: first step = the user's replacement deck (`UserInputs.replacements`, else `default_replacements["5"]`), one tap picks one → end screen. Grounding text step stays as an optional "or try this" link. Breathing is NOT forced.
- Between 23:00 and 05:00 local: the SOS hub lists `sos_sleep` first, highlighted, and the whole flow uses dim colors.
- Second urge rating stays (one tap). End screen when both ratings exist: «من 8 إلى 4» big + «شارك» button.

## 3. Share card (generic) — `lib/v3/ui/share/share_card.dart`
- Widget rendered to PNG via RepaintBoundary, shared with `share_plus`. App mark + one big line + small line + store name "Brain Clean". No personal answers, no name.
- Variants: `sosWin(before, after)` → «تجاوزت رغبة في التصفح: من 8 إلى 4», `dayMilestone(days, clarityFrom?, clarityTo?)` → «أكملت X يومًا من برنامج الصفاء». Add «شارك إنجازك» on completion screens of days 7, 14, 30.

## 4. In-app review
- Add dependency `in_app_review`. Request once (flag in v3 box) after the FIRST SOS where after ≤ before − 2, or after Day 3 completion — whichever comes first. Never on a day the paywall was shown; never mid-flow (only on end/completion screens). If `isAvailable()` false → do nothing.

## Tests — `test/v3/content_sos_share_test.dart`
day 4 = notif audit, day 5 = home screen, days 1–7 free; bored flow shows replacement first with defaults when user list empty; at 23:30 sleep flow is first; share card builds for both variants without exceptions; review requested once only, not on paywall day (fake review service).
