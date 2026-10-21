#!/usr/bin/env bash
# CI only: delete the preinstalled "iPhone 16" Simulators, so demo.sh has to create its own,
# as on a Mac with a fresh Xcode 26 or 27 (they come with newer iPhones only).
set -euo pipefail
xcrun simctl list devices -j \
  | python3 -c 'import json, sys
for items in json.load(sys.stdin)["devices"].values():
    for d in items:
        if d["name"] == "iPhone 16":
            print(d["udid"])' \
  | while read -r udid; do
      echo "Deleting iPhone 16 Simulator $udid"
      xcrun simctl delete "$udid"
    done
