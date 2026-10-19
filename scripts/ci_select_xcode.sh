#!/usr/bin/env bash
# CI only: select the newest Xcode 16 on the runner so CI matches Emily's Mac.
set -euo pipefail
ls -d /Applications/Xcode*.app || true
pick="$(ls -d /Applications/Xcode_16*.app 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$pick" ]; then
  sudo xcode-select -s "$pick/Contents/Developer"
fi
xcodebuild -version
