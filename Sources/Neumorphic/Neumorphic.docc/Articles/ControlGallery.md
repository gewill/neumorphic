# Control gallery

Browse every control family, style, and surface before choosing an API.

## Overview

These previews use the library's actual views mounted on macOS 26.6.2, with light appearance,
English labels, and regular control size. They illustrate appearance; native editors and layout
can differ on iOS. See <doc:ControlSizing> and <doc:ButtonSizing> for side-by-side platform examples,
size policies, and the distinction between visible surfaces, layout bounds, and hit targets.

Start with <doc:GettingStarted> for installation and composition, and <doc:Accessibility> for
interaction and accessibility guidance. The Example app's **Sizing** tab lets you compare native
and neumorphic controls interactively on both platforms.

## Buttons and toggles

### Buttons

![A capsule Continue button, a circular copy button, and an accent Save button.](gallery-buttons.png)

Use ``Neumorphic/SoftDynamicButtonStyle`` for content that grows naturally and
``Neumorphic/FixedSizeSoftDynamicButtonStyle`` for an explicit label frame. Apply them with
`softButtonStyle` and `fixedSizeSoftButtonStyle`; `neumorphicThemedButtonStyle` adds environment theme
and ``Neumorphic/NeumorphicButtonRole`` support. The preview shows these current styles.
``Neumorphic/SoftButtonStyle`` is deprecated; use the current dynamic styles pictured here.
See <doc:ButtonSizing> before choosing padding or an explicit minimum.

### Pressed effects

![Three buttons demonstrating the none, flat, and hard pressed effects.](pressed-effects.gif)

``Neumorphic/SoftButtonPressedEffect`` selects `.none`, `.flat`, or `.hard` shadow treatment.
This animation was recorded from the iOS Example app in Simulator with simulated touch input.

### Switch and shape toggles

![An enabled switch and a selected circular play toggle.](gallery-toggles.png)

``Neumorphic/NeumorphicSwitchToggleStyle`` provides the switch via `.toggleStyle(.neumorphicSwitch)`
or `switchToggleStyle`; use `neumorphicThemedSwitchStyle` to inherit the environment theme. ``Neumorphic/SoftDynamicToggleStyle`` provides shape toggles through
`softToggleStyle` or `neumorphicThemedToggleStyle`. ``Neumorphic/SoftSwitchToggleStyle`` is the legacy
switch style; the preview uses the current switch and themed shape styles.

## Input controls

### Slider

![A slider with its thumb at approximately 65 percent.](gallery-slider.png)

``Neumorphic/NeumorphicSlider`` binds a numeric value, with a range and optional step.

### Text field

![An inset text field containing Hello, Neumorphic.](gallery-text-field.png)

``Neumorphic/NeumorphicTextField`` wraps native text editing in a themed inset surface.

### Secure field

![An empty inset secure field showing the Password placeholder.](gallery-secure-field.png)

Use `NeumorphicTextField("Password", text: $password, secure: true)` for native secure editing.
This is an option of ``Neumorphic/NeumorphicTextField``, rather than a separate control type.

### Stepper

![A Quantity stepper showing 2, with minus and plus buttons.](gallery-stepper.png)

``Neumorphic/NeumorphicStepper`` changes an integer value within a range.

### Date picker

![A Date control with a native macOS date editor.](gallery-date-picker.png)

``Neumorphic/NeumorphicDatePicker`` keeps the native date editor inside a neumorphic surface.
Its editor presentation follows the platform.

## Selection controls

### Segmented picker

![A two-option picker with Light selected and Dark unselected.](gallery-picker.png)

``Neumorphic/NeumorphicPicker`` displays a set of choices with a shared selection binding.

### Menu

![A compact menu displaying the selected Light option and a disclosure indicator.](gallery-menu.png)

``Neumorphic/NeumorphicMenu`` presents options in a native menu. Requires iOS 14 or macOS 11 and later.

### Checkbox

![A checked Remember me checkbox.](gallery-checkbox.png)

``Neumorphic/NeumorphicCheckbox`` represents an independent Boolean choice.

### Radio buttons

![Light and Dark radio options, with Light selected.](gallery-radio.png)

``Neumorphic/NeumorphicRadio`` represents one value in a group sharing a selection binding.

## Progress

### Linear progress

![A linear progress bar labeled Downloading, 65 percent.](gallery-progress.png)

``Neumorphic/NeumorphicProgressView`` displays progress along an inset track.

### Circular progress

![A circular progress indicator beside the text 65 percent complete.](gallery-circular-progress.png)

``Neumorphic/NeumorphicCircularProgressView`` displays progress around a ring.

## Containers and navigation

### Disclosure group

![An expanded Details group revealing Additional information.](gallery-disclosure.png)

``Neumorphic/NeumorphicDisclosureGroup`` reveals content controlled by an expansion binding.

### Link

![A Visit website link on a raised surface.](gallery-link.png)

``Neumorphic/NeumorphicLink`` styles a system link. Requires iOS 14 or macOS 11 and later.

### Card

![A raised card titled Your workspace with descriptive text.](gallery-card.png)

Apply `neumorphicCard(_:padding:preset:)` to group arbitrary content on a raised surface.
A card is a view modifier, so the content keeps its own layout and semantics.

## Surfaces and feedback

### Outer and inner shadows

![Two circles, one raised by an outer shadow and one inset by an inner shadow.](gallery-shadows.png)

Use `softOuterShadow` for raised surfaces and `softInnerShadow` for inset surfaces.
``Neumorphic/NeumorphicShadowPreset`` supplies shared shadow geometry.

### Focus and hover

![Focus and Hover buttons with their corresponding visual indicators enabled.](gallery-focus.png)

Apply `neumorphicFocusRing(_:isFocused:color:lineWidth:)` for a
``Neumorphic/NeumorphicFocusRing`` indicator, and `neumorphicHover(_:isHovered:color:lineWidth:)`
for ``Neumorphic/NeumorphicHoverEffect``. The hover modifier adds
pointer feedback on macOS and has no effect on iOS. These previews explicitly enable the state
bindings to show appearance; they do not demonstrate keyboard navigation or pointer interaction.

## Related building blocks

- ``Neumorphic/NeumorphicTheme`` supplies environment colors and contrast choices.
- ``Neumorphic/NeumorphicButtonRole`` selects semantic button colors.
- ``Neumorphic/NeumorphicShadowPreset`` supplies reusable shadow settings.
- ``Neumorphic/NeumorphicKit`` and `Color.Neumorphic` provide the default color scheme.

Apply `neumorphicTheme(_:)` to an ancestor so its controls inherit the theme. See
<doc:GettingStarted> for a complete composition and <doc:Accessibility> for accessible alternatives.
