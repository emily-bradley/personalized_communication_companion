#!/usr/bin/env bash
# CI only: select the newest installed Xcode with the given major version (default 16, to
# match Emily's Mac). TestFlight uploads use 26 because App Store Connect requires the iOS 26
# SDK for uploads since April 2026.
set -euo pipefail
MAJOR="${1:-16}"
ls -d /Applications/Xcode*.app || true
pick="$(ls -d /Applications/Xcode_"$MAJOR"*.app 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$pick" ]; then
  sudo xcode-select -s "$pick/Contents/Developer"
else
  echo "No Xcode $MAJOR found; using the default Xcode."
fi
xcodebuild -version
