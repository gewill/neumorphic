#!/usr/bin/env python3
"""Capture the Example Sizing tab using actual macOS/iOS controls, without source edits."""
import argparse
import pathlib
import subprocess
import tempfile
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUNDLE = "neumorphic.example"


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("platform", choices=["macos", "ios"])
    parser.add_argument("--output", required=True, type=pathlib.Path)
    parser.add_argument("--udid", help="Required for iOS; the simulator must already be booted")
    parser.add_argument("--section", choices=["Buttons", "Controls"], default="Controls")
    parser.add_argument("--control", default="Stepper", choices=["TextField", "SecureField", "Slider", "Switch", "Stepper", "Picker", "Menu", "Checkbox", "Radio", "DatePicker", "Disclosure"])
    parser.add_argument("--size", choices=["Mini", "Small", "Regular", "Large"], default="Regular")
    parser.add_argument("--derived-data", type=pathlib.Path)
    parser.add_argument("--skip-build", action="store_true", help="Use an existing Debug build at --derived-data")
    args = parser.parse_args()
    if args.platform == "ios" and not args.udid:
        parser.error("--udid is required for iOS")
    if args.skip_build and not args.derived_data:
        parser.error("--skip-build requires --derived-data")
    args.output = args.output.resolve()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="neumorphic-sizing-") as temporary:
        derived = (args.derived_data or pathlib.Path(temporary) / "build").resolve()
        if not args.skip_build:
            destination = "platform=macOS" if args.platform == "macos" else f"platform=iOS Simulator,id={args.udid}"
            run("xcodebuild", "-workspace", str(ROOT / "neumorphic.xcworkspace"), "-scheme", "neumorphic-example", "-configuration", "Debug", "-destination", destination, "-derivedDataPath", str(derived), "CODE_SIGNING_ALLOWED=NO", "CODE_SIGNING_REQUIRED=NO", "build", cwd=ROOT)
        product = "Debug" if args.platform == "macos" else "Debug-iphonesimulator"
        app = derived / "Build/Products" / product / "neumorphic-example.app"
        if not app.is_dir():
            parser.error(f"Build product does not exist: {app}")
        options = ["--sizing-section", args.section, "--sizing-control", args.control, "--sizing-size", args.size, "--sizing-capture", "yes"]
        if args.platform == "ios":
            run("xcrun", "simctl", "install", args.udid, str(app))
            subprocess.run(["xcrun", "simctl", "terminate", args.udid, BUNDLE], capture_output=True)
            run("xcrun", "simctl", "launch", args.udid, BUNDLE, *options)
            time.sleep(3)
            run("xcrun", "simctl", "io", args.udid, "screenshot", str(args.output))
        else:
            with (pathlib.Path(temporary) / "app.log").open("w") as log:
                process = subprocess.Popen([str(app / "Contents/MacOS/neumorphic-example"), *options], stdout=log, stderr=log)
                try:
                    time.sleep(3)
                    result = run("swift", str(ROOT / "Scripts/readme-shots/helpers/window-id.swift"), str(process.pid), capture_output=True)
                    window = result.stdout.strip()
                    if not window.isdigit():
                        raise RuntimeError("No normal application window found")
                    run("screencapture", "-x", "-o", "-l", window, str(args.output))
                finally:
                    process.terminate()
                    process.wait(timeout=10)
    print(f"Captured {args.output}. Inspect the image before publishing; layout bounds do not prove hit testing.")


if __name__ == "__main__":
    main()
