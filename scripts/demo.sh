#!/usr/bin/env bash
# One command to see Selvo in the iOS Simulator on a Mac with Xcode 16.
#
#   ./scripts/demo.sh
#
# It installs XcodeGen with Homebrew if needed, generates the Xcode project, builds Selvo for an
# iPhone 16 Simulator (no signing needed), boots the Simulator, then installs and launches Selvo
# with the demo profile for Lucas. CI runs this same script on every push.
set -euo pipefail

cd "$(dirname "$0")/.."
BUNDLE_ID="com.emilykenney.selvo"
DERIVED="build/DerivedData"
APP="$DERIVED/Build/Products/Debug-iphonesimulator/Selvo.app"

say() { printf '\n==> %s\n' "$1"; }
fail() { printf '\nSelvo demo stopped: %s\n' "$1" >&2; exit 1; }

say "Checking Xcode"
command -v xcodebuild >/dev/null 2>&1 || fail "Xcode is not installed. Install Xcode 16 from the App Store, open it once, then run this again."
# Capture first, then print: piping into head can break the pipe and abort xcodebuild.
XCODE_VERSION="$(xcodebuild -version 2>/dev/null)" || fail "Xcode is installed but not selected. Run: sudo xcode-select -s /Applications/Xcode.app"
echo "${XCODE_VERSION%%$'\n'*}"
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

say "Finding an iPhone 16 Simulator"
UDID="$(python3 scripts/find_simulator.py "iPhone 16")"
echo "Simulator $UDID"

say "Booting the Simulator"
xcrun simctl boot "$UDID" 2>/dev/null || true
if [ -z "${CI:-}" ]; then
  open -a Simulator --args -CurrentDeviceUDID "$UDID" || true
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
xcrun simctl launch "$UDID" "$BUNDLE_ID" -SelvoDemoProfile YES

# Give the app a moment, then make sure it is still running and keep a picture of the screen.
sleep 5
RUNNING="$(xcrun simctl spawn "$UDID" launchctl list 2>/dev/null || true)"
case "$RUNNING" in
  *"$BUNDLE_ID"*) ;;
  *) fail "Selvo launched but is not running. Open it in Xcode to see the crash." ;;
esac
mkdir -p build
xcrun simctl io "$UDID" screenshot build/demo-launch.png >/dev/null 2>&1 || true

say "Selvo is running in the Simulator"
