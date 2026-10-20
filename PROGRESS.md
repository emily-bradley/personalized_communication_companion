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
