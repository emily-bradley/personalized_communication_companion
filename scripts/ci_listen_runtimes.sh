#!/usr/bin/env bash
# CI only: for every installed iOS Simulator runtime, run the Listen UI test on an iPhone 16
# and record whether Selvo could start listening (its own log lines, never what was heard),
# then whether a fixed test sentence spoken by the system voice is recognized on the phone.
# Answers: which iOS Simulator keeps Listen working on device with this Xcode?
# Usage: scripts/ci_listen_runtimes.sh <report file>   (after xcodegen generate)
set -uo pipefail
REPORT="$1"
mkdir -p "$(dirname "$REPORT")" build
xcodebuild -version | head -1 > "$REPORT"
sw_vers | tr '\n' ' ' >> "$REPORT"; echo "" >> "$REPORT"
xcrun simctl list runtimes >> "$REPORT"
DEVTYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-16"
# A fixed test sentence in the Mac's voice, for the file probe (the Simulator voice can hang).
SENTENCE="$PWD/build/speech-probe.aiff"
say -o "$SENTENCE" "I would like a coffee please" || echo "say could not write the test sentence" >> "$REPORT"
export TEST_RUNNER_SPEECH_PROBE_FILE="$SENTENCE"
xcrun simctl list runtimes -j | python3 -c 'import json, sys
for r in json.load(sys.stdin)["runtimes"]:
    if r.get("isAvailable") and r.get("platform") == "iOS":
        print(r["identifier"], r["version"])' | while read -r runtime version; do
  echo "" >> "$REPORT"
  echo "== iOS $version" >> "$REPORT"
  udid="$(xcrun simctl create "Listen probe $version" "$DEVTYPE" "$runtime" 2>>"$REPORT")" || continue
  xcodebuild test -project Selvo.xcodeproj -scheme Selvo -destination "id=$udid" \
    -derivedDataPath build/DerivedData-probe CODE_SIGNING_ALLOWED=NO \
    -only-testing:SelvoUITests/DemoWalkUITests/testListenShowsListeningAndStops \
    > "build/probe-$version.log" 2>&1
  echo "test exit $?" >> "$REPORT"
  # Then the same sentence from a file, on the phone itself (Listen has asked for permission by now).
  xcodebuild test -project Selvo.xcodeproj -scheme Selvo -destination "id=$udid" \
    -derivedDataPath build/DerivedData-probe CODE_SIGNING_ALLOWED=NO \
    -only-testing:SelvoTests/SpeechFileProbeTests \
    > "build/probe-file-$version.log" 2>&1
  echo "file probe exit $?" >> "$REPORT"
  grep "SPEECHPROBE" "build/probe-file-$version.log" | sort -u >> "$REPORT" || true
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" >/dev/null 2>&1 || true
  xcrun simctl spawn "$udid" log show --last 2h --style compact \
    --predicate 'subsystem == "com.emilykenney.selvo"' 2>&1 | grep "listen" >> "$REPORT" || true
  xcrun simctl shutdown "$udid" 2>/dev/null || true
done
cat "$REPORT"
