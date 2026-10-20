# Selvo demo in the iOS Simulator

This runs Selvo on your Mac in the iOS Simulator, with the demo profile for Lucas already loaded. No iPhone, signing, or Apple account is needed.

## Before the demo (once, allow about 1 hour, mostly downloads)

1. **A Mac that runs Xcode 16 or Xcode 26.** The Mac App Store now offers Xcode 26, which needs macOS Sequoia 15.6 or later. On an older Mac, Xcode 16 needs macOS Sonoma 14.5 or later and can be downloaded from [developer.apple.com/download/all](https://developer.apple.com/download/all/) with your Apple account. Check your macOS version in Apple menu, **About This Mac**. The demo script is tested with both Xcode 16 and Xcode 26 on every change.
2. **Xcode** from the Mac App Store. Open it once, accept the license, and when it asks which platforms to install, include **iOS**. If you skipped that, open Xcode, **Settings**, **Components**, and download the iOS Simulator platform.
3. **Command Line Tools.** Open Terminal and run:
   ```
   xcode-select --install
   ```
   If it says they are already installed, you are set. If Terminal later says Xcode is not selected, run `sudo xcode-select -s /Applications/Xcode.app`.
4. **Homebrew** from [brew.sh](https://brew.sh). Paste the one line from that page into Terminal and follow what it prints at the end (it asks you to run 2 lines that add `brew` to your path).
5. **Get the code.** In Terminal:
   ```
   git clone https://github.com/emily-bradley/personalized_communication_companion.git
   cd personalized_communication_companion
   ```

Do a full practice run the day before. The first build and the first Simulator boot are the slow ones.

## The one command

From the repository folder:

```
./scripts/demo.sh
```

What it does:

1. Checks that Xcode is installed and selected.
2. Installs XcodeGen with Homebrew if it is missing.
3. Generates `Selvo.xcodeproj` from `project.yml`.
4. Finds an iPhone 16 Simulator, boots it, and opens the Simulator app.
5. Builds Selvo for the Simulator (a few minutes the first time, under a minute after that).
6. Installs Selvo and launches it with the demo profile for Lucas.
7. Checks Selvo is still running and saves a picture of the screen to `build/demo-launch.png`.

When it prints `Selvo is running in the Simulator`, you are ready. Running it again is safe: it reinstalls and relaunches Selvo and keeps the saved profile, including anything changed in a rehearsal.

Two options start over:

| Command | Opens on | Use it |
| --- | --- | --- |
| `./scripts/demo.sh --fresh` | Home, with a fresh profile for Lucas | After every rehearsal, so theme, text size, font, speech rate, voice, tile and help phrase changes are all undone |
| `./scripts/demo.sh --welcome` | Welcome, with no profile | When you want to show Welcome or Set up together |

Both delete Selvo's saved profile first. CI runs all three forms on every change.

## How the demo profile loads

Selvo shows Welcome only when there is no saved profile. Once a profile is saved, Selvo always opens it, whatever the launch says. When there is none, it decides whether to load Lucas like this (`shouldSeedDemo` in `Selvo/App/AppModel.swift`):

- Launched with `-SelvoDemoProfile YES` (`demo.sh` and `demo.sh --fresh`): load Lucas.
- Launched with `-SelvoDemoProfile NO` (`demo.sh --welcome`): show Welcome.
- No launch argument, for example tapping the Selvo icon in the Simulator: load Lucas in the Simulator; show Welcome on an iPhone.

From Welcome, **I already have a profile** opens Selvo with a fresh profile for Lucas. **Set up together** walks through the 5 setup steps (name, people, places, text size and theme, voice), and the person made there becomes the saved profile. Run `./scripts/demo.sh --fresh` to get Lucas back.

## The 5 minute demo

Times are a guide. Tap with the mouse or trackpad. Turn the Mac volume up before you start.

**1. Welcome (30 seconds, optional)**
If you started with `./scripts/demo.sh --welcome`: the orb, the Selvo wordmark, and "Your voice. Your way." Say that setup happens together, with the person who will use Selvo holding the phone. Tap **I already have a profile**.

**2. Home (30 seconds)**
The message strip at the top says "Tap a picture to start." Below it, a greeting for Lucas, then 4 tiles (Photos, Places, People, Phrases) and the Listen row. **Speak** is at the bottom, full width. **Settings** and **Help** are top right. Point out that tiles never move, so Lucas learns where things are.

**3. Photos, then Coffee (30 seconds)**
Tap **Photos**. Lucas's pictures appear in a fixed grid: Coffee, Dinner, Home, Car, and more, with a second page (the dots below the grid). The demo pictures are drawn symbols, never real photos; a supporter can add a real photo to any tile. Tap **Coffee**.

**4. Choose your words (90 seconds)**
- Selvo offers 3 suggestions about coffee, in Lucas's styles (plain, witty, short). The first is already chosen and in the message strip. Tap the second one and the strip changes.
- Tap **Another**: 3 different suggestions arrive. On a Mac with Apple Intelligence turned on, the Simulator may use the on-device model here, so the words can differ from run to run. Saved phrases always fill in, and nothing waits.
- Tap **Incorrect**: the selected suggestion is removed and a new one takes its place, in the same spot. The other two do not move.
- Tap **Undo**: what was there before comes back.
- Point out that nothing times out or disappears on its own. **Clear** (top right) empties the message and goes back to Home; you do not need to tap it now.

**5. Speak (20 seconds)**
Tap **Speak**. The Mac speaks the message, and **Spoken** shows for about a second where Another and Incorrect were.

**6. Show (20 seconds)**
Tap **Show** under the message. The message fills the screen in large type, for a noisy room or a listener who reads better than they hear. It is turned upside down on purpose: the phone lies on the table facing the person across from Lucas, so on the Mac it reads upside down. Tap **Done** to go back to your words.

**7. Listen (60 seconds)**
Tap **Clear** (top right) to empty the message and go back to Home, then tap **Listen**. The first time, the Simulator asks for the microphone and speech recognition: allow both. macOS may also ask whether Simulator can use the microphone: allow it. Say a short sentence near the Mac, such as "Do you want to go to the park later?" What you said appears as text. Tap **Show replies**, tap one of the 3 replies Lucas could choose, then **Speak**. Speak stops listening first so the phone does not hear its own voice, and the **Stop listening** button above Speak becomes **Listen again**. Tap **Back** to go home.

**8. Help (20 seconds)**
On Home, tap **Help** (top right). Selvo asks "Show the help screen?" so it never opens by accident. Tap **Yes, show it**. The screen fills with "I need help." and Lucas's phrase in large type. It stays until someone taps **Done**.

**9. Settings (40 seconds)**
On Home, tap **Settings** (the gear, top right).
- **Text size**: tap the largest A. The whole screen grows, not only the preview, so you can see what Lucas would see. Tap the smallest A again before going on, or scroll down for the rest.
- **Theme**: switch between Nightlight and Daylight.
- **Speech rate**: move from Slow toward Fast.
- **Reading font**: tap **Atkinson** (Atkinson Hyperlegible, made for low-vision readers), then **Lexend** again.
- **Voice** (pinned at the bottom): open it and tap a voice to hear it, or tap **Play a sample** to hear the new rate.

Settings are saved. Before the real demo, run `./scripts/demo.sh --fresh` to undo everything changed in rehearsal.

## If something goes wrong

**The Simulator is slow, or stays black, the first time.** The first boot of a new Simulator can take 2 to 5 minutes. Wait for the iPhone home screen. If the script stops, run `./scripts/demo.sh` again; the second run is much faster.

**No sound when you tap Speak.** Check the Mac volume and that it is not muted. In the Simulator menu bar, open **I/O**, then **Audio Output**, and choose your Mac speakers or headphones. Bluetooth headphones sometimes take the sound: disconnect them or pick them there.

**Listen shows nothing, or says it cannot listen.**
- Check that the microphone was allowed. In the Simulator, open the **Settings** app, scroll to **Selvo**, and turn on **Microphone** and **Speech Recognition**.
- Check that the Mac allows the Simulator to use the microphone: Apple menu, **System Settings**, **Privacy & Security**, **Microphone**, and turn on **Simulator**.
- In the Simulator menu bar, **I/O**, **Audio Input**, choose the Mac microphone.
- Connect or disconnect Bluetooth headphones before the demo, not during Listen: changing the Mac's microphone while Selvo is listening can stop it.
- Speech recognition in the Simulator can be slow or unavailable on some Macs. If Listen does not work, skip it and say it is shown best on an iPhone.

**Selvo crashed or looks stuck.** Run `./scripts/demo.sh` again. It closes and relaunches Selvo. If it still looks wrong, run `./scripts/demo.sh --fresh`, which also clears the saved profile.

**The script says Xcode or Homebrew is missing.** Follow the line it prints, then run it again.

**Nothing else works.** As a last resort, run:

```
xcrun simctl erase all
```

This resets every Simulator on the Mac to a fresh state, as if new: all apps and data in all Simulators are deleted, including Selvo's saved profile. Quit the Simulator app first. Then run `./scripts/demo.sh` again; expect the slow first boot again.
