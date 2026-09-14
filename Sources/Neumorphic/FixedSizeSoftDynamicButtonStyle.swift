import SwiftUI

/// A dynamic soft button style with an explicit label frame and additional surface padding.
public struct FixedSizeSoftDynamicButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    var mainColor: Color
    var textColor: Color
    var darkShadowColor: Color
    var lightShadowColor: Color
    var pressedEffect: SoftButtonPressedEffect
    var padding: CGFloat
    var minimumSize: CGSize?
    var size: CGSize

    /// Creates a fixed-size soft button style with a platform-specific minimum layout.
    ///
    /// Reserves at least 28-by-28 points on macOS and 44-by-44 points on iOS.
    /// The complete layout rectangle is hittable, including transparent margins.
    ///
    /// - Parameters:
    ///   - shape: The shape of the surface.
    ///   - mainColor: The surface color.
    ///   - textColor: The label and symbol color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - pressedEffect: The visual treatment applied while the control is pressed.
    ///   - padding: The inset between the label and the surface edge.
    ///   - size: The label frame before padding. Negative width or height is normalized to zero.
    public init(
        _ shape: S, mainColor: Color, textColor: Color, darkShadowColor: Color, lightShadowColor: Color,
        pressedEffect: SoftButtonPressedEffect, padding: CGFloat = 16, size: CGSize
    ) {
        self.shape = shape
        self.mainColor = mainColor
        self.textColor = textColor
        self.darkShadowColor = darkShadowColor
        self.lightShadowColor = lightShadowColor
        self.pressedEffect = pressedEffect
        self.padding = padding
        self.size = CGSize(width: max(size.width, 0), height: max(size.height, 0))
    }

    /// Creates a fixed-size soft button style with explicit layout and hit bounds.
    ///
    /// The complete layout rectangle is hittable, including transparent margins, and stays
    /// unchanged during presses. Shadows may draw outside it. See <doc:ButtonSizing>.
    ///
    /// - Parameters:
    ///   - shape: The shape of the surface.
    ///   - mainColor: The surface color.
    ///   - textColor: The label and symbol color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - pressedEffect: The visual treatment applied while the control is pressed.
    ///   - padding: The inset between the label and the surface edge.
    ///   - size: The label frame before padding. Negative width or height is normalized to zero.
    ///   - minimumSize: The minimum complete layout and rectangular hit size, in points.
    ///     Use `.zero` for no minimum. Negative or nonfinite components become zero.
    public init(
        _ shape: S, mainColor: Color, textColor: Color, darkShadowColor: Color, lightShadowColor: Color,
        pressedEffect: SoftButtonPressedEffect, padding: CGFloat = 16, size: CGSize, minimumSize: CGSize
    ) {
        self.init(
            shape, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor,
            lightShadowColor: lightShadowColor, pressedEffect: pressedEffect, padding: padding, size: size)
        self.minimumSize = minimumSize
    }

    /// Builds the fixed-size button content for the current state.
    public func makeBody(configuration: Self.Configuration) -> some View {
        SoftDynamicButton(
            configuration: configuration, shape: shape, mainColor: mainColor, textColor: textColor,
            darkShadowColor: darkShadowColor, lightShadowColor: lightShadowColor, pressedEffect: pressedEffect,
            padding: padding, minimumSize: minimumSize, size: size)
    }

    struct SoftDynamicButton: View {
        let configuration: ButtonStyle.Configuration

        var shape: S
        var mainColor: Color
        var textColor: Color
        var darkShadowColor: Color
        var lightShadowColor: Color
        var pressedEffect: SoftButtonPressedEffect
        var padding: CGFloat
        var minimumSize: CGSize?
        var size: CGSize

        @Environment(\.isEnabled) private var isEnabled: Bool
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            configuration.label
                .foregroundColor(isEnabled ? textColor : textColor.opacity(0.55))
                .frame(width: size.width, height: size.height)
                .padding(padding)
                .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
                .background(
                    ZStack {
                        if isEnabled {
                            if pressedEffect == .flat {
                                shape.stroke(darkShadowColor, lineWidth: configuration.isPressed ? 1 : 0)
                                    .opacity(configuration.isPressed ? 1 : 0)
                                shape.fill(mainColor)
                            } else if pressedEffect == .hard {
                                shape.fill(mainColor)
                                    .softInnerShadow(
                                        shape, darkShadow: darkShadowColor, lightShadow: lightShadowColor, spread: 0.15,
                                        radius: 3
                                    )
                                    .opacity(configuration.isPressed ? 1 : 0)
                            }
                            shape.fill(mainColor)
                                .softOuterShadow(
                                    darkShadow: darkShadowColor, lightShadow: lightShadowColor, offset: 6, radius: 3
                                )
                                .opacity(pressedEffect == .none ? 1 : (configuration.isPressed ? 0 : 1))
                        } else {
                            shape.stroke(darkShadowColor, lineWidth: 1)
                                .opacity(1)
                            shape.fill(mainColor)
                        }
                    }
                )
                .modifier(NeumorphicButtonBoundsModifier(minimumSize: minimumSize))
        }
    }
}

public extension View {
    /// Applies a soft button style with an explicit visual size.
    ///
    /// Uses a 28-by-28-point minimum layout and hit region on macOS, and 44-by-44 on iOS.
    ///
    /// - Parameters:
    ///   - content: The shape of the surface.
    ///   - mainColor: The surface color.
    ///   - textColor: The label and symbol color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - pressedEffect: The visual treatment applied while the control is pressed.
    ///   - size: The label frame before padding. Negative width or height is normalized to zero.
    func fixedSizeSoftButtonStyle<S: Shape>(
        _ content: S = Circle(), mainColor: Color = Color.Neumorphic.main,
        textColor: Color = Color.Neumorphic.secondary, darkShadowColor: Color = Color.Neumorphic.darkShadow,
        lightShadowColor: Color = Color.Neumorphic.lightShadow, pressedEffect: SoftButtonPressedEffect = .hard,
        size: CGSize = .init(width: 30, height: 30)
    ) -> some View {
        buttonStyle(
            FixedSizeSoftDynamicButtonStyle(
                content, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor,
                lightShadowColor: lightShadowColor, pressedEffect: pressedEffect, padding: 0, size: size))
    }

    /// Applies a fixed-size soft button style with explicit layout and rectangular hit bounds.
    ///
    /// Transparent margins are hittable and do not shrink during presses. Shadows may
    /// extend beyond the complete frame. See <doc:ButtonSizing> for sizing examples.
    ///
    /// - Parameters:
    ///   - content: The shape of the surface.
    ///   - mainColor: The surface color.
    ///   - textColor: The label and symbol color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - pressedEffect: The visual treatment applied while the control is pressed.
    ///   - size: The label frame before padding. Negative width or height is normalized to zero.
    ///   - minimumSize: The minimum complete layout and hit size. Use `.zero` for no minimum.
    ///     Negative or nonfinite components become zero.
    func fixedSizeSoftButtonStyle<S: Shape>(
        _ content: S = Circle(), mainColor: Color = Color.Neumorphic.main,
        textColor: Color = Color.Neumorphic.secondary, darkShadowColor: Color = Color.Neumorphic.darkShadow,
        lightShadowColor: Color = Color.Neumorphic.lightShadow, pressedEffect: SoftButtonPressedEffect = .hard,
        size: CGSize = .init(width: 30, height: 30), minimumSize: CGSize
    ) -> some View {
        buttonStyle(
            FixedSizeSoftDynamicButtonStyle(
                content, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor,
                lightShadowColor: lightShadowColor, pressedEffect: pressedEffect, padding: 0, size: size,
                minimumSize: minimumSize))
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        Button {
        } label: {
            Text("Close")
        }
        .fixedSizeSoftButtonStyle(
            RoundedRectangle(cornerRadius: 12), mainColor: Color.accentColor, textColor: Color.Neumorphic.main,
            size: .init(width: 60, height: 60)
        )
        .padding()
    }
}
