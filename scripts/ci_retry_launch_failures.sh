#!/usr/bin/env bash
# CI only. When every failure in an xcodebuild test log is the Simulator failing to stop or
# start Selvo before a UI test body runs ("Failed to terminate com.emilykenney.selvo", seen
# Oct 22 on the Xcode 27 runner on a docs only commit), run just those UI tests once more
# after a fresh boot. Any other failure is left as it is and the step stays red.
# Usage: ci_retry_launch_failures.sh LOG UDID
# Exits 0 when the rerun passes, 1 when it fails, 2 when there was nothing to rerun.
set -uo pipefail
log="$1"
udid="$2"

errors="$(grep -E "error: -\[SelvoUITests\." "$log" || true)"
[ -n "$errors" ] || exit 2
# Every failure must be a launch failure, and no unit test may have failed.
if grep -E "error: -\[" "$log" | grep -vqE "Failed to terminate com\.emilykenney\.selvo|Failed to launch com\.emilykenney\.selvo|Timed out while launching application"; then
  exit 2
fi

args=()
while read -r cls test; do
  args+=("-only-testing:SelvoUITests/$cls/$test")
done < <(printf '%s\n' "$errors" | sed -E 's/.*-\[SelvoUITests\.([A-Za-z0-9_]+) ([A-Za-z0-9_]+)\].*/\1 \2/' | sort -u)

echo "Only launch failures in: ${args[*]}. Running those UI tests once more after a fresh boot."
xcrun simctl shutdown "$udid" 2>/dev/null
xcrun simctl boot "$udid" 2>/dev/null
xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1
xcodebuild test-without-building \
  -project Selvo.xcodeproj \
  -scheme Selvo \
  -destination "id=$udid" \
  -derivedDataPath build/DerivedData \
  "${args[@]}" \
  CODE_SIGNING_ALLOWED=NO \
  > build/xcodebuild-retry.log 2>&1
status=$?
grep -E "error|failed|Test Suite|Executed|\*\* " build/xcodebuild-retry.log | tail -60
cat build/xcodebuild-retry.log >> "$log"
[ "$status" -eq 0 ] && exit 0 || exit 1
