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

## 2026-10-20, build run 5 (07:56 to about 09:10 Central)

### Shipped
- `scripts/demo.sh` now runs in CI with Xcode 26 as well as Xcode 16 (a matrix on the demo job). The Mac App Store now offers Xcode 26, so that is most likely what Emily installs. `docs/DEMO.md` says either works, gives the macOS needed for each, and where to get Xcode 16 on an older Mac. The Xcode 26 launch picture is on `ci-screenshots` under `demo-xcode26/`.
- New UI test `SelvoUITests/DemoWalkUITests.swift` walks the rest of the demo script: Welcome then "I already have a profile" to Home; "Set up together" through all 5 steps to Finish and Home greeting the new name; Incorrect removes the chosen card and keeps three, Undo brings it back; Listen opens, shows its status and Stop listening, and stops; Settings switches to Daylight, Atkinson, Lexend and back to Nightlight. Screenshots `ui-demo-*`.
- Polish from the run 4 review: the Back chevron grows with its label (it looked thin at accessibility XL); a hidden tile's icon dims with its label in the tile editor; screenshot renders of non-orb screens end in the same bottom fade as the app.
- From this run's review: the setup voice step says "Choose how fast the words are spoken." (the brand book says not to describe Selvo as speaking for someone); the setup text size preview uses the message size, the same as Settings; setup shows the real default voice name ("Voice: Samantha") as Settings does.

### Verified, and how
- CI green on every push this run, all five jobs (SelvoCore tests and token check, build with unit, screenshot and UI tests, `scripts/demo.sh` with Xcode 16, `scripts/demo.sh` with Xcode 26, the Xcode 26 build):
  - 34826e3 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39426893350
  - 3d1fa1f https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39429662469
  - 8cfa85c https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39431735928
- `scripts/demo.sh` passed in CI with both Xcodes. The Xcode 26 launch picture shows Home with the Lucas profile on iOS 26.
- Screenshots reviewed from `ci-screenshots`: `demo-xcode26/demo-launch`, `ui-demo-07-listen`, `ui-axl-02-photos` (Back chevron), `10-edit-tiles-night-default` (dimmed hidden icon, fade), `ui-demo-setup-4` and `ui-demo-setup-5` (after the fixes).
- A reviewer agent that had not seen the code compared the new shots with the artboards and brand book. Placement, sizes, one glow, three suggestions and copy rules all passed.

### Readings I took
- Kept from the review, as earlier runs decided: the Settings caption under the bottom fade at rest (scroll hint), Show replies before anything is heard (it offers saved phrases, as the caption says), supporter tile reorder (the handoff lists it), the selected ring drawn outside the card (as on the artboards), and Slow and Fast pills in setup (a quick choice; the slider is in Settings).
- Step 1 of setup speaks to the person ("What should Selvo call you?") and later steps name them. Left as is; see Needs Emily.

### Next
- Friday: final artboard pass on the final build and the final PROGRESS summary. Every item through Thursday and the TestFlight section is done.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-20, build run 6 (09:56 to about 11:00 Central)

Main was green at the start (8b0e8cd). Every item through Thursday and the TestFlight section was already done, so this run did an early version of Friday's artboard pass on the current build and fixed what it found.

### Shipped
- Incorrect now puts the new suggestion in the removed card's slot, and it takes the selection. Before, the cards below moved up a slot and the new one landed at the bottom. This follows "positions never move". If nothing is left to offer, the open slot closes and the remaining cards stay in order. `SuggestionStack` keeps fixed slots; unit tests updated; the demo walk UI test checks the last card never moves up. `docs/DEMO.md` says the new one arrives in the same spot.
- Settings: the theme caption names the theme chosen at setup ("Lucas chose Nightlight at setup.") and no longer follows the current selection. New `Profile.setupTheme`, set when the profile is made; profiles saved before it was added still load and show only "Both shown side by side."
- Screens with the orb (Welcome, Listen) now end in the same bottom fade as other screens when the text is too tall to fit. Before, at accessibility sizes the heard text was cut flat at the bottom edge, and in the live app it could scroll over the buttons below.
- Primary buttons have 16pt inner side padding and center wrapped labels, so "Set up together" no longer touches the pill ends at accessibility sizes. The Welcome body text uses the full width at accessibility sizes.
- CI writes `build-summary.txt` (errors, failed assertions, test counts) next to the screenshots on the `ci-screenshots` branch. Job logs and artifacts cannot be downloaded from the agent sandbox, so this is how later runs read a failure.

### Verified, and how
- 9262952 and 70098e4: the build-and-test job went red. Logs could not be downloaded, so I added the summary file in 9e8cc5a. That run showed two causes: (1) the new UI assertion was too strict, because the new card can be taller and push the last card down; (2) wider padding I tried on choice pills at accessibility sizes made the audit report "Text clipped" on Settings. I relaxed the assertion to "never moves up" and took out the pill padding change.
- 19c25bb green, all five jobs (SelvoCore tests and token check, build with unit, screenshot and UI tests, `scripts/demo.sh` with Xcode 16, `scripts/demo.sh` with Xcode 26, the Xcode 26 build): https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39449274890
- `scripts/demo.sh` passed in CI with both Xcodes on every push this run.
- Screenshots reviewed from `ci-screenshots` for 19c25bb: `ui-demo-04-incorrect` (new card in the middle slot, "Is there time for coffee?" still last), `ui-demo-09-settings-daylight` (caption says Nightlight after switching to Daylight), `07-listen-night-axl` (heard text fades), `01-welcome-night-axl` (body fades, button label wraps inside the pill).
- A reviewer agent that had not seen the code compared all 81 shots from 8b0e8cd with the artboards and brand book. It found no rule breaks. The items above came from its list.

### Readings I took
- From the review, left as is: the Lexend check sits close to the word at accessibility XL (wider padding fails the clipping audit; the ring and tint also mark the choice); setup step 3 (places) has no "Add a place" row (the artboard shows only the people step; places can be added later in the tile editor); Undo off state without its arrow (decided in run 3); supporter tile reorder (in the handoff); Help attention title weight (uses the heading style).
- The reviewer thought the name from setup ("Maya") did not reach Suggest. That was test order: each UI test launches on its own, and the Incorrect test uses the Lucas profile. Not a bug.

### Next
- Friday: the final artboard pass on the final build (check off the Friday item then) and the final PROGRESS summary.
- Optional: an "Add a place" row in setup step 3, matching "Add a person" in step 2.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-20, build run 7 (11:55 to about 13:20 Central)

Main was green at the start (ff3fd07). Every item through Thursday and the TestFlight section was already done, so this run had two fresh reviewers look for demo risks: one compared all screenshots with the artboards, one read the code and DEMO.md for bugs a live demo could hit. Fixes below.

### Shipped
- Always three suggestions. A reviewer traced a real break: on a tile with six phrases (Dinner), Incorrect then Another left two cards, and repeated Incorrect could shrink the stack too. New `SavedPhraseProvider.next(for:count:after:)` and `startingOver(...)` in SelvoCore: when a tile's phrases run out it starts over skipping the cards on screen and those marked Incorrect, then adds the general phrases, and only as a last resort lets an Incorrect phrase come back. A new unit test plays 26 Another and Incorrect moves on every demo tile and checks three different cards after each.
- After Incorrect, the new card keeps the removed card's style when it can (witty stays witty), so the set keeps plain, witty and short as on the artboard.
- Setup step 3 starts with three places, like step 2 with three people, so "Add a place" shows without scrolling.
- On-device model suggestions that contain an exclamation mark, a long dash or a line break are dropped; saved phrases fill the slot.
- Back on a tile grid no longer calls `removeLast` on an empty path (possible crash on a double tap).
- Speech rate track has a 1pt border-strong edge, so the empty part is visible in Daylight (it was about 1.1:1).
- `scripts/demo.sh`: when `xcodebuild -version` fails it prints what xcodebuild said and suggests accepting the license, selecting Xcode, and `xcodebuild -runFirstLaunch` (before it always said "not selected").
- `docs/DEMO.md`: Listen step matches the app (tap Show replies, after Speak the button becomes Listen again, then Back); Show explains the message is upside down on purpose; Play a sample is in the Voice screen.
- UI test: real screenshot of the help message editor (`ui-demo-11-help-phrase`), because ImageRenderer draws text fields as a placeholder in `11-help-phrase-*`. The Incorrect UI test now checks card order and the kept style.

### Verified, and how
- 83d613d green, all five jobs: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39463083818
- 15fcce1 and 64353e2 went red in the UI test only: my Incorrect assertions assumed fixed heights, but the message strip grows with the message (as on the artboard: min-height 72, grows), so the cards shift a little when the new message is shorter. Read via `build-summary.txt` on `ci-screenshots`. Fixed the test to check order.
- 29c317c green, all five jobs (SelvoCore tests and token check; build with unit, screenshot and UI tests; `scripts/demo.sh` with Xcode 16; `scripts/demo.sh` with Xcode 26; Xcode 26 build): https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39468183711
- f781dd7 (speech rate edge) green, all five jobs: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39470470611. `ui-demo-09-settings-daylight` shows the empty track edge.
- `scripts/demo.sh` passed in CI with both Xcodes on every push this run.
- Screenshots reviewed from `ci-screenshots` for 29c317c: `ui-demo-04-incorrect` ("Coffee. Now. Please." in the middle slot, witty, selected), `ui-demo-11-help-phrase` (fields drawn, border-strong edge, radius 16), `ui-demo-setup-3` (three places and Add a place).

### Readings I took
- From the design review, left as is: the Settings theme caption names the theme chosen at setup (decided in run 6); Listen offers Show replies before anything is heard (saved phrases, decided in run 5); the name field pill shape in setup 1; the Text size check beside the A; the Help attention Done already uses the primary label style; at accessibility XL Suggest shows one card fully and the next under the fade (it scrolls).
- From the code review, left for later: if Emily's Mac has Apple Intelligence, the iOS 26 Simulator may use the on-device model, so the first cards could differ from DEMO.md. The saved phrases still show first and the UI never waits. "I already have a profile" always loads Lucas (intended for the demo).

### Next
- Friday: the final artboard pass on the final build (check off that item then) and the final PROGRESS summary.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-20, build run 8 (13:56 to about 14:30 Central)

Main was green at the start (7db5d3b). Every item through Thursday and the TestFlight section was already done, so this run had two fresh reviewers look again: one did a dry rehearsal of `docs/DEMO.md` against the code and real Simulator screenshots, one compared all screenshots with the artboards (no P1).

### Shipped
- `scripts/demo.sh --fresh` starts over with a fresh profile for Lucas, and `scripts/demo.sh --welcome` starts over on Welcome. Both use the existing `-SelvoResetProfile` launch argument. The rehearsal review found that a plain rerun keeps everything changed in rehearsal (Daylight, text size, font, speech rate, voice, moved tiles, help phrase, or a new person from Set up together), and the old recovery path was three `simctl` commands on `booted`. CI now runs plain, `--welcome` and `--fresh` with both Xcode 16 and Xcode 26 and publishes a picture of each.
- New unit tests `SelvoTests/LaunchTests.swift`: a plain launch keeps the saved profile; `--fresh` arguments give Lucas; `--welcome` arguments give no profile.
- `docs/DEMO.md` fixes from the rehearsal: a table for the three forms of the command; run `--fresh` after every rehearsal; on Suggest the first card is already in the strip when the screen opens; Listen's Stop listening button (not the bottom button) becomes Listen again; Settings bullets in the app's order (Text size, Theme, Speech rate, Reading font, Voice pinned at the bottom), the pill says Atkinson, and the larger A grows the whole screen; Photos has a second page and the pictures are drawn symbols; on a Mac with Apple Intelligence, Another may bring on-device model suggestions that differ run to run.
- Setup person and place glyphs fit the 22pt box from the artboard (the two-person symbol was about 31pt wide).

### Verified, and how
- 8202694 green, all five jobs (SelvoCore tests and token check; build with unit, screenshot and UI tests including LaunchTests; `scripts/demo.sh` plain, `--welcome` and `--fresh` with Xcode 16; the same with Xcode 26; Xcode 26 build): https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39479904568
- Screenshots reviewed from `ci-screenshots` for 8202694: `demo/demo-launch-welcome.png` (Welcome after a reset), `demo/demo-launch-fresh.png` (Home for Lucas after a reset), `ui-demo-setup-2` (smaller glyphs in the 48pt wells).

### Readings I took
- From the design review, left as is: Settings text size chips draw the three A at growing sizes (the artboard draws all at 17pt); growing sizes say what each does without relying on the ring. Setup step 5 offers Slow and Fast pills (decided in run 5). After Another the plain and witty labels sit on different sentences than the artboard's sample (the app's labels fit the words). Incorrect replaces the removed card in place (decided in run 6, follows "Incorrect removes one"). Suggest cards sit about 5pt lower than the artboard (minor; left for Friday's pass).
- The on-device model stays on when available, since suggestions are the product. DEMO.md says the words may differ.

### Next
- Friday: the final artboard pass on the final build (check off that item then) and the final PROGRESS summary.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-20, build run 9 (15:56 to about 16:50 Central)

Main was green at the start (22c7e6c). Every item through Thursday and the TestFlight section was already done, and the two open items belong to Friday's final build. So this run had two fresh reviewers look from new angles: one read the code for tap sequences that could go wrong in a live demo (fast or repeated taps, Listen and Speak sharing the audio session, persistence, PhotosPicker), one compared every Daylight and accessibility XL screenshot with the artboards (no P1).

### Shipped
- A double tap on a tile, Show, Help, Settings or Listen no longer opens the screen twice (before, Done on Show or Back on Suggest seemed to do nothing, and two Listen screens each started a listener). `AppModel.open` skips a route that is already on top. New unit tests `SelvoTests/NavigationTests.swift`.
- Listen waits for Selvo to finish speaking. Before, tapping Listen again (or opening Listen from Home) while a reply was still being spoken switched the audio session to record, so the rest of the sentence went silent and the mic could hear the tail of it. Now listening starts when the speech ends.
- `SpeechService.isSpeaking` follows the message playing now, so a quick second Speak is not marked finished by the first message's cancel callback.
- The check on a selected choice pill (Lexend, Slow, Fast) keeps a gap from a long label at accessibility sizes (it touched the "d" of Lexend).

### Verified, and how
- 8cf102a green, all five jobs (SelvoCore tests and token check; build with unit tests including NavigationTests, screenshot and UI tests including the accessibility audits and demo walk; `scripts/demo.sh` plain, `--welcome` and `--fresh` with Xcode 16; the same with Xcode 26; Xcode 26 build): https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39497046316
- `scripts/demo.sh` passed in CI with both Xcodes.
- Screenshots reviewed from `ci-screenshots` for 8cf102a: `ui-axl-09b-settings-scrolled` (gap between Lexend and its check). Copy scan: no en or em dashes in Swift, docs, scripts or workflows; no exclamation marks or the words user, voiceless or patient in UI copy.

### Readings I took
- Left as is from the design review: the Settings font caption sits under the bottom fade until the screen scrolls (Settings has more than the artboard, the For supporters section, so it scrolls by design and the fade says there is more); Undo with nothing to undo shows no arrow (decided in run 3); the Listen and Show captions stop growing at accessibility sizes so the heard text and message keep the space (decided earlier); the Listen heard text at accessibility XL scrolls; setup progress gap 8pt against 6pt on the artboard (minor, left for Friday's pass).
- Left as is from the code review: a saved profile that fails to decode is replaced by Lucas in the Simulator. No field changes are planned before Friday, so there is no path to it now; note for TestFlight.
- `docs/DEMO.md` now says to connect or disconnect Bluetooth headphones before the demo, not during Listen, since changing the Mac's microphone while listening is the one audio risk left.

### Next
- Friday: the final artboard pass on the final build (check off that item then) and the final PROGRESS summary.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-20, build run 10 (17:55 to about 18:30 Central)

Main was green at the start (c061121). Every item through Thursday and the TestFlight section was already done; the two open items belong to Friday's final build. This run closed two small leftovers from earlier reviews.

### Shipped
- Setup progress segments sit 6pt apart, as on App-Setup (they were 8pt).
- A saved profile that cannot be read is moved aside to `profile-unreadable-<time>.json` beside it, so a later save never writes over it (run 9 noted this for TestFlight). New SelvoCore tests: an unreadable file is kept and survives the next save; a readable one loads in place.

### Verified, and how
- 0bf829f green, all five jobs, including `scripts/demo.sh` plain, `--welcome` and `--fresh` with Xcode 16 and Xcode 26: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39511813960
- Screenshots reviewed from `ci-screenshots` for 0bf829f: `02-setup-night-default` beside a render of App-Setup (gaps match).

### Readings I took
- The "Suggest cards about 5pt lower" note from run 8: measured against a render of App-Suggest, the gap from the Show row to the first card matches (about 34pt against 35pt). The difference comes from the real message wrapping to two lines in the strip, so nothing to change.

### Next
- Friday: the final artboard pass on the final build (check off that item then) and the final PROGRESS summary.

### Needs Emily
- On her Mac: Xcode from the Mac App Store (Xcode 26 needs macOS Sequoia 15.6 or later; open it once and add the iOS platform), Command Line Tools, and Homebrew (https://brew.sh). Then run `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-21, build run 1 (07:57 to about 10:20 Central)

Main was green at the start (12d5b34). Every item through Thursday and the TestFlight section was already done, so two fresh reviewers looked from angles no earlier run used: one read `scripts/demo.sh` and DEMO.md for failures a personal Mac hits that CI never does, one checked every behavior in the iPhone section of the handoff against the code. The biggest finding: **the Mac App Store now offers Xcode 27** (27.1, needs macOS Tahoe 26.6; Apple's system requirements page), not 26, so this run proved the demo and every test on Xcode 27.

Note for the next run: this run overlapped with the 09:55 run (session 01Xg6), which pushed 8b623ef and ed95e59 between my commits. Both runs worked on the Listen probe; nothing conflicted.

### Shipped
- `scripts/demo.sh` works without sudo when the Mac points at the Command Line Tools (it uses Xcode for the script only), stops with a plain fix when Xcode's first launch setup is missing, opens the Simulator that belongs to the Xcode in use, and says the first boot can take about 5 minutes. `find_simulator.py` names Components (Platforms in Xcode 16) and turns a Simulator tool error into a plain message.
- `scripts/demo.sh --ios 18` picks the iOS version of the Simulator; it combines with `--fresh` and `--welcome`. (Checked here with a mocked simctl; CI runs the plain forms.)
- CI: the demo jobs now run with the Mac's own `/bin/bash` (bash 3.2). The Xcode 26 demo job first deletes the runner's iPhone 16 Simulators, so the script creates its own, as on a Mac with a fresh Xcode 26 or 27 (proven: "Deleting iPhone 16 Simulator" then a new device, then green). New workflow `demo-xcode27.yml` on the `xcode-27` runner: `scripts/demo.sh` plain, `--welcome` and `--fresh` with Xcode 27.2, and every unit, UI, demo walk and accessibility audit test on the iOS 27 Simulator. `ci_select_xcode.sh` prefers a release Xcode over a beta.
- Speak: a quick double tap says the message once with one haptic (before, the second tap restarted the sentence). On Suggest, Spoken now stays while the voice plays and about a second after it ends, as the handoff says (before, a long message lost its Spoken check while still playing). New `SelvoTests/SpeakTests.swift`.
- No Sendable warning from the speech synthesizer with Xcode 27 (with Xcode 27 the warning printed as an "error:" line in the demo script's output, which would have looked alarming on Emily's Mac).
- Listen writes why it cannot run to the Mac's log (subsystem `com.emilykenney.selvo`, category `listen`; never what it hears). CI saves those lines as `selvo-log.txt` beside the screenshots.
- `docs/DEMO.md`: Xcode 27, 26 or 16 with the macOS each needs, no separate Command Line Tools step, what to run if Xcode is not selected or needs its first launch setup, about 40 GB free, clone into the home folder, practice Listen the day before so permission prompts come then, `--fresh` before the demo, Spoken while the voice plays.

### Verified, and how
- CI green on every push, all jobs. Latest fully finished: 2ef38c9, CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39618970688 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39618970543. Later pushes (ac4bf22, the other run's 8b623ef and ed95e59, 73d2ac7) were still queued when this run ended.
- `scripts/demo.sh` passed in CI with Xcode 16, 26 (fresh-Mac Simulator path) and 27 (27.2, iOS 27 Simulator).
- Screenshots: `demo-xcode27/demo-launch*.png` beside `demo-xcode26` (same pixels apart from the status bar). All 81 shots from `screenshots-xcode27` compared by pixel difference with `screenshots` (iOS 18): only the keyboard in setup step 1, the status bar, and Listen differ.

### Found: Listen in the iOS 27 Simulator
- On the iOS 27 Simulator Listen shows "Listening is not available on this phone right now." The log says: on-device recognition is reported as supported, but each session fails at once with kLSRErrorDomain 300, three times, so Selvo stops. A probe test shows the newer on-device `SpeechTranscriber` is not available in the Simulator either. On the iOS 18 Simulator Listen starts normally (log: on device true, 48 kHz, then "no speech" because CI has no voice).
- So on Emily's Mac with Xcode 27, Listen will most likely not hear anything unless the Simulator is iOS 18 (or iOS 26, if the probe shows it works). The rest of the demo, including Show replies on the Listen screen, still works.
- `listen-probe.yml` runs the Listen test on every installed runtime with Xcode 26 and 27 and publishes `listen-xcode26/` and `listen-xcode27/` to `ci-screenshots`. Read those first.
- Reading I took: I did not make the Simulator fall back to Apple's server recognition. That would send what the other person says to Apple, and the rules say never to add network calls that send what a person says. It is Emily's call (below).

### Readings I took from the reviews (left as is)
- Clear on Suggest still empties the message and goes Home, as DEMO.md walks it; it is not a destructive action on saved data. Removing a photo already takes two taps (menu, then confirm).
- The model's first stack may still replace the saved phrases if it arrives within 1.5 s and nothing was tapped: the handoff says to fill the stack when results arrive.
- The Listen caption "Replies are on their way. Saved phrases still work." is the artboard's copy.
- No contrast setting: the handoff lists one, the Settings artboard has none (artboard wins). Incorrect feedback is kept for the screen only, not saved to the profile; worth doing for TestFlight, not before the demo, since it would change the cards between rehearsal and demo.

### Next
- Read the Listen probe reports. If iOS 18 (or 26) works, put `./scripts/demo.sh --ios 18` in DEMO.md with how to add that Simulator in Xcode (Settings, Components, plus button), and consider making demo.sh pick it automatically when installed. Add a CI form that runs `--ios 18`.
- Friday: the final artboard pass on the final build and the final PROGRESS summary.

### Needs Emily
- **Which Xcode is on your Mac?** The App Store now gives Xcode 27 (needs macOS Tahoe 26.6). All three versions are proven, but with Xcode 27 the Simulator cannot run Listen on the phone itself. Decide one: (a) add the iOS 18 Simulator in Xcode and run `./scripts/demo.sh --ios 18` (keeps everything on the Mac; the next run will document it), or (b) allow the Simulator only to use Apple's server speech recognition for the demo (what is said near the Mac goes to Apple).
- On her Mac: Xcode, then Homebrew (https://brew.sh). Then `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-21, build run 2 (09:56 to about 11:25 Central)

Main was green at the start (2ef38c9). This run overlapped with run 1 (session 01AFa6), which was still probing Listen in the iOS 27 Simulator. Once I saw its `listen-probe.yml`, I took back my duplicate CI step (ed95e59) so both did not publish to the same folder, then picked up its open Listen item after it wrote its progress.

### Shipped
- **Listen with Xcode 27.** The Listen probe (`listen-xcode26/` and `listen-xcode27/` on `ci-screenshots`) showed: iOS 27.0 fails at once (kLSRErrorDomain 300, three times); with Xcode 26, iOS 26.0.1 runs on device (session ends with "no speech" after about 5 seconds, as expected in CI); iOS 18.5 reports no on-device recognizer and would use Apple's server recognition; 18.6, 26.1 and 26.2 logged lines the log tool could not decode, two per runtime about 6 seconds apart, so they probably ran too. So `scripts/demo.sh`, with Xcode 27 or later and no `--ios`, now uses the iOS 26 Simulator when it is installed and says so, or prints a tip to add it. `--ios 27` still picks iOS 27 by hand. Checked here with a mocked `xcrun`: Xcode 27 with iOS 26 installed picks 26; without it prints the tip; Xcode 26 changes nothing.
- `docs/DEMO.md`: new step 5 (Xcode 27 only: add the iOS 26 Simulator in Settings, Components, or `xcodebuild -downloadPlatform iOS -buildVersion 26.2`), a line under the command table, and a Listen troubleshooting line.
- New CI job `demo-ios26` in `demo-xcode27.yml`: downloads the iOS 26 Simulator onto the Xcode 27 runner, runs `/bin/bash scripts/demo.sh` and checks it chose iOS 26, then runs the Listen UI test there and fails unless Selvo logged "on device: true" and never "Listening is not available". Publishes to `ci-screenshots` under `demo-xcode27-ios26/`.
- SpeechProbeTests also reports whether the iOS 26 DictationTranscriber has an English locale and whether the older recognizer claims on-device support.
- The `02-photos` UI screenshot waits for the Photos grid (on iOS 18 it caught Home mid transition; found by the reviewer).
- CI concurrency: one run per branch per workflow; a newer push replaces a waiting run (a running one always finishes). Two overlapping agent runs had queued about a dozen runs and the macOS runners took hours to reach the latest.

### Verified, and how
- Started from 2ef38c9, green in CI and Xcode 27 (runs 39618970688 and 39618970543).
- A reviewer agent that had not seen the code compared all 84 iOS 27 screenshots with the iOS 18 set and the artboards, with a pixel diff: no app UI restyled or broken by iOS 27. Differences are system UI only (status bar, keyboard in setup step 1, the microphone prompt over `ui-demo-07-listen`, which DEMO.md already covers by practicing the day before). Rule check passed (Speak, Back, Clear, Help placement; one glow; copy).
- **Not yet verified in CI:** 78410ed, 97aaa2c, 90b643f, f12a657 and this commit were still queued behind the overlapping runs when I stopped (the runner queue, not a failure). The newest push supersedes the waiting ones.

### Next
- First: check the newest CI and Xcode 27 runs on main. If `demo-ios26` is green, read `demo-xcode27-ios26/listen-ios26.txt`, then check off the Listen item in PLAN.md. If `xcodebuild -downloadPlatform` failed on the runner, read why in the job log summary and fix the version list.
- Friday: final artboard pass on the final build and the final PROGRESS summary.

### Needs Emily
- **Which Xcode is on your Mac?** If it is Xcode 27 (the App Store default now), add the iOS 26 Simulator once (DEMO.md step 5) so Listen can hear; `./scripts/demo.sh` then uses it by itself. This keeps listening on the Mac, so the server recognition question from run 1 should not be needed.
- On her Mac: Xcode, then Homebrew (https://brew.sh). Then `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- Optional: whether setup should speak to the person throughout ("you") or name them throughout.
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-21, build run 4 (15:55 to about 16:55 Central)

Main CI was green at the start for 9abde7c (run 39672687598). Run 3 (session 01NZqs) was still active and pushing the Listen work (32983ee, e99ebc0 during this run), and the Listen item is the only open item before Friday. So I took the reading that two runs must not edit the same Listen code and CI files at once: I made no code changes, and did a pre-Friday artboard review instead.

### Verified, and how
- CI for 9abde7c green, all jobs: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39672687598 (includes `scripts/demo.sh` with Xcode 16 and 26).
- The Xcode 27 "Build and test" failure on dd4c2a1 (run 39668632384) was `AccessibilityAuditUITests.testHelp` timing out while Xcode launched the app on the runner ("Timed out while launching application via Xcode"); every unit test passed. Not a code failure; the newer runs on main decide it.
- A reviewer agent that had not seen the code compared all 84 screenshots for 9abde7c (`ci-screenshots/screenshots/`) with renders of every artboard. No P1.

### Findings for Friday's artboard pass (not changed)
- P2: Home at accessibility XL: the greeting takes 3 lines and the category tiles shrink to about 94pt (token `touch-tile` is 96). I looked at `ui-axl-01-home.png`: icons and labels are clear and nothing clips, so I left it. Option for Friday: cap the greeting's growth on Home.
- P2: the rendered `11-help-phrase-*` shots draw the text fields as yellow bars (the ImageRenderer cannot draw text fields). The Simulator shot `ui-demo-11-help-phrase.png` is correct. Use that one when reviewing.
- P2 noted, left as is: Settings in Daylight still says "Lucas chose Nightlight at setup." under the theme pair. That is true (it names the setup choice, decided Oct 20).
- P3: Suggest cards about 4 to 8pt shorter than App-Suggest; Help pill about 6pt narrower; Home greeting wraps one word earlier; Daylight Speak shadow lighter; speech rate thumb about 22pt against 28 on the artboard (check its hit area); Photos uses SF Symbols, not the artboard's line icons (brand book allows SF Symbols); voice name depends on the Mac's voices.

### Next
- Run 3's Listen item: check off once the `demo-ios26` job in `demo-xcode27.yml` is green.
- Friday: the final artboard pass on the final build (the P2 and P3 list above is the starting point) and the final PROGRESS summary.

### Needs Emily
- Unchanged from run 2: which Xcode is on her Mac (with Xcode 27, add the iOS 26.2 Simulator, DEMO.md step 5); Xcode and Homebrew on her Mac; for TestFlight her Team ID, the bundle ID, the App Store Connect app record, API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if wanted.

## 2026-10-21, build run 3 (13:56 to about 17:35 Central)

Main CI was green at the start (7f6d1b1), but the Xcode 27 workflow was red: the new `demo-ios26` job showed Listen failing on the iOS 26.4 Simulator too (kLSRErrorDomain 300). Fixing that was this run's work. Run 4 (session 019zQg) overlapped from 15:55 and stayed out of the Listen code; its notes are above.

### Found: the iOS Simulator version decides whether Listen can hear
- New probes (`listen-probe.yml`, now also on `macos-26` runners) and a new file probe (`SelvoTests/SpeechFileProbeTests.swift`: a fixed test sentence made with the Mac's `say`, given to the older on-device recognizer and to the iOS 26 DictationTranscriber). Reports are on `ci-screenshots` under `listen-*`.
- iOS 26.0.1 and 26.2: Listen starts on device and runs until "no speech" (kAFAssistantErrorDomain 1110, expected with no voice in CI); both recognizers turn the test sentence into text.
- iOS 26.4, 26.5 and 27.0: the older recognizer fails at once ("Failed to initialize recognizer", 300), on macOS 26.6 hosts and on macOS 27 alike, with Xcode 26.6 and 27.2. DictationTranscriber has no audio format it accepts there.
- So the earlier reading (the Mac or Xcode 27 was the cause) was wrong; it is the runtime.

### Shipped
- `scripts/find_simulator.py` picks a Simulator where Listen can hear first (iOS 18, or 26.0 to 26.2), with any Xcode, and prints "Using the iOS 26.2 Simulator, where Listen works" or a tip to add it. `scripts/demo.sh --ios` takes a version like `26.2`. Checked here with a mocked `xcrun` in 8 cases (Xcode 27 alone, with 26.2, with 26.4 and 26.2, Xcode 26.6 with 26.5, Xcode 16 with 18.x, explicit versions).
- `docs/DEMO.md` step 5: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once. Troubleshooting line updated.
- `demo-xcode27.yml` `demo-ios26` job downloads exactly iOS 26.2, checks demo.sh chose it, and fails unless Listen starts on device. It runs the Listen test once more only when the test runner crashes before any test runs (it did, twice, on the first try after demo.sh).
- `CoreFlowUITests` waits up to 40 seconds for Another to come back after Spoken (it missed once in CI on 700d57c while the voice was slow).
- Tried and taken out in this run: a DictationTranscriber fallback in `SpeechListener` (it ran, but cannot hear in the same Simulators). `SpeechListener.swift` is back exactly as it was; nothing moved to `legacy/` because the code was written and removed in this run.

### Verified, and how
- f534811 (contains all of the above) green on every job. CI: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39680125656 (including `scripts/demo.sh` with Xcode 16 and 26). Xcode 27: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39680125575 (`scripts/demo.sh` with Xcode 27; demo.sh with the iOS 26.2 Simulator added, which chose 26.2 itself, and Listen on device: "Starting recognition, on device: true", then "no speech" after about 7 seconds; every unit and UI test on iOS 27).
- Screenshot reviewed: `demo-xcode27-ios26/demo-launch.png` (Home for Lucas on iOS 26.2 under Xcode 27, same as the other demo shots). Run 4 did the full artboard review this afternoon, so I did not repeat it.

### Next
- Friday: the final artboard pass on the final build (start from run 4's P2 and P3 list) and the final PROGRESS summary.

### Needs Emily
- **If your Mac has Xcode 27, or Xcode 26.4 or later**, run once in Terminal: `xcodebuild -downloadPlatform iOS -buildVersion 26.2` (about 8 GB), so Listen can hear in the demo. `./scripts/demo.sh` then uses it by itself and says "Using the iOS 26.2 Simulator". No change is needed for Xcode 16 or Xcode 26.3 and earlier.
- On her Mac: Xcode, then Homebrew (https://brew.sh). Then `./scripts/demo.sh` from the repo, and `./scripts/demo.sh --fresh` after each rehearsal. See `docs/DEMO.md`.
- For TestFlight next week: her Apple Team ID; confirm and register the bundle ID `com.emilykenney.selvo`; create the App Store Connect app record and an API key; add the secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`. See `docs/TESTFLIGHT.md`.
- Choose the Daylight wordmark "vo" color (orb teal per the brand book, or deep teal per App-Home-Day).
- The real logo artwork, if she wants it in place of the drawn wordmark.

## 2026-10-21, build run 5 (17:56 to about 19:10 Central)

Main was green at the start (8dabfc6, CI run 39686290718). Every item through Thursday is checked, so I pulled Friday's artboard pass and started on run 4's P2 and P3 list.

### Shipped (21679a3)
- Suggest cards now match App-Suggest in height: a one-line card is 81pt (artboard 82, was about 74). The cause was that `lineSpacing` adds leading only between lines, so a single 17/26 line and the 14/20 caption lost their outer leading. New `TypeStyle.halfLeading` in `Typography.swift`; only `SuggestionCard` uses it, so no other screen moved.
- Home at accessibility XL: the greeting now stops growing at the same size as the tiles. The greeting takes 2 lines instead of 3 and the four tiles are about 108pt tall (were about 95; token `touch-tile` is 96).

### Checked, left as is
- Speech rate thumb: drawn at 28pt as on the artboard (its 3pt edge is the page color, so it looks about 22). The whole 44pt row takes taps and drags, so the hit area is fine.
- Daylight Speak shadow lighter than App-Home-Day: App-Home-Day uses the Nightlight shadow, and `tokens.json` gives Daylight `0 8px 24px rgba(15, 21, 48, 0.12)`. The brand book wins.
- Help pill about 6pt narrower: same 12pt padding as the artboard; the difference is the font's measured width. Not worth a change.

### Verified, and how
- CI for 21679a3 green on every job, including `scripts/demo.sh` with Xcode 16 and 26: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39690239045. Xcode 27: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39690239107 (green on every job). The iOS 26.2 job failed on the first try before any test ran ("The test runner failed to initialize for UI testing. Timed out waiting for AX loaded notification"; demo.sh in that job ended with exit 70 on the same slow Simulator) and passed on its one re-run, so I read it as the runner, not this change, which touches only layout. If it fails that way again on Friday, give that job a longer Simulator warm up before demo.sh.
- Screenshots reviewed on `ci-screenshots` for 21679a3: `ui-axl-01-home.png`, `ui-03-suggest.png`, `ui-axl-03-suggest.png`. Measured the tile and card heights from the pixels. Nothing clips; Speak, Clear and Back unchanged.

### Next
- Friday: the final artboard pass on the final build (remaining from run 4: the rendered help phrase shots draw text fields as bars, use the Simulator shot), then the final PROGRESS summary for Emily.

### Needs Emily
- Unchanged from run 3: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; Xcode and Homebrew on her Mac; for TestFlight her Team ID, the bundle ID, the App Store Connect app record, API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if wanted.

## 2026-10-22, build run 1 (07:58 to about 10:45 Central)

Main's CI was green at the start (ab55a9a), but the Xcode 27 workflow was red: the iOS 26.2 Listen job's test runner failed before any test ran ("Timed out while loading Accessibility"). That was the second time this week, so I treated it as a real problem. While I fixed it, slow macOS runners turned up three more failures that were not caused by code changes. Every item through Thursday was already checked off, so this run made CI and `scripts/demo.sh` sturdier and did a review pass on the Friday artboards.

### Shipped
- 823ca7d `ci:` The iOS 26.2 Listen job now closes Selvo before the test. If the test runner fails before any test runs, the job reboots the Simulator and tries once more. It retries on both "while preparing to run tests" and "failed to initialize for UI testing".
- cac5a99 `ci:` The Xcode 27 "Build and test" job reruns the UI tests once, after a fresh boot, only when the UI test runner died before any UI test ran and no test failed. On 823ca7d it crashed while preparing, after all 29 unit tests had passed.
- df53dc2 `test:` The accessibility audit runs once more if it ends with "Audit failed to complete in time" (code -56). On cac5a99 that happened on three screens in the macos-15 CI, and the commit had not touched the app. A second timeout still fails the test. Real audit findings still fail the first time.
- b178736 `fix:` **demo.sh** now builds for `generic/platform=iOS Simulator`, using only the Mac's own chip (arm64 or x86_64, read from `sysctl` so it works under Rosetta too), and installs with `simctl`. It no longer asks xcodebuild for the Simulator by id. On 823ca7d, demo.sh failed (exit 70) right after the iOS 26.2 runtime was downloaded, with "Unable to find a device matching the provided destination". Emily would hit the same thing right after DEMO.md step 5.
- 45926fa `fix:` **demo.sh** tries the launch up to 5 times, 3 seconds apart, while the Simulator still says Selvo "is installing". It failed once on the `--welcome` run in the Xcode 26 job. That is the path Emily uses between rehearsals.

### Verified, and how
- Every job is green on 45926fa (the head before this note):
  - CI: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39795999312. This covers `scripts/demo.sh` with Xcode 16 and with Xcode 26 in all three forms (plain, `--welcome`, `--fresh`), the Xcode 26 TestFlight SDK build, and the full test suite with screenshots.
  - Xcode 27: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39795999267. This covers demo.sh with Xcode 27; demo.sh choosing the freshly added iOS 26.2 Simulator on its own, with Listen running on device until "no speech"; and every test on iOS 27.
- b178736 was also green on all three Xcode 27 jobs (run 39792042532), so the generic build and install work with a just-added runtime.
- Screenshots reviewed: `demo/demo-launch-welcome.png` and `demo-xcode26/demo-launch.png` for 45926fa (Welcome and Lucas's Home, the same as before the build change), plus the full set on `ci-screenshots/screenshots/` for ab55a9a.
- A reviewer agent that had not seen the code compared all of ab55a9a's shots with renders of the artboards. Rules pass: Speak, Back, Clear and Help are placed correctly, only the orb glows, copy matches, there are no dashes, exclamation marks or banned words, and tiles are 96pt or larger. It reported two P1s, both on ImageRenderer renders: Listen and Welcome at accessibility XL looked cut off. I checked the code. Both screens sit in `ScrollsWhenNeeded`, which scrolls in the app, and the fade at the bottom is the intended "more below" cue. Renders cannot scroll. So neither is a P1.
- Its other findings were already decided in earlier runs, so I left them as is:
  - The Settings footnote sits under the fade, because Settings scrolls to For supporters.
  - The disabled Undo has no arrow (run 3).
  - The selected tile has a check badge (non-color cue).
  - Suggest at accessibility XL scrolls.
  - The setup UI test types "Maya" on purpose, to prove a new name reaches Home.
- Left as is, new: on Welcome at default size, the body wraps with "phone." alone on its third line. The text uses the artboard's 300pt max width; Lexend's measured width causes the wrap. This is cosmetic. Possible Friday fix: allow about 330pt.

### Next
- Friday: the final artboard pass on the final build, then the final PROGRESS summary for Emily. Optional: the Welcome wrap.
- If the iOS 26.2 Listen test fails again with "Home shows Speak" after Stop listening (it did once on 823ca7d, when the runner took 341 seconds for one test), give that final `assertHome` a longer wait.

### Needs Emily
- No change from Oct 21:
  - With Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear.
  - Install Xcode and Homebrew on your Mac.
  - For TestFlight: your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`).
  - Pick the Daylight wordmark "vo" color.
  - Send the real logo artwork, if you want it.

## 2026-10-22, build run 2 (09:57 to about 11:50 Central)

Main's CI was green at the start (45926fa). Run 1 was still active until about 10:45, so I stayed out of `scripts/` and the workflows until it wrote its progress. Every item through Thursday is checked, so I pulled Friday's artboard pass.

### Shipped
- a5698bd `fix:` The Suggest message strip now keeps two lines of height. Before this, tapping "Coffee first. Then I'll be nice." made the strip grow from one line to two and pushed all three cards down about 37pt, so a quick second tap could land on the wrong card. Other screens keep the one-line strip (`reservedLines` defaults to 1). New unit test `testMessageStripKeepsReservedLines`.
- a42908d `fix:` **Red CI fixed.** The Xcode 27 runner now ships the iOS 27.1 Simulator, and creating an iPhone 16 there failed with "Incompatible device", so the Xcode 27 test job had no device and xcodebuild stopped (exit 64, run 39801698918). `scripts/find_simulator.py` now (1) prefers runtimes whose supported devices include an iPhone 16, (2) on a runtime that cannot run one, uses its plainest iPhone (for example "iPhone 17") and says so, and (3) tries the next runtime when the Simulator refuses to make a device. demo.sh uses the same script, so Emily's Mac gets the same fallback if a future Xcode drops the iPhone 16. I checked it here with a mocked `xcrun` in 5 cases: only 27.1 without iPhone 16; 27.1 without and 27.0 with; 27.1 refusing create; 26.2 installed beside 27.1; `--ios 27.1` asked by hand.

### Verified, and how
- CI for a5698bd green on every job: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39801698459 (includes `scripts/demo.sh` with Xcode 16 and 26).
- CI for a42908d green on every job: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39806990153.
- Xcode 27 for a42908d green on every job (demo.sh with Xcode 27; demo.sh with the iOS 26.2 Simulator added; all 30 unit and 15 UI tests on iOS 27): https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39806990002. That runner had an image with iOS 27.0, where an iPhone 16 works, so the new fallback was not needed there; it is proven only by the mocked cases above. If a runner with iOS 27.1 comes back, its log will say which device it used.
- The Xcode 27 run for a5698bd also had the iOS 26.2 Listen job fail once with "Failed to get matching snapshots: Error getting main window kAXErrorServerNotFound" after 279 seconds on one test (run 39801698918). That is the runner's accessibility server, not the strip change; the same job passed on a42908d. If it happens again, add that message to the job's retry patterns.
- Screenshots reviewed for a5698bd (`ci-screenshots/screenshots/`): `ui-demo-04-incorrect.png` and `ui-demo-05-undo.png` now have the first card at the same place (one-line and two-line messages); `ui-03-suggest.png` unchanged in layout.
- A reviewer agent that had not seen the code compared all 84 shots for 45926fa with renders of every artboard. Rules pass on every screen. Its findings and what I did:
  - Cards moving when the message wraps: fixed (above).
  - Settings footnote half under the fade at default size; Undo with nothing to undo has no arrow; Welcome and Listen cut at accessibility XL in the renders; Suggest at accessibility XL shows one card and scrolls; Lexend check close to the word at accessibility XL; selected tile check badge; Help headline weight: all decided in earlier runs (see run 1 today and Oct 20). Left as is.
  - P3, left for Friday if time: Photos page dots sit about 18pt higher than the artboard (the dots row is a 44pt tap target); Welcome body ends on "phone." alone (Lexend width, artboard max 300pt); Welcome orb halo looks a little smaller than `glow-orb`; Home gear sits about 18pt from Help.

### Readings I took
- The "tile positions never move" rule is about tiles, but the same reason (people aiming at a moving target) applies to the three cards, so I treated the card shift as a bug even though the artboard does not show it.

### Next
- Friday: the final artboard pass on the final build (the P3 list above), then the final PROGRESS summary for Emily.
- If an Xcode 27 job logs "cannot run an iPhone 16; using an iPhone 17", check its screenshots once on `ci-screenshots/screenshots-xcode27/`.

### Needs Emily
- No change: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; install Xcode and Homebrew on your Mac; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if you want it.

## 2026-10-22, build run 3 (11:56 to about 13:15 Central)

Main was green at the start (d3b424d; CI green, Xcode 27 still running and then green). Every item through Thursday is checked, so I worked run 2's P3 list from Friday's artboard pass.

### Shipped
- 695814d `fix:` Friday artboard polish:
  - Welcome: the body text may be 330pt wide (artboard 300pt). Lexend sets wider than the artboard, so it broke into three lines with "phone." alone; now two lines, "...with the person / who will use it holding the phone."
  - The orb halo is drawn like the CSS `glow-orb` token: a disc grown by the spread, then blurred. A SwiftUI shadow has no spread, so the halo was smaller than the artboard. Still the only glow on the screen, still on Welcome and Listen only.
  - Photos: the page dots take only their 8pt in the layout, so they sit 16pt above Speak as on App-Photos (were about 38pt). The 44pt tap area is unchanged; it reaches into the gaps.
  - Home: the Settings gear's 44pt frame now sits right beside Help, as on App-Home (was a 12pt gap).
- c583eee `ci:` the iOS 26.2 Listen job also retries once, after a fresh boot, when the Simulator's accessibility server goes away mid test (`kAXErrorServerNotFound`, seen once in run 2).

### Verified, and how
- CI green on every job for 695814d (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39818638050) and c583eee (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39821535628), including `scripts/demo.sh` with Xcode 16 and 26 in all three forms.
- Xcode 27 green on every job for c583eee: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39821535778 (demo.sh with Xcode 27, demo.sh plus Listen on iOS 26.2, all tests on iOS 27). The run for 695814d was replaced while waiting, as designed; c583eee contains it. d3b424d's Xcode 27 run (39817433964) was also green.
- Screenshots reviewed on `ci-screenshots/screenshots/` for 695814d: `ui-demo-01-welcome.png` (two lines, bigger halo), `01-welcome-day-default.png` (Daylight halo soft, no wash over text), `ui-02-photos.png` and `ui-axl-02-photos.png` (dots just above Speak, nothing overlaps), `ui-01-home.png` (gear beside Help), `ui-demo-07-listen.png` and `07-listen-night-axl.png`.
- A reviewer agent that had not seen the code compared Welcome, Home, Photos and Listen in both themes and both sizes with the artboards. No P1; all rules pass; the halo now reads close to the artboard. Its P2s are the accessibility XL renders of Welcome and Listen cutting off under the scroll fade, already decided in run 1 (renders cannot scroll; the app scrolls). Left as is: at accessibility XL the Listen halo faintly tints behind the header title (decorative, the title keeps its contrast); the Home greeting wraps "to start?" to a second line because Lexend at 14pt is wider than the artboard's 342pt row allows.

### Readings I took
- The artboard renders here fall back to a system sans (no web fonts offline), so line breaks are judged by intent (no word left alone), not by matching the render.

### Next
- Friday: one last full artboard pass on the final build, then the final PROGRESS summary for Emily.

### Needs Emily
- No change: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; install Xcode and Homebrew on your Mac; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if you want it.

## 2026-10-22, build run 4 (13:56 to about 15:05 Central)

Main was green at the start (ba4e5e1, CI and Xcode 27). Every item through Thursday is checked, so I pulled Friday's artboard pass again, this time across every screen, not only the four that run 3 covered.

### Shipped
- ae4cc5a `fix:` two artboard differences:
  - Photos (and every tile that shows an SF Symbol): the symbol is 26pt, was 32pt. The artboard's line icons sit in a 32pt box, so the visible picture is about 22 to 24pt; ours were about 40 to 50pt and heavy. Home's line drawings are unchanged.
  - Settings: the speech rate track takes the thumb's 28pt in the layout, as on App-Settings. Its 44pt touch area and accessibility frame are kept and reach into the gaps. At default text size the footnote "Atkinson Hyperlegible was tested with low-vision readers." now shows both lines above the fade (before, it was cut after "low-").

### Verified, and how
- CI green on every job for ae4cc5a: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39836690559 (`scripts/demo.sh` with Xcode 16 and 26, the TestFlight SDK build, all tests with screenshots).
- Xcode 27 for ae4cc5a: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39836690578 green on every job (demo.sh with Xcode 27, demo.sh plus Listen on iOS 26.2, all tests on iOS 27).
- Screenshots reviewed on `ci-screenshots/screenshots/` for ae4cc5a: `ui-09-settings.png` (footnote whole), `ui-axl-09-settings.png` and `ui-axl-09b-settings-scrolled.png` (slider row clear of its neighbours at accessibility XL), `ui-02-photos.png` (smaller symbols, closer to App-Photos).
- A reviewer agent that had not seen the code compared all shots for ba4e5e1 with renders of every artboard. **No P1.** All placement, glow, copy and touch target rules pass. Its findings and what I did:
  - Settings footnote cut at default size: fixed (above).
  - Photo symbols too big: fixed (above).
  - Photo pictures differ from the artboard (Dinner cloche, Game monitor, Park map pin): left as is. The seeded profile uses SF Symbols by design, and a fork and knife or a tree reads more plainly than a cloche or a pin.
  - Incorrect replaces the selected card in place where the artboard moves the selection: left as is. HANDOFF says "Incorrect removes one", and the Oct 20 fix fills that card's slot so the other two never move.
  - Another shows the new set in style order (plain, witty, short), not the artboard's order: left as is, so each card's caption stays in the same place (covered by `testCoffeeAnotherGivesTheArtboardAlternates`).
  - Text size chips draw the three A's at three sizes (artboard: all 17pt): left as is. Three identical A's would not show the choice.
  - Slider empty track has a border-strong edge: left as is, decided earlier for Daylight contrast.
  - Home greeting wraps "to start?": the text already has the full width; Lexend is wider than the artboard's font. Left as is.
  - The Daylight disabled Speak shadow is faint, and setup people rows are 76pt against 80pt: P3, left for Friday if time.
  - The theme caption names the setup theme even after a change: decided Oct 20 (it says what was chosen at setup).

### Readings I took
- The artboard is the spec for size, but the demo pictures stay SF Symbols as the build prompt asks, so I matched the icon size and not the exact pictures.

### Next
- Friday: final full artboard pass on the final build (optional P3s: Daylight disabled Speak shadow, setup people row height), then the final PROGRESS summary for Emily.

### Needs Emily
- No change: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; install Xcode and Homebrew on your Mac; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if you want it.

## 2026-10-22, build run 5 (15:56 to about 17:40 Central)

Main was green at the start (6b99873, CI and Xcode 27). Every item through Thursday is checked, so I looked at Friday's screens through the project rule that the person using Selvo cannot read.

### Shipped
- da70c3c `feat:` Speak carries the three sound bars before its label, everywhere Speak appears (Home, Photos grid, Choose your words, Listen replies). The brand book and HANDOFF name the sound bars as the Speak glyph; the artboards show the word only, and the brand book wins. The bars take the label's color (navy on teal, muted when Speak is off), grow with Dynamic Type, and are hidden from VoiceOver, so the button is still named "Speak" for VoiceOver and the UI tests.

### Verified, and how
- CI green on every job for da70c3c: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39853642621 (`scripts/demo.sh` with Xcode 16 and 26, the TestFlight SDK build, all tests with screenshots).
- Xcode 27 for da70c3c: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39853642961 green on every job after one re-run. The first try of the iOS 26.2 Listen job failed before any test step ran: the test runner failed on a fresh Simulator, and the retry after a reboot timed out launching Selvo ("Timed out while launching application via Xcode", 151 s). `scripts/demo.sh` itself passed in that same job. The re-run of only that job was green, so I read it as a slow runner, not this change, which only draws a shape inside the Speak button.
- Screenshots reviewed on `ci-screenshots/screenshots/` for da70c3c: `ui-03-suggest.png` (bars before Speak, navy on teal), `ui-axl-03b-suggest-scrolled.png` (bars grow with the text, Speak still one line), `03-home-day-default.png` (Daylight, muted bars on the off Speak).
- A reviewer agent that had not seen the code went through the person-facing screens asking "could someone who cannot read use this?". No rule breaks (dashes, exclamation marks, banned words, Clear beside Speak, glow count). I measured Clear and Help at 44pt in the PNGs (it guessed 43). What I did with its list:
  - Speak has no picture: fixed (above), as the brand book says.
  - The gear on Home "is not on the artboard": wrong, App-Home has it.
  - Another, Incorrect, Clear, Show replies and Stop listening are words only: left as is. The artboards show words only and the brand book names no glyph for them; adding pictures is a design call for Emily (see Needs Emily).
  - **The three suggestions are text only, so a person who cannot read cannot tell them apart before Speak.** This is the real gap for the people Selvo is for. Not built the day before the demo, because the fix is a design decision (for example a quiet preview in the earpiece or headphones when a card is chosen, so the room does not hear it). See Needs Emily.
  - Mom and People share a similar figure picture: by design, the demo uses SF Symbols, never real photos; a supporter adds a real photo with PhotosPicker.

### Readings I took
- Brand book over artboard for the Speak glyph, per PLAN.md's order of authority. Other glyphs stay as the artboards draw them until Emily decides.

### Next
- Friday: final full artboard pass on the final build, then the final PROGRESS summary for Emily.

### Needs Emily
- New: decide how a person who cannot read tells the three suggestions apart before Speak (a private preview in the earpiece or headphones, pictures on cards, or both), and whether Another, Incorrect, Clear and the Listen controls should carry pictures too.
- No change: with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; install Xcode and Homebrew on your Mac; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if you want it.

## 2026-10-22, build run 6 (17:56 to about 19:35 Central)

Main was red at the start: CI was green for 98b9b0e (a PROGRESS-only commit), but the Xcode 27 "Build and test" job failed in `AccessibilityAuditUITests.testHome` setup with "Failed to terminate com.emilykenney.selvo", before the test body ran. Its one re-run then failed in a different place: `ScreenshotTests.testComponentGallery` could not encode its PNG (ImageIO "zlib error, No IDATs written"). The app had not changed since da70c3c, which was green, so both were the runner, and I made CI sturdy against each instead of only re-running.

### Shipped
- 3832eb4 `ci:` `scripts/ci_retry_launch_failures.sh`. When every failure in the test log is the Simulator failing to stop or start Selvo before a UI test runs (Failed to terminate, Failed to launch, Timed out while launching), CI runs just those UI tests once more after a fresh boot. Any other failure keeps the job red. Used by `ci.yml` and `demo-xcode27.yml`. Checked here with stubbed `xcrun` and `xcodebuild` on three logs: launch failure only (reruns that one test), launch failure plus a real assertion (no rerun), no failures (no rerun).
- a598fab `test:` a screenshot encodes once more when `pngData()` returns nothing.

### Verified, and how
- CI green for 3832eb4 (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39868624993) and a598fab (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39870874931), including `scripts/demo.sh` with Xcode 16 and 26 in all three forms.
- Xcode 27 green on every job for a598fab: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39870875010 (demo.sh with Xcode 27, demo.sh plus Listen on iOS 26.2 with on-device recognition, all tests on iOS 27). The Xcode 27 "Build and test" job was also green for 3832eb4, all 15 UI tests on the first try.
- The Xcode 27 run for 3832eb4 (39868625025) failed only its Listen check: the test passed and demo.sh passed, but on that runner the iOS 26.2 Simulator reported no on-device recognizer, so Selvo used Apple's server recognition (log "on device: false", then kAFAssistantErrorDomain 216), and the job rightly requires on device. The same job for a598fab ran on device. I read it as the runner's speech assets, not this change (CI scripts and a test only).
- Screenshots: `screenshots/03-home-night-default.png` for a598fab looked at; unchanged from run 5, as expected (no app code changed).

### Readings I took
- No app code the evening before the demo; only CI sturdiness, since the failures were the runner.
- The P3 "setup people rows are 76pt against 80pt" from run 4: the artboard row is 10 + 48 + 10 plus a 1pt border, about 70pt, so the 80 was a misreading; ours grows with the label line height. Left as is.

### Next
- Friday: final artboard pass on the final build, then the final PROGRESS summary for Emily. No new features after Friday.

### Needs Emily
- Worth knowing before the demo: when a phone or Simulator has no on-device recognizer, Listen falls back to Apple's server recognition (what the other person says goes to Apple; Selvo never keeps it). It happened once on a CI runner tonight. Decide whether Listen should instead say "Listening is not available" in that case (keeps everything on the phone).
- No change: decide how a person who cannot read tells the three suggestions apart before Speak; with Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear; install Xcode and Homebrew on your Mac; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`); the Daylight wordmark "vo" color; the real logo artwork if you want it.

## 2026-10-23, build run 1 (07:56 to about 09:10 Central): final summary for Emily

Main was green at the start (460fc25, CI and Xcode 27). Only Friday's final artboard pass and this summary were left.

### Shipped
- 8bdb364 `fix:` setup step 1 now speaks to the supporter, like steps 2 to 5: "Who is Selvo for?" and "Type the name they go by. They can change it later." Before, it asked the person to type their own name, which they may not be able to do.

### Verified, and how
- CI green on every job for 8bdb364: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39958054152 (`scripts/demo.sh` with Xcode 16 and 26, the TestFlight SDK build, SelvoCore tests, all app and UI tests with screenshots).
- Xcode 27 green on every job for 8bdb364: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39958054163 (`scripts/demo.sh` with Xcode 27, demo.sh plus Listen on iOS 26.2, all tests on iOS 27).
- Screenshots reviewed on `ci-screenshots`: `ui-demo-setup-1.png` for 8bdb364 (new copy, nothing clipped), `01-welcome-night-axl.png` for 460fc25.
- A reviewer agent that had not seen the code compared every screen for 460fc25 with the artboards and brand rules. **No P1**: Speak, Back, Clear and Help placement, one glow, copy rules, 44pt touch targets, orb sizes, Daylight colors and accessibility XL all pass. What I did with the rest:
  - Setup step 1 spoke to the wrong person: fixed (above).
  - Undo has no arrow until there is something to undo: left as is, decided Oct 19 so the off state does not rely on color alone.
  - Settings says the system voice name, not "Daniel, warm": left as is, the artboard is sample data.
  - Listen shows its empty state until someone talks: expected; the artboard shows a state after speech.
  - P3s left as is: default text size chip is the smallest (the person's own setting), Setup uses Slow and Fast buttons where Settings has a slider, the Settings caption fades at the scroll edge, the Lexend check is close to its text at accessibility XL, only one suggestion shows fully at accessibility XL before scrolling, "Set up together" wraps to two lines at accessibility XL (render only, not clipped), help phrase fields draw blank in renders (known ImageRenderer limit), setup shots use "Maya" while the demo profile is Lucas.

### Where Selvo stands for the demo
- Every item in PLAN.md through Friday is checked, and the TestFlight readiness section is built (it waits only on Emily's Apple details).
- `scripts/demo.sh` passes in CI with Xcode 16, 26 and 27, in its three forms (`./scripts/demo.sh`, `--fresh`, `--welcome`). `docs/DEMO.md` has the 5-minute walk: Welcome, Home, Choose your words, Speak and Spoken, Another, Incorrect and Undo, Show, Listen, Help, Settings.
- After today: no new features. Runs fix red CI and demo-blocking bugs and keep `docs/DEMO.md` and `docs/TESTFLIGHT.md` accurate.

### Next
- Week of Oct 26: TestFlight upload once Emily has added her Team ID and the secrets (`docs/TESTFLIGHT.md`). Nothing else is open in PLAN.md.

### Needs Emily
- Before the demo, on your Mac: install Xcode (16, 26 or 27) and Homebrew, then run `./scripts/demo.sh` (see `docs/DEMO.md`). With Xcode 27, or Xcode 26.4 or later, run `xcodebuild -downloadPlatform iOS -buildVersion 26.2` once so Listen can hear.
- Decide: how a person who cannot read tells the three suggestions apart before Speak (a private preview in the earpiece, pictures on cards, or both), and whether Another, Incorrect, Clear and the Listen controls should carry pictures.
- Decide: when a phone has no on-device recognizer, should Listen use Apple's server recognition (today) or say "Listening is not available".
- For TestFlight: your Team ID, confirm the bundle ID `com.emilykenney.selvo`, the App Store Connect app record, an API key and the four secrets (`docs/TESTFLIGHT.md`).
- Optional: the Daylight wordmark "vo" color; the real logo artwork.

## 2026-10-23, build run 2 (09:56 to about 10:10 Central): check only

Main was green at the start (288499d, CI and Xcode 27). Every item in PLAN.md is checked, so this run only checked that the demo is still ready, and changed no app code on demo day.

### Verified, and how
- CI green on every job for 288499d: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39962317624 (`scripts/demo.sh` with Xcode 16 and 26, TestFlight SDK build, all tests with screenshots).
- Xcode 27 green on every job for 288499d: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39962317668.
- Looked at `demo-xcode26/demo-launch-fresh.png` on `ci-screenshots` for 288499d: `./scripts/demo.sh --fresh` opens Home for Lucas, with the message strip, 4 tiles, Listen, Speak bottom center with its sound bars, gear and Help top right.
- Searched the repo outside `legacy/` and the design files for em and en dashes: none.
- Read `docs/DEMO.md` against the current app: still accurate.

### Readings I took
- No new code on demo day when everything is green and PLAN.md is done; a change now only adds risk.

### Next
- Week of Oct 26: TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- No change from build run 1 today: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (with Xcode 27 or 26.4 or later, also `xcodebuild -downloadPlatform iOS -buildVersion 26.2` so Listen can hear); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets.

## 2026-10-23, build run 3 (11:56 to about 12:05 Central): check only

Main was green at the start (325e3ea). Every item in PLAN.md is checked (50 of 50), so this run only confirmed the demo is still ready and changed no app code on demo day.

### Verified, and how
- CI green on every job for 325e3ea: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39974060739 (`scripts/demo.sh` with Xcode 16 and 26, TestFlight SDK build, all tests with screenshots).
- Xcode 27 green on every job for 325e3ea: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39974060688.
- Searched the repo outside `legacy/` and the design files for em and en dashes: none.

### Readings I took
- Same as run 2: no code changes on demo day while everything is green and PLAN.md is done.

### Next
- Week of Oct 26: TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- No change from build run 1 today: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (see `docs/DEMO.md`); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets.

## 2026-10-23, build run 4 (13:56 to about 14:05 Central): check only

Main was green at the start (b497335). Every item in PLAN.md is checked, so this run only confirmed the demo is still ready and changed no app code on demo day.

### Verified, and how
- CI green on every job for b497335: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39991016932 (`scripts/demo.sh` with Xcode 16 and 26, TestFlight SDK build, all tests with screenshots).
- Xcode 27 green on every job for b497335: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/39991016845.
- Searched the repo outside `legacy/` and the design files for em and en dashes: none.

### Readings I took
- Same as runs 2 and 3: no code changes on demo day while everything is green and PLAN.md is done.

### Next
- Week of Oct 26: TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- No change from build run 1 today: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (see `docs/DEMO.md`); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets.

## 2026-10-23, build run 5 (15:56 to about 16:05 Central): check only

Main was green at the start (1aedd92). Every item in PLAN.md is checked (50 of 50), so this run only confirmed the demo is still ready for 6pm and changed no app code on demo day.

### Verified, and how
- CI green on every job for 1aedd92: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40007441919 (`scripts/demo.sh` with Xcode 16 and 26, TestFlight SDK build, SelvoCore tests, all tests with screenshots).
- Xcode 27 green on every job for 1aedd92: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40007441746.
- Searched the repo outside `legacy/` and the design files for em and en dashes: none.

### Readings I took
- Same as runs 2 to 4: no code changes on demo day while everything is green and PLAN.md is done.

### Next
- After Friday no new features. Week of Oct 26: TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- No change from build run 1 today: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (see `docs/DEMO.md`); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets.

## 2026-10-23, build run 6 (17:55 to about 20:55 Central): red Xcode 27 run fixed in CI and tests only

Main was 4383600 at the start. CI was green on every job: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40023063791. The Xcode 27 workflow was red on one job: "scripts/demo.sh and Listen (Xcode 27, iOS 26.2 Simulator added)". Its demo step ran for 40 minutes and was cancelled, and the job then hit its 75 minute limit. The job logs could not be downloaded (404).

### What I did
- That commit changed only PROGRESS.md, and the same app code passed this job five times today. I took it to be a stuck runner or Simulator, not a fault in the app, and re-ran the failed job once.
- The re-run was green on every job: https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40023063840 (attempt 2). The demo step finished in about 11 minutes and picked iOS 26.2; Listen passed. No app code changed on demo day.

- It hung again on the next push (8c8e6c7, run https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40040040394): the iOS 26.2 demo step ran for 45 minutes. I cancelled it; again no log could be downloaded. The other Xcode 27 jobs and all of CI were green.
- `ci:` the iOS 26.2 demo step in `demo-xcode27.yml` now has a 20 minute watchdog. If `demo.sh` is still running, it prints the last lines and the Simulator and xcodebuild processes, resets the Simulator service, and runs once more; a second hang or any failure stays red. The step has a 50 minute limit and the job 95. Checked locally: YAML parses, `bash -n`, and a fake demo.sh that hangs, then passes, and one that fails.

- With the watchdog (179a14a, https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40044878549) the iOS 26.2 demo step passed in 17 minutes, without needing the watchdog. CI was green. But "Build and test (Xcode 27, iOS 27 Simulator)" failed in `ScreenshotTests.testComponentGallery`: `00-components did not encode`. The log shows why: the first render in the test process waited about 11 seconds for the GPU pipeline ("building pipeline took 11.3 seconds"), and until then ImageIO timed out ("waiting for phase 6") and wrote nothing (zlib error). The Oct 22 fix tried to encode only twice, right away.
- `test:` the screenshot test now tries to encode up to five times, two seconds apart, letting the run loop turn in between. Tests only; no app code changed.

- Green on every job for f430e81: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40048224031 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40048224041 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh plus Listen on iOS 26.2, all tests with screenshots on iOS 27). The iOS 26.2 demo step took 17 to 18 minutes on the last two runs, against 6 to 11 earlier today; the watchdog did not need to step in. No screenshots changed, so I did not review them again.

### Readings I took
- Twice in three tries is not a flake to wave through, but with no logs the cause is unknown. I did not change `scripts/demo.sh` tonight, since Emily may be running it for the demo; the watchdog only changes CI and makes the next hang show where it stops. If it shows `simctl bootstatus` or xcodebuild stuck on the iOS 26.2 Simulator, a later run can add the same reset to demo.sh.

### Next
- After Friday no new features. Week of Oct 26: TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- No change from build run 1 today: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (see `docs/DEMO.md`); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback; for TestFlight your Team ID, the bundle ID, the App Store Connect app record, an API key and the four secrets.

## 2026-10-26, build run 1 (08:02 to about 08:30 Central): check only, TestFlight week

Main was green at the start (ea9f097): CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40051791596 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40051791637, both green on every job (`scripts/demo.sh` with Xcode 16, 26 and 27, Listen on iOS 26.2, all tests with screenshots). Every item in PLAN.md is checked, including the TestFlight readiness section, so this run changed no code.

### Verified, and how
- No new commits on main since Friday night; no open issues.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`, and the TestFlight workflow has never been run, so the upload is waiting on Emily.
- `docs/TESTFLIGHT.md` matches `testflight.yml`: four secrets (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `APPLE_TEAM_ID`).
- Searched the repo outside `legacy/` and the design files for em and en dashes: none.

- This run's push (a214fa6) was green on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40327370839 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40327370730. But the iOS 26.2 demo step took 21.5 minutes (17 on Friday, 6 to 11 before), past the 20 minute watchdog, so it most likely needed its second try. The job log could not be downloaded (403), so this is not confirmed. If it keeps growing, a later run should find where it slows; demo.sh itself on Xcode 16, 26 and 27 stays at about 10 minutes.

### Readings I took
- After Friday no new features; with CI green and the TestFlight section done, the right work is to keep watch and not churn the code.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- For TestFlight this week: your Team ID, confirm the bundle ID `com.emilykenney.selvo`, create the App Store Connect app record and an API key, add the four secrets, then run the TestFlight workflow by hand (`docs/TESTFLIGHT.md`).
- Still open: install Xcode and Homebrew on your Mac and run `./scripts/demo.sh` (see `docs/DEMO.md`); decide how a person who cannot read tells the three suggestions apart before Speak; decide on Listen's server recognition fallback.

## 2026-10-26, build run 2 (09:57 to about 10:10 Central): check only

Main was green at the start (77ea5fb) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40333381823 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40333381901 (`scripts/demo.sh` with Xcode 16, 26 and 27, Listen on iOS 26.2, all tests with screenshots). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- The iOS 26.2 demo step took 13.5 minutes on 77ea5fb, under the 20 minute watchdog, so the 21.5 minute run this morning looks like a slow runner, not a trend. Read from the job step times with `gh api`.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no TestFlight workflow run exists yet; no open issues.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged from run 1 today: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-26, build run 3 (11:56 to about 12:05 Central): check only

Main was green at the start (8e7da8d) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40344603484 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40344603835 (`scripts/demo.sh` with Xcode 16, 26 and 27, Listen on iOS 26.2, all tests with screenshots). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- The iOS 26.2 demo step took about 14 minutes, under the 20 minute watchdog (job step times via `gh api`).
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no TestFlight workflow run exists; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-26, build run 4 (13:56 to about 14:05 Central): check only

Main was green at the start (c0e5245) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40363997263 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40363995708 (`scripts/demo.sh` with Xcode 16, 26 and 27, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Job conclusions and step times via `gh api`; `scripts/demo.sh` took about 9 minutes on Xcode 26 and 8 on Xcode 16.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-26, build run 5 (15:56 to about 16:05 Central): check only

Main was green at the start (2ff7498) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40382257495 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40382257524 (`scripts/demo.sh` with Xcode 16, 26 and 27, Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Job conclusions and step times via `gh api`: `scripts/demo.sh` took about 7 minutes on Xcode 16 and 26; the iOS 26.2 demo step took about 16 minutes, under the 20 minute watchdog.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run (0 runs); no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-26, build run 6 (17:56 to about 18:40 Central): fixed a red Xcode 27 run

Main was red at the start (935187e): CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40400140079 was green, but Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40400140302 failed in "Listen on the iOS 26.2 Simulator". The Listen UI test itself passed and `scripts/demo.sh` passed; the Simulator log query came back with no Selvo listen lines, so the "on device: true" check failed. 935187e changed only PROGRESS.md.

### What changed
- 5bb45b2 `ci:` in `demo-xcode27.yml`, the iOS 26.2 Listen step:
  - It now really fails when the test fails. Under `set +e` the `grep -q "test exit 0"` line never stopped the step, so two Listen test failures passed silently (325e3ea on Oct 23 and 2ff7498 today, both "Failed to get screenshot: Timed out while requesting screenshot"). Found by reading the published `listen-ios26.txt` for the last 20 runs on `ci-screenshots`.
  - "Timed out while requesting screenshot" joins the Simulator failures that get one rerun after a fresh boot. A second failure stays red.
  - The log query runs up to three times, 15 seconds apart, when it finds no listen lines, and records log show's own messages (never Selvo's lines) so the next empty result can be explained.

### Verified, and how
- The edited step run locally with stubbed `xcrun` and `xcodebuild` in five cases: pass with log (green), pass with an empty log every time (red after 3 queries), log on the second query (green), a screenshot timeout then a pass (green after 2 test runs), a real assertion failure with "on device: true" in the log (red; it was green before this fix).
- 5bb45b2 green on every job. CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40416589295 (`scripts/demo.sh` with Xcode 16 and 26, all tests with screenshots, the Xcode 26 TestFlight SDK build). Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40416589294 (`scripts/demo.sh` with Xcode 27; demo.sh with iOS 26.2, about 18 minutes; Listen "on device: true" on the first log query; all tests on iOS 27).
- No app code changed, so no screenshots were reviewed again. `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run; no open issues.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the Listen screenshot timeout keeps coming back even after its one rerun, look at the test's screenshot attachments next.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 1 (08:24 to about 09:35 Central): a Listen flake on Xcode 27, confirmed and made visible

Main was red at the start (a88209d): CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40420577849 was green, but Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40420577810 failed in "Listen on the iOS 26.2 Simulator". The stricter check from 5bb45b2 caught a real test failure this time: `DemoWalkUITests.swift:182` "Listen shows whether it is listening". The Listen screen opened, but no status line was found in 20 seconds, the test took 263 seconds instead of the usual 37, and Selvo never logged "Starting recognition". a88209d changed only PROGRESS.md; the same code passed this step on 5bb45b2 and passed the same test on iOS 27 in the same run. Every Listen state shows a status line, so the reading taken is a stalled Simulator, not an app bug.

### What changed
- Re-ran the failed job once (attempt 2 of run 40420577810): green, which confirms the flake on unchanged code.
- f04eb0a `ci:` in `demo-xcode27.yml`, the iOS 26.2 Listen step keeps each attempt's result bundle and, only when the test fails, exports XCTest's screenshots into a `failure/` folder published with `demo-xcode27-ios26` on `ci-screenshots`. Nothing showed the screen last time. This cannot turn a pass red; the same two checks still decide the step. Not yet exercised on a failure, since the run after it passed.

### Verified, and how
- f04eb0a green on every job. CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40512294929 (`scripts/demo.sh` with Xcode 16 and 26, all tests with screenshots, the Xcode 26 TestFlight SDK build). Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40512294650 (`scripts/demo.sh` with Xcode 27, about 10 minutes; demo.sh and Listen on iOS 26.2, about 38 minutes, Listen "on device: true" after one accessibility rerun; all tests on iOS 27).
- Read the published `listen-ios26.txt` for the last 20 runs on `ci-screenshots` to separate this failure from the earlier screenshot timeouts.
- No app code changed, so no screenshots were reviewed again. `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run; no open issues.
- Job logs through `gh api .../jobs/ID/logs` came back Forbidden from the log store in this environment; the GitHub MCP `get_job_logs` tool worked.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the "no status" failure comes back, look at the `failure/` screenshots before changing anything.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 2 (10:09 to about 10:15 Central): check only

Main was green at the start (c3cda06) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40522087584 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40522087523 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Job conclusions and times via `gh api`; the iOS 26.2 demo and Listen job took about 37 minutes and passed, so the `failure/` screenshot export was not exercised.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run (0 runs); no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the Listen "no status" failure comes back, look at the `failure/` screenshots before changing anything.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 3 (11:57 to about 12:02 Central): check only

Main was green at the start (0a1eeba) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40528311487 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40528311472 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Job conclusions and times via `gh api`: `scripts/demo.sh` took about 11 minutes on Xcode 16, 8 on Xcode 26 and 11 on Xcode 27; the iOS 26.2 demo and Listen job took about 32 minutes and passed.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run (0 runs); no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the Listen "no status" failure comes back, look at the `failure/` screenshots before changing anything.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 4 (13:56 to about 14:00 Central): check only

Main was green at the start (7eb8ec2) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40546029836 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40546029757 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`: CI took about 18 minutes and Xcode 27 about 34 minutes, both passed.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the Listen "no status" failure comes back, look at the `failure/` screenshots before changing anything.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 5 (15:56 to about 16:00 Central): check only

Main was green at the start (41032fb) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40564667065 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40564666936 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Job conclusions and times via `gh api`: the iOS 26.2 demo and Listen job took about 28 minutes and passed; `scripts/demo.sh` on Xcode 27 took about 12 minutes.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; the TestFlight workflow has never been run (0 runs); no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs. If the Listen "no status" failure comes back, look at the `failure/` screenshots before changing anything.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-27, build run 6 (17:56 to about 18:40 Central): Listen check red on c8fe70d, fixed

Main started red: the Xcode 27 run for c8fe70d failed (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40582533722) in the iOS 26.2 Listen check. CI was green. Listen started on device (log: on device true, 48 kHz) and the published failure screenshot shows Listening with Stop listening, so Listen itself worked. After the tap on Stop listening, Home did not show Speak within 20 seconds; the test took 261 seconds on a slow runner. This is the case run notes from Oct 21 (823ca7d) predicted.

### Changed
- `SelvoUITests/DemoWalkUITests.swift`: the final wait for Home after Stop listening is 60 seconds (all other waits unchanged).
- `Selvo/App/SpeechListener.swift`: `stop()` logs "Stopped listening" (state only, never what was heard), so a future failure shows whether the tap reached Selvo or the screen was just slow to go back.
- Reading taken: a slow CI Simulator, not a demo bug, since Listen and Stop work on every other run and on Xcode 16 and 26. No app behavior changed.

### Verified, and how
- 0a90beb is green on both workflows: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40598967221 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40598967282 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots).
- `listen-ios26.txt` on `ci-screenshots` for 0a90beb: test exit 0 in 71 seconds; log shows Starting recognition, then Stopped listening 4.6 seconds later.
- Job logs: `gh api .../logs` is still Forbidden from the log store; the GitHub MCP `get_job_logs` tool worked.
- No screenshots changed visually; the failure screenshot (Listen, Listening state) was reviewed and matches the artboard.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). If "Home shows Speak" after Stop fails again, check the log for "Stopped listening": present means the screen was slow to go back; absent means the tap never reached Selvo.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 1 (08:07 to about 08:10 Central): check only

Main was green at the start (5d3ea8c) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40603205862 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40603205782 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen check that was red on c8fe70d stayed green on 0a90beb and 5d3ea8c.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 2 (09:56 to about 10:32 Central): Listen check red on f1c559f, fixed

Main started red: the Xcode 27 run for f1c559f failed (https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40693600751) in the iOS 26.2 Listen check, "Home shows Speak" after 60 seconds. CI was green. The log has "Starting recognition" but no "Stopped listening", and the failure screenshot still shows Listening with Stop listening, so (as the Oct 27 note predicted) the tap never reached Selvo. The test took 269 seconds, a slow runner.

### Changed
- `SelvoUITests/DemoWalkUITests.swift`: after the tap on Stop listening (or Done), wait 20 seconds for Home; if it is not there and the button is still on screen, tap again, up to three taps in all, then require Home. No app code changed.
- Reading taken: a dropped synthesized tap on a slow CI Simulator, not a demo bug, since the app's Stop path is a direct call and works on every other run.

### Verified, and how
- e58882f is green on both workflows: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40711471111 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40711471133 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build).
- `listen-ios26.txt` on `ci-screenshots` for e58882f: test exit 0; log shows Starting recognition, then Stopped listening 4 seconds later.
- Failure screenshot for f1c559f reviewed: Listen in the Listening state, matches the artboard. No other screenshots changed.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 3 (11:56 to about 12:00 Central): check only

Main was green at the start (b99bd74) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40717005372 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40717005453 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held on b99bd74.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 4 (13:56 to about 13:59 Central): check only

Main was green at the start (d660969) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40730867895 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40730867957 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a second commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 5 (15:56 to about 15:59 Central): check only

Main was green at the start (488bfc3) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40749776543 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40749776513 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a third commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-28, build run 6 (17:55 to about 17:58 Central): check only

Main was green at the start (64055da) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40767678613 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40767678605 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a fourth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-29, build run 1 (08:19 to about 08:22 Central): check only

Main was green at the start (3980518) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40783688186 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40783688278 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a fifth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-29, build run 2 (10:12 to about 10:15 Central): check only

Main was green at the start (264a242) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40880972988 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40880973094 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a sixth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-29, build run 3 (11:55 to about 11:58 Central): check only

Main was green at the start (829a868) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40899248595 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40899248573 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a seventh commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-29, build run 4 (13:55 to about 13:58 Central): check only

Main was green at the start (27d0683) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40916440812 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40916440929 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for an eighth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-29, build run 5 (17:56 to about 17:59 Central): check only

Main was green at the start (951fca8) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40935422085 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40935421988 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a ninth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-30, build run 1 (08:31 to about 08:34 Central): check only

Main was green at the start (5382c6a) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40969628951 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/40969629038 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run conclusions via `gh api`; the Listen retry from e58882f held for a tenth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-30, build run 2 (10:22 to about 10:26 Central): check only

Main was green at the start (6e8d9c7) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41064020695 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41064020319 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run and job conclusions via `gh api`; the Listen retry from e58882f held for an eleventh commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-30, build run 3 (12:03 to about 12:06 Central): check only

Main was green at the start (bb0206b) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41080248730 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41080248446 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run and job conclusions via `gh api`; the Listen retry from e58882f held for a twelfth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-30, build run 4 (13:56 to about 13:59 Central): check only

Main was green at the start (891a365) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41095568612 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41095568709 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run and job conclusions via `gh api`; the Listen retry from e58882f held for a thirteenth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).

## 2026-10-30, build run 5 (15:56 to about 15:59 Central): check only

Main was green at the start (f12efd4) on every job: CI https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41111141623 and Xcode 27 https://github.com/emily-bradley/personalized_communication_companion/actions/runs/41111141651 (`scripts/demo.sh` with Xcode 16, 26 and 27, demo.sh and Listen on iOS 26.2, all tests with screenshots, the Xcode 26 TestFlight SDK build). Every item in PLAN.md is checked, so this run changed no code.

### Verified, and how
- Run and job conclusions via `gh api`; the Listen retry from e58882f held for a fourteenth commit.
- `Config/Signing.xcconfig` still reads `DEVELOPMENT_TEAM = [EMILY_TEAM_ID]`; no open issues.
- No screenshots changed, so none were reviewed again.

### Next
- TestFlight upload once Emily adds her Team ID and the secrets (`docs/TESTFLIGHT.md`). Later runs fix only red CI or demo-blocking bugs.

### Needs Emily
- Unchanged: Team ID, confirm bundle ID `com.emilykenney.selvo`, App Store Connect app record, API key, the four secrets, then run the TestFlight workflow by hand; run `./scripts/demo.sh` on your Mac; the two open design decisions (telling the three suggestions apart without reading; Listen's server fallback).
