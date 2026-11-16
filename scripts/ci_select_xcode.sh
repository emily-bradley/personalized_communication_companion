#!/usr/bin/env bash
# CI only: select the newest installed Xcode with the given major version (default 16, to
# match Emily's Mac). TestFlight uploads use 26 because App Store Connect requires the iOS 26
# SDK for uploads since April 2026.
set -euo pipefail
MAJOR="${1:-16}"
ls -d /Applications/Xcode*.app || true
# Prefer a release over a beta, as the Mac App Store gives a release. A beta or release
# candidate is not always named as one: on Nov 16 the image's Xcode_27.3.app was build
# 27C5020n. Apple's pre-release build numbers end in a lowercase letter, so skip those too.
is_release() {
  local build
  build="$(/usr/libexec/PlistBuddy -c "Print :ProductBuildVersion" "$1/Contents/version.plist" 2>/dev/null || true)"
  [ -n "$build" ] && ! [[ "$build" =~ [a-z]$ ]]
}
pick=""
for app in $(ls -d /Applications/Xcode_"$MAJOR"*.app 2>/dev/null | grep -vi beta | sort -V || true); do
  if is_release "$app"; then pick="$app"; fi
done
[ -n "$pick" ] || pick="$(ls -d /Applications/Xcode_"$MAJOR"*.app 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$pick" ]; then
  sudo xcode-select -s "$pick/Contents/Developer"
else
  echo "No Xcode $MAJOR found; using the default Xcode."
fi
xcodebuild -version
