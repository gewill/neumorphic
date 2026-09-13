# Button sizing

Use platform defaults or choose explicit layout and hit bounds.

## Compatibility and platform policy

The `softButtonStyle` and `fixedSizeSoftButtonStyle` overloads without `minimumSize` use a
28-by-28-point minimum on macOS and a 44-by-44-point minimum on iOS. The style initializers and themed
button modifiers use the same defaults. The complete layout rectangle is hittable, including
transparent margins, for both default and explicit sizing.

**Breaking layout change for the next major release:** Earlier versions imposed a 44-by-44-point
minimum on macOS too. Existing signatures and padding behavior are unchanged, but compact Mac
buttons now occupy less space. Pass `minimumSize: CGSize(width: 44, height: 44)` to retain the previous
minimum. A minimum does not force larger labels or surfaces to shrink.

The overloads with a required `minimumSize: CGSize` let the caller choose a minimum for the complete
layout rectangle. That entire rectangle is explicitly hittable, including transparent margins and
the corners outside a circular surface. Use `.zero` to remove the minimum. Each negative or nonfinite
minimum component is treated as zero. This policy also applies to the new initializers on
``Neumorphic/SoftDynamicButtonStyle`` and ``Neumorphic/FixedSizeSoftDynamicButtonStyle``.

Apple's [Accessibility guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
list a default control size of 28-by-28 points for macOS (minimum 20-by-20), and 44-by-44 points for
iOS/iPadOS (minimum 28-by-28). These are distinct from a requirement that every visible surface be
44 points. The default minimum follows the platform’s default control size. Override it when your
input methods or users need a different target.

```swift
Button {} label: {
    Image(systemName: "doc.on.doc")
}
.fixedSizeSoftButtonStyle(
    Circle(), size: CGSize(width: 28, height: 28)
)
.accessibilityLabel("Copy")
```

On macOS this produces a 28-point layout; on iOS it reserves a 44-point target.
To keep the same 28-point surface with a larger target on macOS, pass `minimumSize: CGSize(width: 44, height: 44)`.

## Label, surface, layout, and shadows

- **Label bounds:** The fixed style's `size` sets the label frame before padding. Negative dimensions
  become zero. The convenience modifier uses zero padding; the style initializer defaults to 16
  points on each edge. A fixed label frame can truncate or overflow large content.
- **Surface bounds:** Padding is added outside the label frame, then the surface is drawn behind it.
  With `size: CGSize(width: 30, height: 30)` and `padding: 5`, the nominal surface is 40-by-40 points.
  The non-fixed style uses the label's layout size plus padding, so it can grow with text.
- **Complete layout and hit bounds:** The minimum frame is applied after the surface. Each dimension
  is at least `minimumSize` and can be larger to accommodate the padded label. Extra space around the
  surface is transparent but hittable with all overloads. A minimum does not force the surface
  itself to grow. Parent proposals still participate in normal SwiftUI layout.
- **Shadows:** Outer shadows may draw outside the surface and complete layout rectangle. They reserve
  no layout space. These styles do not inset or clip shadows to fit a complete visual envelope.

The label's pressed scale does not resize the layout or the rectangular hit region. The
surface remains stationary; pressed effects change its shadow treatment. Reduce Motion suppresses
the label scale, and disabled buttons retain their layout while using standard `Button` semantics.

For text that should grow naturally, use the non-fixed overload:

```swift
Button("Continue") { }
    .softButtonStyle(
        Capsule(), padding: 6
    )
```

Account for padding already applied by the caller: it contributes to the label's size before the
style's own padding. Adding a minimum label height and then style padding can make the complete
control larger than the chosen minimum.
