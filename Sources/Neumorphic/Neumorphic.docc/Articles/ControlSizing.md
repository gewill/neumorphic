# Control sizing

Adapt neumorphic controls to the platform and the surrounding control size.

## Platform defaults

Text fields, sliders, switches, steppers, segmented pickers, menus, checkboxes, radio buttons, and
disclosure headers share a minimum interaction dimension. The minimum is applied after content and
padding, so a 44-point label no longer receives another 20 points of style padding.

| Control size | macOS minimum | iOS minimum |
| --- | --- | --- |
| Mini | 20 pt | 44 pt |
| Small | 24 pt | 44 pt |
| Regular | 28 pt | 44 pt |
| Large | 32 pt | 52 pt |

These are library layout and interaction defaults, not claims that every native control has these
visible dimensions. Larger or multiline labels can grow beyond the minimum. The size, padding,
corner radius, and spacing of custom controls follow the `controlSize` environment on macOS and
iOS 15 or later. iOS 13–14 uses regular metrics. Extra-large and future unknown sizes currently use
the large metrics to retain compatibility with Swift 5.7.

```swift
VStack {
    NeumorphicTextField("Name", text: $name)
    NeumorphicSlider(value: $volume)
    Toggle("Enabled", isOn: $isEnabled)
        .switchToggleStyle()
}
.controlSize(.small)
```

`controlSize(_:)` requires iOS 15 or later; guard it when supporting older iOS releases. Large size
requires macOS 11 or later. Dynamic button styles retain their separate explicit `padding` and
`minimumSize` contract; see <doc:ButtonSizing>.

## Visible surfaces and interaction regions

The entire rectangular target of switches, checkboxes, radio buttons, and shape-based toggles is
hittable, including transparent corners and margins. The target remains stable when the value or
pressed appearance changes. Disabled controls do not activate.

Text fields retain native `TextField` and `SecureField` editing. Tapping the surface around the text
focuses the field without placing an intercepting overlay over the editor. On iOS 15/macOS 12 or
later this uses SwiftUI focus state; earlier systems use a contained native hosting view to forward
only gutter interactions to the field. Text selection and keyboard navigation remain native.

Sliders keep a separate track, thumb, and full-height interaction rectangle. The thumb diameter
changes with the control size, and drag mapping uses that same diameter so both endpoints remain
reachable. Disabled sliders ignore pointer and keyboard adjustments.

Date pickers retain the native control's size and behavior, with additional platform-specific
padding. They do not force the date editor into the table's minimum dimensions.

Outer shadows can extend beyond layout bounds and do not reserve additional layout space.

## Switch geometry and explicit heights

With the label hidden, the default macOS switch surfaces are 36×16, 44×20, 54×24, and 64×28 points
for mini, small, regular, and large. The complete layout also reserves the corresponding minimum
interaction height above. These surface dimensions follow the native switch comparison; the
neumorphic shadows and thumb remain custom visuals.

Omit `height` to use platform and control-size defaults. An explicit height keeps the original
75:45 width-to-height ratio and 30:45 thumb-to-height ratio; invalid values normalize to 1 point.
The minimum interaction dimensions still apply around a smaller surface.

```swift
Toggle("Enabled", isOn: $isEnabled)
    .switchToggleStyle(labelsHidden: true)

Toggle("Enabled", isOn: $isEnabled)
    .switchToggleStyle(labelsHidden: true, height: 20)
```

The same automatic sizing applies to `NeumorphicSwitchToggleStyle`, `.neumorphicSwitch`,
`softSwitchToggleStyle`, and `neumorphicThemedSwitchStyle`. Explicit-height initializers and modifiers
remain available.

## Migration

This is a layout behavior change for the next major release. Compact Mac controls become smaller,
compound controls no longer double-count padding, and the original switch style uses the same
platform sizing as the current switch style. Text fields and several controls now reserve less
horizontal padding. Recheck adjacent controls and custom width/height constraints when upgrading.
The existing public entry points and minimum OS versions remain available.

## Platform examples

The Example app's **Sizing** tab compares native SwiftUI and neumorphic controls under the same
platform conditions. These light-appearance captures show macOS and iOS separately. Dashed outlines
show layout bounds; they do not measure the actual hit region. Use the page's controls to explore
sizes, longer labels, and disabled states.

### macOS

![macOS control sizing comparison](control-sizing-macos.png)

### iOS

![iOS control sizing comparison](control-sizing-ios.png)

For an overview of every control and style, see <doc:ControlGallery>.
