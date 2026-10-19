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

## 2026-10-19, build run 1 (11:56 to about 13:30 Central)

### Shipped
- Day 1 foundation: XcodeGen `project.yml`, `Selvo` app target, `SelvoCore` package, theme tokens generated from `tokens.json` by `scripts/gen_tokens.py` (CI fails if they drift), Lexend and Atkinson Hyperlegible bundled with their OFL licenses, core components (PrimaryButton, QuietButton, LinkButton, BackButton, HelpButton, IconButton, MessageStrip, Tile, SuggestionCard, TopBar, Wordmark, Orb, Screen).
- Day 2: Welcome, 5 step supporter setup, Profile model and JSON store, seeded demo profile for Lucas (SF Symbols, no photos of people), Home, tile grid with fixed slots and paging, PhotosPicker on tiles (long press a tile).
- Day 3: Choose your words (three suggestions, Another, Incorrect, Undo, Clear, Show), SuggestionStack, SavedPhraseProvider, SuggestionEngine with timeout and fallback, on-device model provider behind `#if canImport(FoundationModels)` and an availability check, Speak with AVSpeechSynthesizer, one haptic and the Spoken state, Show mode.
- Day 4: Listen (on-device speech recognition when the phone supports it), Help (confirm, then the attention screen), Settings (text size, theme side by side, speech rate, reading font, voice). Daylight on every screen.
- Day 5 and TestFlight readiness pulled forward: `scripts/demo.sh`, app icon, launch color, `docs/DEMO.md`, `docs/TESTFLIGHT.md`, `docs/APP-STORE-READINESS.md`, `Config/Signing.xcconfig` (Release only, `[EMILY_TEAM_ID]` placeholder), `PrivacyInfo.xcprivacy`, purpose strings, manual `.github/workflows/testflight.yml`.

### Verified, and how
- CI on `macos-15` (`.github/workflows/ci.yml`), all green on main, for example https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39297500155 (commit c368a01). Jobs:
  - SelvoCore `swift test` and the generated token check.
  - App build, 18 unit and screenshot tests, and 3 UI tests on an iPhone 16 Simulator (Xcode 16.4). The UI test walks Home, Photos, Coffee, a suggestion, Speak and sees Spoken, Another replaces the stack, Show, Help in two taps, and Settings, using saved phrases only (the offline path; the app makes no network calls).
  - `scripts/demo.sh` itself: installs XcodeGen, generates, builds for an iPhone 16 Simulator, boots, installs, launches with the demo profile and checks the app is still running. Passed.
  - A Simulator build with Xcode 26, because App Store Connect has required the iOS 26 SDK for uploads since April 28, 2026. This also compiles the Foundation Models provider. Passed.
- Screenshots: every screen in Nightlight and Daylight at default and accessibility XL text (ImageRenderer), plus real Simulator screenshots from the UI test (`ui-*.png`). I reviewed them, then a separate reviewer agent compared them with the artboards; its P1 and P2 findings were fixed (tile wells, clipped ring in Settings, suggestion text scaling, centered heroes, 56pt secondary buttons, title centering, page dots, fixed size wordmark).

### How to see CI images (for future runs)
- Artifact downloads are blocked from the agent sandbox, so CI also commits images to the `ci-screenshots` branch (`screenshots/` and `demo/`, each with a `SHA` file). `git fetch origin ci-screenshots` and read them from there.

### Readings I took (Emily did not need to answer)
- Setup steps: 1 name, 2 people (the artboard), 3 places, 4 text size and theme side by side, 5 voice. Phrases are seeded from the demo set instead of a setup step. The final button reads Finish. The help phrase is copied from the demo profile; it needs its own editor (added to PLAN).
- "I already have a profile" loads the Lucas demo profile.
- In the Simulator the demo profile loads automatically on first launch; `-SelvoDemoProfile NO` shows Welcome; `-SelvoResetProfile` starts clean (UI tests use it).
- Tapping a tile opens Choose your words (as the artboard links do). Speak on a tile grid speaks the tile label.
- Tile wells stay surface-sunken. Tinted wells were tried and removed: the brand book reserves surface-brand-tint for selection and indigo is decorative only.
- The drawn wordmark stands in for the logo file, which is not in the repo.
- Speak and Listen labels are 20pt as on the artboards (`TypeScale.primaryAction`); every other label uses the 17pt `label` token.
- Screen chrome (top bar, quiet button rows) stops growing at the largest standard text size so Back, titles and Help stay readable at accessibility sizes.
- Purpose strings say speech stays on the phone only when the phone can recognize speech by itself, which is accurate.

### Later in the run
- Supporter editing: Settings has a "For supporters" section with Edit Photos, Places, People, Phrases (hide and show on grid without moving other tiles, rename, add a tile with a symbol) and a Help message editor with a live preview. SelvoCore tests cover hide, unhide, add and rename keeping positions.
- Accessibility audit UI tests run Apple's `performAccessibilityAudit` on Home, Photos, Choose your words, Show, Help (both screens) and Settings. Pixel contrast and Dynamic Type audit types are left out on purpose (contrast is checked against tokens in TokensTests; chrome caps text growth by design; screenshots cover accessibility XL). One Settings note, "Potentially inaccessible text" with no element attached, is allowed for now and needs a look with Accessibility Inspector. Main went red for about 25 minutes while these audits were tuned; it is green again (see the last run below).
- Top bar titles shrink a little before truncating ("Help message", "Edit Photos").
- Known screenshot limitation: multiline text fields (help message editor) draw as placeholders in ImageRenderer screenshots; they work in the app.

### Next
- Tile reorder for supporters.
- Trace the Settings audit note on a Mac.
- Friday polish: second artboard comparison pass on the latest screenshots, real device check of haptics and voices.

### Needs Emily
- On her Mac: Xcode 16 from the App Store (open it once and add the iOS platform), Command Line Tools, Homebrew (https://brew.sh). Then `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- Next week for TestFlight: her Apple Team ID, confirm the bundle ID `com.emilykenney.selvo`, register it, create the App Store Connect app record and an API key, and add four repository secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- The real logo artwork (the orb and wordmark files) if she wants it in the app instead of the drawn version.
