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

## 2026-10-19, build run 1 (11:56 to 14:00 Central)

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
- Supporters can move a tile earlier or later (press and hold a name in the tile editor, or the VoiceOver actions). Only the two swapped tiles change slots.
- Second review pass by a fresh reviewer agent: every earlier fix held. Fixed after it: Help pill stays on one line at accessibility sizes, Speak shadow sits on the capsule only (not the label), Home tiles never clip their labels and the Home grid scrolls at accessibility sizes, orb glow no longer clipped, Settings caption "Both shown side by side. Lucas chose Nightlight at setup.", Edit tiles wells all surface-sunken and "Put back" instead of "Show on grid" (Show is a reserved product term), dark status bar on the attention screen, and Coffee's Another stack now uses the artboard alternates.
- The accessibility audit waits for navigation to settle; one run failed with "hit area too small" while tiles were still sliding in.
- Final state: all five CI jobs green on main at 5313f19, https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39305838251 (SelvoCore tests, app tests with 13 screenshot tests and 7 UI tests including the accessibility audits, scripts/demo.sh, Xcode 26 build).
- Left as is and why: the Settings Voice row says "Voice: default" until a voice is chosen (the artboard's "Daniel, warm" is sample data); the Undo link is ink-muted until there is something to undo; the Home greeting wraps a little early at default size (cosmetic).
- For Emily to decide: on Daylight the wordmark's "vo" uses the deep teal from App-Home-Day, while the brand book says it stays the orb teal as a logotype.
- Known screenshot limitation: multiline text fields (help message editor) draw as placeholders in ImageRenderer screenshots; they work in the app.

### Next
- Tile reorder for supporters.
- Trace the Settings audit note on a Mac.
- Friday polish: second artboard comparison pass on the latest screenshots, real device check of haptics and voices.

### Needs Emily
- On her Mac: Xcode 16 from the App Store (open it once and add the iOS platform), Command Line Tools, Homebrew (https://brew.sh). Then `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- Next week for TestFlight: her Apple Team ID, confirm the bundle ID `com.emilykenney.selvo`, register it, create the App Store Connect app record and an API key, and add four repository secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- The real logo artwork (the orb and wordmark files) if she wants it in the app instead of the drawn version.

## 2026-10-19, build run 2 (13:55 to about 15:00 Central)

### Shipped
- Accessibility pass (Day 4), checked off. A separate agent read every view:
  - VoiceOver actions "Choose a photo" and "Remove photo" on tiles. These match the long press menu.
  - Voice Control answers to the word on screen for choice pills, theme swatches and Hide / Put back.
  - With Differentiate Without Color on, page dots no longer rely on teal alone.
  - On Home and Setup, VoiceOver no longer stops on an empty top bar heading.
  - Reduce Motion needed no change: the only animations are fades, which is the brand book's reduced form.
- Scrolling areas fade at the bottom edge. A line about to pass under a pinned button is no longer cut through its letters, and the fade hints that more is below. Screens with the orb are left unfaded so the glow is not clipped.
- Settings shows the real default voice name ("Voice: Samantha" in the Simulator) instead of "Voice: default".
- The orb is smaller at accessibility text sizes on Listen (96pt) and Welcome (96pt, wordmark 44pt), so the text keeps the space.
- Choice pills have 32pt side padding, so a label stays clear of the check mark at large text sizes.
- New UI tests:
  - Supporter tile reorder: moves Coffee later in Edit Photos, checks the list and the grid, relaunches, and checks the grid again.
  - Real Simulator screenshots at accessibility XL (`ui-axl-*.png`) of Home, Photos, Choose your words (top and scrolled), Settings (top and scrolled), Help confirm and the attention screen.
- The Settings accessibility audit exception is removed. Settings at the top, Settings scrolled and Setup step 4 all pass the full audit, except contrast and Dynamic Type, which were left out on purpose last run. The earlier note no longer appears; most likely last run's Slow and Fast fix cleared it.

### Verified, and how
- CI green on every push this run. The last run was https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39313343548 (commit b731751). All four jobs passed:
  - SelvoCore tests and the token check.
  - Build with 20 unit and screenshot tests and 10 UI tests on an iPhone 16 Simulator.
  - `scripts/demo.sh` (passed).
  - The Xcode 26 build.
- Screenshots reviewed from the `ci-screenshots` branch (`ui-09-settings`, `ui-10-edit-photos-moved`, all `ui-axl-*`). A reviewer agent that had not seen the code compared the earlier set with the artboards. Fixed from its list:
  - The Settings caption cut under the Voice row.
  - The clipped heard text at accessibility XL.
  - "Voice: default".
  - The clipped scrolling content at accessibility XL. Most of these were ImageRenderer limits; the real `ui-axl-*` shots show the content scrolls correctly with the fade.

### Readings I took
- The tile reorder item said "check when verified on a device". I took a Simulator UI test that drives the real context menu and survives a relaunch as enough for the demo. Haptics and voices still need a device check.
- The Text size pills keep growing "A" sizes (the artboard has all three at 17px with the middle one selected). Growing sizes show what each choice does, so I kept them.

### Open, for a later run or for Emily
- Undo when there is nothing to undo is shown by color only (teal vs ink-muted); VoiceOver says "dimmed". This needs a design call, for example hiding the arrow when it is off.
- Reviewer P3 polish not done:
  - Hide / Put back eye icons look heavy at accessibility XL.
  - The heart glyph for Mom vs the person glyph for others.
  - The Daylight wordmark "vo" color: the brand book says orb teal, App-Home-Day uses deep teal. Needs Emily to choose.
  - The Help message preview uses a full danger fill.

### Next
- Every item through Thursday and the TestFlight readiness section is done. Friday: a final artboard comparison pass on the latest screenshots, and the final PROGRESS summary.

### Needs Emily
- On her Mac: Xcode 16 from the App Store (open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week:
  - Her Apple Team ID.
  - Confirm the bundle ID `com.emilykenney.selvo` and register it.
  - Create the App Store Connect app record and an API key.
  - Add the repository secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Undo off-state cue and the Daylight wordmark "vo" color (see Open above).
- The real logo artwork, if she wants it in place of the drawn wordmark.


## 2026-10-19, build run 3 (15:56 to about 16:40 Central)

### Shipped
- Undo with nothing to undo no longer relies on color alone: the arrow is hidden and the word stays ink-muted. The arrow keeps its space, so nothing moves. With something to undo, the teal arrow and word show as before.
- The Show link uses the artboard icon (a card frame with three lines), drawn as a small shape that grows with the text. `LinkButton` now takes any icon; the SF Symbol form still works.
- Choose your words at accessibility XL: the message strip stops growing at accessibility1, and the "Suggested for Lucas" caption stops at xxxLarge, so the cards keep more room. Show still turns the message to full size.
- Listen at accessibility XL: the "Replies are on their way" caption and Show replies now grow together and stop at accessibility1, so the heard text keeps the space and Show replies no longer looks smaller than the caption.
- Help message editor caption reads "...when you tap Help and then “Yes, show it”."

### Verified, and how
- CI green on 6819d74: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39324256133. All four jobs passed: SelvoCore tests and token check, build with unit, screenshot and UI tests on an iPhone 16 Simulator, `scripts/demo.sh` (passed), and the Xcode 26 build.
- Screenshots reviewed from the `ci-screenshots` branch for 6819d74: `ui-03-suggest` (new Show icon, Undo off with no arrow), `ui-axl-03-suggest` (strip smaller, the selected card fully visible), `07-listen-night-axl` (more heard text visible).
- A reviewer agent that had not seen the code compared all 71 screenshots from e235405 with the artboards and brand rules. It found no P1 items: no copy or rule breaks, one glow per screen, Speak, Back, Clear and Help in place, three suggestions everywhere.
- The suggestion caption cap (e28cb6c) is green too: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39326214151, all four jobs including `scripts/demo.sh`. In `ui-axl-03-suggest` the second card now shows below the selected one.

### Readings I took
- Text size default. The artboard has three sizes (24, 30, 38) with the middle one as default. The app has Standard, Large and Larger, where Standard follows the phone setting and the others raise it. Lucas is on Standard, so the first pill is selected. I kept this, because a size smaller than the phone setting would go against "the phone's own larger setting wins".
- The Another set pairs styles by meaning ("Coffee. Now. Please." is witty), not by the artboard's placeholder order. Kept.
- Not changed, judged as SF Symbol drawing differences rather than layout: the filled parts of the photo, house, car and bed symbols, and the Places pin shape. A custom icon set would be needed to match the artboard strokes exactly.
- Settings at default text size scrolls a little, so the font caption sits under the bottom fade above the Voice row. The fade is the scroll hint; the Supporter section is below it anyway.

### Next
- Friday: one more artboard pass on the final build and the final PROGRESS summary. Optional polish if time allows: a matching Places icon, the person avatar in Setup, and the selected pill check at accessibility XL.

### Needs Emily
- On her Mac: Xcode 16 from the App Store (open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: say whether the Undo off state (arrow hidden, word muted) reads right to her.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-19, build run 4 (17:55 to about 18:50 Central)

### Shipped
- Home: Photos, Places, People and Phrases now use line drawings traced from the App-Home artboard SVGs (24 unit box, 1.8 stroke, 32pt), so all four match each other and the artboard. The old SF Symbols were filled (photo), a different pin shape, and different sizes. New file `Selvo/Components/ArtboardGlyphs.swift`; `TileArtwork` has a `.drawing` case.
- People icons: the demo profile uses the two-person icon (`person.2`) for Mom, Emily, Blake, Dad and Sam, as in App-Setup and App-Photos. Mom no longer shares the heart with "Thank you". New people added in setup start with it too.
- The check on a selected choice pill (Text size, Speech rate, Reading font) grows with the text up to xxxLarge, so it still reads beside the large "A" at accessibility XL.
- Hide and Put back in the tile editor: the eye is small and regular weight, so the word leads.

### Verified, and how
- CI green on every push this run, all four jobs each time (SelvoCore tests and token check, build with unit, screenshot and UI tests, `scripts/demo.sh`, Xcode 26 build):
  - 67922bb https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39338554960
  - 3ae4904 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39339585073
  - 3f2577a https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39340668072
- `scripts/demo.sh` passed in CI on the last commit.
- Screenshots reviewed from `ci-screenshots`: `03-home-*` (all four drawings), `02-setup-*` (two-person icon), `09-settings-*-axl` (check), `10-edit-tiles-night-axl` (eye).
- A reviewer agent that had not seen the code compared Home, Setup, Photos, Settings and Edit tiles with the artboards: no P1. It confirmed the Photos and Places drawings match. Its People and Phrases size mismatch was fixed in 3f2577a.

### Readings I took
- The artboards use one two-person glyph for every person; I used the matching SF Symbol for tiles and setup rows, and the traced drawing only on the Home destinations.
- Left as is from the review: Photos grid symbols that are filled (Dinner, Home, Car, Bed) and the selected tile check badge (an extra cue that does not rely on color); "Voice: Samantha" (real default voice, the artboard's "Daniel, warm" is sample data); check circles on theme cards (same reason as the tile badge).

### Next
- Friday: final artboard pass on the final build, then the final PROGRESS summary.
- Optional polish from the review: the Settings section under the pinned Voice button at accessibility XL is cut by the bottom fade (scroll hint, as noted in run 3); the Back chevron looks thin at accessibility XL; the setup list at accessibility XL ends at a hard edge above Continue; a hidden tile's icon could dim with its label.

### Needs Emily
- On her Mac: Xcode 16 from the App Store (open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- The real logo artwork, if she wants it in place of the drawn wordmark.
