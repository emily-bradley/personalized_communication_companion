#!/usr/bin/env bash
# One command to see Selvo in the iOS Simulator on a Mac with Xcode 16, 26 or 27.
#
#   ./scripts/demo.sh            open Selvo, keeping what is saved (first run: Lucas)
#   ./scripts/demo.sh --fresh    start over with a fresh Lucas (clears rehearsal changes)
#   ./scripts/demo.sh --welcome  start over on the Welcome screen
#   ./scripts/demo.sh --ios 18   use the iOS 18 Simulator (can be combined with the others)
#
# It installs XcodeGen with Homebrew if needed, generates the Xcode project, builds Selvo for an
# iPhone 16 Simulator (no signing needed), boots the Simulator, then installs and launches Selvo
# with the demo profile for Lucas. CI runs this same script on every push.
set -euo pipefail

cd "$(dirname "$0")/.."
BUNDLE_ID="com.emilykenney.selvo"
DERIVED="build/DerivedData"
APP="$DERIVED/Build/Products/Debug-iphonesimulator/Selvo.app"

# Launch arguments for Selvo. Reset deletes the saved profile and every setting in it.
MODE=""
IOS=""
LAUNCH_ARGS=(-SelvoDemoProfile YES)
while [ $# -gt 0 ]; do
  case "$1" in
    --fresh) MODE="fresh"; LAUNCH_ARGS=(-SelvoDemoProfile YES -SelvoResetProfile) ;;
    --welcome) MODE="welcome"; LAUNCH_ARGS=(-SelvoDemoProfile NO -SelvoResetProfile) ;;
    --ios) [ $# -ge 2 ] || { printf 'Usage: ./scripts/demo.sh [--fresh | --welcome] [--ios 18]\n' >&2; exit 2; }; IOS="$2"; shift ;;
    *) printf 'Usage: ./scripts/demo.sh [--fresh | --welcome] [--ios 18]\n' >&2; exit 2 ;;
  esac
  shift
done
case "$IOS" in
  ""|[0-9]|[0-9][0-9]) ;;
  *) printf 'Usage: ./scripts/demo.sh [--fresh | --welcome] [--ios 18]\n' >&2; exit 2 ;;
esac
SHOT="build/demo-launch${MODE:+-$MODE}.png"

say() { printf '\n==> %s\n' "$1"; }
fail() { printf '\nSelvo demo stopped: %b\n' "$1" >&2; exit 1; }

say "Checking Xcode"
command -v xcodebuild >/dev/null 2>&1 || fail "Xcode is not installed. Install Xcode from the App Store, open it once, then run this again."
# When the Mac points at the Command Line Tools instead of Xcode (common after
# xcode-select --install), use Xcode for this script only, so no sudo is needed.
case "${DEVELOPER_DIR:-$(xcode-select -p 2>/dev/null || true)}" in
  *CommandLineTools*|"")
    for candidate in /Applications/Xcode.app /Applications/Xcode*.app; do
      if [ -x "$candidate/Contents/Developer/usr/bin/xcodebuild" ]; then
        export DEVELOPER_DIR="$candidate/Contents/Developer"
        echo "Using $candidate"
        break
      fi
    done
    ;;
esac
# Capture first, then print: piping into head can break the pipe and abort xcodebuild.
if ! XCODE_VERSION="$(xcodebuild -version 2>/dev/null)"; then
  fail "xcodebuild could not run. It said:\n$(xcodebuild -version 2>&1 | tail -n 3)\nIf it mentions the license, run: sudo xcodebuild -license accept\nIf Xcode is not selected, run: sudo xcode-select -s /Applications/Xcode.app\nThen run: xcodebuild -runFirstLaunch"
fi
echo "${XCODE_VERSION%%$'\n'*}"
xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1 || fail "Xcode needs to finish its first launch setup. Run: sudo xcodebuild -runFirstLaunch\nThen run this again."
command -v python3 >/dev/null 2>&1 || fail "python3 is missing. Run: xcode-select --install"

if ! command -v xcodegen >/dev/null 2>&1; then
  say "Installing XcodeGen"
  if ! command -v brew >/dev/null 2>&1; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$candidate" ] && eval "$("$candidate" shellenv)" && break
    done
  fi
  command -v brew >/dev/null 2>&1 || fail "Homebrew is not installed. Install it from https://brew.sh, then run this again."
  brew install xcodegen
fi

say "Generating the Xcode project"
xcodegen generate --quiet

say "Finding an iPhone 16 Simulator${IOS:+ with iOS $IOS}"
UDID="$(python3 scripts/find_simulator.py "iPhone 16" "$IOS")"
echo "Simulator $UDID"

say "Booting the Simulator (the very first boot can take about 5 minutes)"
xcrun simctl boot "$UDID" 2>/dev/null || true
if [ -z "${CI:-}" ]; then
  # Open the Simulator that belongs to the Xcode in use, in case there are two.
  SIM_APP="${DEVELOPER_DIR:-$(xcode-select -p)}/Applications/Simulator.app"
  if [ -d "$SIM_APP" ]; then
    open "$SIM_APP" --args -CurrentDeviceUDID "$UDID" || true
  else
    open -a Simulator --args -CurrentDeviceUDID "$UDID" || true
  fi
fi
xcrun simctl bootstatus "$UDID" -b >/dev/null

say "Building Selvo (the first build takes a few minutes)"
xcodebuild build \
  -project Selvo.xcodeproj \
  -scheme Selvo \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

[ -d "$APP" ] || fail "The build finished but Selvo.app was not found at $APP"

say "Installing and launching Selvo"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" "$BUNDLE_ID" "${LAUNCH_ARGS[@]}"

# Give the app a moment, then make sure it is still running and keep a picture of the screen.
sleep 5
RUNNING="$(xcrun simctl spawn "$UDID" launchctl list 2>/dev/null || true)"
case "$RUNNING" in
  *"$BUNDLE_ID"*) ;;
  *) fail "Selvo launched but is not running. Open it in Xcode to see the crash." ;;
esac
mkdir -p build
xcrun simctl io "$UDID" screenshot "$SHOT" >/dev/null 2>&1 || true

case "$MODE" in
  fresh) say "Selvo is running in the Simulator with a fresh profile for Lucas" ;;
  welcome) say "Selvo is running in the Simulator on the Welcome screen" ;;
  *) say "Selvo is running in the Simulator" ;;
esac
