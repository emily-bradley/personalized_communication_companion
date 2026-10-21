#!/usr/bin/env python3
"""Print the UDID of an available iPhone 16 Simulator, creating one if needed.

Picks the newest iOS runtime that has an "iPhone 16". If none exists, creates one on the
newest available iOS runtime. With a second argument (an iOS major version such as 18), only
runtimes of that version are used. Used by scripts/demo.sh and CI.
"""
import json
import subprocess
import sys

DEVICE_NAME = sys.argv[1] if len(sys.argv) > 1 else "iPhone 16"
IOS_MAJOR = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] else None


def simctl(*args):
    return subprocess.run(["xcrun", "simctl", *args], check=True, capture_output=True, text=True).stdout


def runtime_version(identifier):
    # com.apple.CoreSimulator.SimRuntime.iOS-18-2 -> (18, 2)
    tail = identifier.rsplit("iOS-", 1)[-1]
    return tuple(int(p) for p in tail.split("-") if p.isdigit())


def wanted(version):
    return IOS_MAJOR is None or (bool(version) and version[0] == IOS_MAJOR)


def sdk_major():
    try:
        out = subprocess.run(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"],
                             check=True, capture_output=True, text=True).stdout.strip()
        return int(out.split(".")[0])
    except Exception:
        return None


def main():
    # Prefer runtimes no newer than the selected Xcode's iOS SDK, so the Simulator matches it.
    sdk = sdk_major()

    def rank(version):
        fits = sdk is None or (version and version[0] <= sdk)
        return (1 if fits else 0, version)

    devices = json.loads(simctl("list", "devices", "available", "-j"))["devices"]
    candidates = []
    for runtime, items in devices.items():
        if ".iOS-" not in runtime or not wanted(runtime_version(runtime)):
            continue
        for d in items:
            if d.get("name") == DEVICE_NAME and d.get("isAvailable", True):
                candidates.append((runtime_version(runtime), d["udid"]))
    if candidates:
        candidates.sort(key=lambda c: rank(c[0]))
        print(candidates[-1][1])
        return

    runtimes = json.loads(simctl("list", "runtimes", "available", "-j"))["runtimes"]
    ios = [r for r in runtimes if r.get("platform") == "iOS" or ".iOS-" in r.get("identifier", "")]
    ios = [r for r in ios if wanted(runtime_version(r["identifier"]))]
    if not ios and IOS_MAJOR:
        sys.exit(f"The iOS {IOS_MAJOR} Simulator is not installed. Open Xcode, then Settings, then "
                 f"Components, click the plus button, and add iOS {IOS_MAJOR}.")
    if not ios:
        sys.exit("No iOS Simulator runtime is installed. Open Xcode, then Settings, then Components "
                 "(Platforms in Xcode 16), and add iOS.")
    ios.sort(key=lambda r: rank(runtime_version(r["identifier"])))
    newest = ios[-1]["identifier"]
    device_types = json.loads(simctl("list", "devicetypes", "-j"))["devicetypes"]
    match = [t for t in device_types if t["name"] == DEVICE_NAME]
    if not match:
        sys.exit(f"This Xcode does not know a device called {DEVICE_NAME}.")
    udid = simctl("create", DEVICE_NAME, match[0]["identifier"], newest).strip()
    print(udid)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        sys.exit(f"The Simulator tools stopped with an error:\n{(error.stderr or '').strip()}\n"
                 "Quit Simulator and Xcode, then run this again. If it happens again, restart the Mac.")
