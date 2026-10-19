# Progress log

## 2026-10-19, setup session
- Preserved the Flutter prototype on branch `prototype-2025` and moved it to `legacy/flutter-prototype/` (nothing deleted).
- Added design references: `docs/design/app/` (10 screens), `docs/design/website/` (6 pages plus the warm color direction), `docs/design/system/` (brand book and tokens), `docs/HANDOFF.md`.
- Added `PLAN.md` (5-day plan) and `CLAUDE.md` (agent rules).
- Next: Day 1 items in PLAN.md.
- Needs Emily: nothing yet. To demo on a device she will need a Mac with Xcode 16 and her iPhone in Developer Mode.

## 2026-10-19, plan update from Emily
- Demo target is the iOS Simulator on Emily's Mac (not a device). Added `scripts/demo.sh` and a CI check for it to Day 5.
- Emily has a paid Apple Developer account and wants TestFlight the week of Oct 26. Added a TestFlight readiness section to PLAN.md.
- Needs Emily (next week): her Apple Team ID, confirm the bundle ID `com.emilykenney.selvo`, create the app record and an App Store Connect API key, add the three repository secrets.
