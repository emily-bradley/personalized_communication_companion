#!/usr/bin/env python3
"""Print the UDID of an available iPhone 16 Simulator, creating one if needed.

Picks an iOS runtime, then an "iPhone 16" on it (creating one if there is none). Runtimes no
newer than the selected Xcode's iOS SDK come first. Among those, runtimes where Listen can hear
come first: iOS 18, and iOS 26.0 to 26.2. In the iOS 26.4 and later Simulators (27 too) the
on-device speech recognizer does not start (CI probes, Oct 21), so when only those are
installed it prints a tip on stderr. With a second argument (an iOS version such as 18 or
26.2), only runtimes of that version are used. Used by scripts/demo.sh and CI.
"""
import json
import subprocess
import sys

DEVICE_NAME = sys.argv[1] if len(sys.argv) > 1 else "iPhone 16"
WANTED = tuple(int(p) for p in sys.argv[2].split(".")) if len(sys.argv) > 2 and sys.argv[2] else None
LISTEN_RUNTIME = "26.2"


def simctl(*args):
    return subprocess.run(["xcrun", "simctl", *args], check=True, capture_output=True, text=True).stdout


def runtime_version(identifier):
    # com.apple.CoreSimulator.SimRuntime.iOS-18-2 -> (18, 2)
    tail = identifier.rsplit("iOS-", 1)[-1]
    return tuple(int(p) for p in tail.split("-") if p.isdigit())


def wanted(version):
    return WANTED is None or (bool(version) and version[:len(WANTED)] == WANTED)


def listen_works(version):
    return version[:1] == (18,) or (26, 0) <= version[:2] <= (26, 2)


def sdk_major():
    try:
        out = subprocess.run(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"],
                             check=True, capture_output=True, text=True).stdout.strip()
        return int(out.split(".")[0])
    except Exception:
        return None


def label(version):
    # (27, 0) -> "27", (26, 2) -> "26.2"
    parts = list(version)
    while len(parts) > 1 and parts[-1] == 0:
        parts.pop()
    return ".".join(str(p) for p in parts)


def main():
    sdk = sdk_major()

    def rank(version):
        fits = sdk is None or (version and version[0] <= sdk)
        return (1 if fits else 0, 1 if listen_works(version) else 0, version)

    runtimes = json.loads(simctl("list", "runtimes", "available", "-j"))["runtimes"]
    ios = [r for r in runtimes if r.get("platform") == "iOS" or ".iOS-" in r.get("identifier", "")]
    ios = [r for r in ios if wanted(runtime_version(r["identifier"]))]
    if not ios and WANTED:
        sys.exit(f"The iOS {label(WANTED)} Simulator is not installed. Open Xcode, then Settings, then "
                 f"Components, click the plus button, and add iOS {label(WANTED)}.")
    if not ios:
        sys.exit("No iOS Simulator runtime is installed. Open Xcode, then Settings, then Components "
                 "(Platforms in Xcode 16), and add iOS.")
    ios.sort(key=lambda r: rank(runtime_version(r["identifier"])))
    chosen = ios[-1]["identifier"]
    version = runtime_version(chosen)
    newest = max(runtime_version(r["identifier"]) for r in ios)

    if listen_works(version) and version != newest and not WANTED:
        print(f"Using the iOS {label(version)} Simulator, where Listen works. "
              f"To use iOS {label(newest)} instead: ./scripts/demo.sh --ios {label(newest)}", file=sys.stderr)
    elif not listen_works(version):
        print(f"Tip: Listen cannot hear in the iOS {label(version)} Simulator. To show Listen, add the "
              f"iOS {LISTEN_RUNTIME} Simulator (see docs/DEMO.md, step 5).", file=sys.stderr)

    devices = json.loads(simctl("list", "devices", "available", "-j"))["devices"].get(chosen, [])
    for d in devices:
        if d.get("name") == DEVICE_NAME and d.get("isAvailable", True):
            print(d["udid"])
            return
    device_types = json.loads(simctl("list", "devicetypes", "-j"))["devicetypes"]
    match = [t for t in device_types if t["name"] == DEVICE_NAME]
    if not match:
        sys.exit(f"This Xcode does not know a device called {DEVICE_NAME}.")
    print(simctl("create", DEVICE_NAME, match[0]["identifier"], chosen).strip())


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        sys.exit(f"The Simulator tools stopped with an error:\n{(error.stderr or '').strip()}\n"
                 "Quit Simulator and Xcode, then run this again. If it happens again, restart the Mac.")
