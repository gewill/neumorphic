# Documentation illustrations

The images in `Sources/Neumorphic/Neumorphic.docc/Resources/` come from the README snippets, mounted gallery controls, or the running Example app. This directory
holds the renderer for standalone illustrations, the capture script for Sizing pages, and the
procedure for the hero, search bar and pressed-effects animation.

README and DocC share these resources; update the canonical files instead of keeping separate copies.

## Complete control gallery

```sh
swift run --package-path Scripts/readme-shots readme-shots --gallery
# Optional output directory for review before replacing published images:
swift run --package-path Scripts/readme-shots readme-shots --gallery /tmp/neumorphic-gallery
```

This mode renders 18 `gallery-*@2x.png` images for the Control Gallery article. It mounts each library
view in an AppKit window and captures the composited window with `screencapture`, including native text and date editors.
Run on macOS with a graphical session and Screen Recording permission for the terminal. Previews use light appearance, en_US, regular control size,
a fixed UTC time zone, a 360-point content width, and 32 points of surrounding padding for shadows.
A 2x display is required: the tool checks `backingScaleFactor` and stops on other displays, so the
848-pixel-wide images match their `@2x` filenames. The focus and hover previews explicitly enable their visual state bindings.

These are macOS appearance illustrations, not iOS sizing or interaction evidence. Update the
article’s recorded macOS version when regenerating them on a different system. Inspect all output
for clipping, missing editors, and alignment before replacing the resources. Use `capture-sizing.py`
below for the separate macOS/iOS comparisons. Run the DocC validation in `CONTRIBUTING.md` after
changing images or references.

## Standalone README illustrations

```sh
swift run --package-path Scripts/readme-shots readme-shots
```

Run it from the repository root; it writes into `Sources/Neumorphic/Neumorphic.docc/Resources/` (pass a directory to override). It
produces `outer-shadow`, `inner-shadow`, `shadows-side-by-side`, `bar-chart`, `soft-button`,
`custom-button`, `switch-toggle`, and `shape-toggle` at scale 3.

Afterwards, cap the wide ones at 900 pixels so they render at a sensible size on GitHub:

```sh
sips -Z 900 Sources/Neumorphic/Neumorphic.docc/Resources/{shadows-side-by-side,outer-shadow,inner-shadow,switch-toggle}.png
```

## Captured from the simulator

`hero.png`, `search-bar.png`, and `pressed-effects.gif` cannot come from `ImageRenderer`:

- Both stills contain a `TextField`, which `ImageRenderer` draws as a yellow "unsupported" placeholder.
- The GIF needs real touch input, which no offscreen renderer can supply.

Add this view to `neumorphic-examples/Shared` temporarily, point `ExampleApp` at it, and **revert both
changes afterwards** — it is a capture harness, not example code. The fixed block heights are what make
the crops below deterministic.

```swift
struct ReadmeShotsView: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.Neumorphic.main.frame(height: 80)   // clears the status bar
            ShotSearchBar().frame(width: 402, height: 110)
            ShotHero().frame(width: 402, height: 420)
            ShotPressedEffects().frame(width: 402, height: 120)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.Neumorphic.main.ignoresSafeArea())
        .ignoresSafeArea()
    }
}
```

`ShotSearchBar` is the README's search-bar snippet, `ShotHero` is a `neumorphicCard` holding a slider,
text field, progress view, both button roles and a switch, and `ShotPressedEffects` is a row of three
capsule buttons using `.none`, `.flat`, and `.hard`.

Build for an iPhone 17 Pro simulator (402×874 points, scale 3), then capture at native resolution:

```sh
xcrun simctl io booted screenshot full.png
ffmpeg -i full.png -vf "crop=1206:330:0:240"  Sources/Neumorphic/Neumorphic.docc/Resources/search-bar.png
ffmpeg -i full.png -vf "crop=1206:1260:0:570" Sources/Neumorphic/Neumorphic.docc/Resources/hero.png
sips -Z 900 Sources/Neumorphic/Neumorphic.docc/Resources/{hero,search-bar}.png
```

The crop offsets are the block heights above multiplied by the scale factor: the search bar starts at
80 points, the card at 190, the button row at 610.

## The pressed-effects GIF

Start a recording, long-press each of the three buttons in turn (roughly 800 ms each, at y = 670
points, x = 125 / 203 / 279), then stop the recording:

```sh
xcrun simctl io booted recordVideo --codec h264 pressed.mov
```

Find when each press lands — the recording is variable frame rate, and the idle gaps between presses
are long:

```sh
ffmpeg -i pressed.mov -vf "crop=1206:360:0:1830,showinfo" -f null - 2>&1 | grep pts_time
```

Then trim the three windows, concatenate them, and build the GIF. Check the result frame by frame:
`.flat` should lose its shadow, `.hard` should look pressed in, and `.none` should not change at all.

```sh
ffmpeg -i pressed.mov -filter_complex \
  "[0:v]crop=1206:360:0:1830,fps=15,scale=560:-1:flags=lanczos[v];\
   [v]split=3[a][b][c];\
   [a]trim=16.30:16.90,setpts=PTS-STARTPTS[a1];\
   [b]trim=22.60:23.70,setpts=PTS-STARTPTS[b1];\
   [c]trim=28.75:29.60,setpts=PTS-STARTPTS[c1];\
   [a1][b1][c1]concat=n=3:v=1:a=0,split[s0][s1];\
   [s0]palettegen=max_colors=64[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 Sources/Neumorphic/Neumorphic.docc/Resources/pressed-effects.gif
```

The trim timestamps are from one particular recording; read yours out of the `showinfo` pass above.

## Sizing page: real macOS and iOS controls

`capture-sizing.py` builds and opens the Example app's **Sizing** tab. It captures a real window or
simulator screen, including native editors; it does not recreate controls with `ImageRenderer` or
compose offscreen rows. The dashed outline is attached to the same SwiftUI layout as each control,
and ignores hit testing. It shows layout bounds, not proof of the actual interaction region.

Run from the repository root, with Xcode and Python 3 installed:

```sh
python3 Scripts/readme-shots/capture-sizing.py macos \
  --section Controls --output /tmp/control-sizing-macos.png
python3 Scripts/readme-shots/capture-sizing.py macos \
  --section Buttons --output /tmp/button-sizing-macos.png

# Choose a booted simulator explicitly; the script does not boot or reset devices.
xcrun simctl list devices booted
python3 Scripts/readme-shots/capture-sizing.py ios --udid YOUR_SIMULATOR_UDID \
  --section Controls --output /tmp/control-sizing-ios.png
python3 Scripts/readme-shots/capture-sizing.py ios --udid YOUR_SIMULATOR_UDID \
  --section Buttons --output /tmp/button-sizing-ios.png
```

Capture options:

- `--control Stepper` selects any of the 11 controls; Stepper is the default.
- `--size Mini|Small|Regular|Large` selects the Controls environment (default Regular).
- `--derived-data PATH` retains a build; add `--skip-build` to reuse it after confirming it matches
  the source. Both sections use the same app build.
- `--output PATH` is required so evidence never silently overwrites README assets.

The Debug-only launch options open the real page with en_US, light appearance, default text size,
layout outlines enabled and a fixed sample date. The iOS status bar and native appearance still
come from the chosen runtime. Keep the same device/window dimensions for before/after evidence.
The macOS command needs Screen Recording permission for the terminal and closes only the process
it launched; the iOS command installs the example app, relaunches it and leaves it open for inspection.

Inspect each PNG at full resolution: labels must be visible, outlines must follow the controls,
Stepper must be vertically centered, and shadows need enough space. Publish comparison evidence
with `gh issue comment --attach` or `gh pr comment --attach`. Only the selected final README
illustrations belong in `Sources/Neumorphic/Neumorphic.docc/Resources/`; keep audit screenshots, videos and logs outside the repository.
Store the approved macOS captures as `{button,control}-sizing-macos@2x.png` and iOS captures as
`{button,control}-sizing-ios@3x.png` in that directory. Verify the source scale before using those
suffixes: current macOS captures are 1978×1354 pixels for a 989×677-point window; current iPhone
captures are 1206×2622 pixels for a 402×874-point screen. Keep DocC image references scale-free
(e.g. `button-sizing-ios.png`); README links use the actual filename. Do not infer a capture scale
for older resized illustrations.

For interaction videos, use the running Sizing page and record real size changes, outline toggles
and control input. A still image does not verify focus, hit targets, VoiceOver or keyboard behavior.
