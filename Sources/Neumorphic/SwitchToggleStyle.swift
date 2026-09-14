//
//  SwitchToggleStyle.swift
//
//
//  Created by will on 2023/1/16.
//

import SwiftUI

/// A SwiftUI-compatible switch toggle style with Neumorphic visuals.
public struct NeumorphicSwitchToggleStyle: ToggleStyle {
    @NeumorphicControlSizing private var metrics
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var tintColor: Color
    var offTintColor: Color

    var mainColor: Color
    var darkShadowColor: Color
    var lightShadowColor: Color

    var hideLabel: Bool
    var height: CGFloat?
    var geometry: NeumorphicSwitchGeometry {
        height.map(NeumorphicSwitchGeometry.init(height:)) ?? metrics.switchGeometry
    }
    var ratio: CGFloat { geometry.height / 45 }

    /// Creates a switch style with customizable colors and dimensions.
    ///
    /// - Parameters:
    ///   - tint: The track color while the control is on.
    ///   - offTint: The track color while the control is off.
    ///   - mainColor: The switch surface color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - labelsHidden: A Boolean value that hides the label when `true`.
    ///   - height: An explicit surface height, overriding platform sizing. Invalid values become 1.
    public init(
        tint: Color = .green,
        offTint: Color = Color.Neumorphic.main,
        mainColor: Color = Color.Neumorphic.main,
        darkShadowColor: Color = Color.Neumorphic.darkShadow,
        lightShadowColor: Color = Color.Neumorphic.lightShadow,
        labelsHidden: Bool = false,
        height: CGFloat = 30
    ) {
        self.tintColor = tint
        self.offTintColor = offTint
        self.mainColor = mainColor
        self.darkShadowColor = darkShadowColor
        self.lightShadowColor = lightShadowColor
        self.hideLabel = labelsHidden
        self.height = height.isFinite ? max(height, 1) : 1
    }

    /// Creates a switch whose visual size follows the platform and `controlSize` environment.
    ///
    /// - Parameters:
    ///   - tint: The track color while the control is on.
    ///   - offTint: The track color while the control is off.
    ///   - mainColor: The switch surface color.
    ///   - darkShadowColor: The lower-right shadow color.
    ///   - lightShadowColor: The upper-left highlight color.
    ///   - labelsHidden: Whether to hide the label.
    public init(
        tint: Color = .green, offTint: Color = Color.Neumorphic.main,
        mainColor: Color = Color.Neumorphic.main, darkShadowColor: Color = Color.Neumorphic.darkShadow,
        lightShadowColor: Color = Color.Neumorphic.lightShadow, labelsHidden: Bool = false
    ) {
        self.init(
            tint: tint, offTint: offTint, mainColor: mainColor, darkShadowColor: darkShadowColor,
            lightShadowColor: lightShadowColor, labelsHidden: labelsHidden, height: 30)
        height = nil
    }

    /// Builds the switch content for the current state.
    public func makeBody(configuration: Self.Configuration) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: metrics.spacing) {
                if !hideLabel {
                    configuration.label
                    Spacer()
                }
                ZStack {
                    Capsule()
                        .fill(mainColor)
                        .softOuterShadow(
                            darkShadow: darkShadowColor,
                            lightShadow: lightShadowColor
                        )
                        .frame(width: geometry.width, height: geometry.height)

                    Capsule()
                        .fill(configuration.isOn ? tintColor : offTintColor)
                        .softInnerShadow(
                            Capsule(), darkShadow: configuration.isOn ? tintColor : darkShadowColor,
                            lightShadow: configuration.isOn ? tintColor : lightShadowColor, spread: 0.35,
                            radius: 3 * ratio
                        )
                        .frame(width: geometry.width - 2 * geometry.inset, height: geometry.height - 2 * geometry.inset)

                    Circle()
                        .fill(mainColor)
                        .softOuterShadow(
                            darkShadow: darkShadowColor, lightShadow: lightShadowColor, offset: 2 * ratio,
                            radius: 1 * ratio
                        )
                        .frame(width: geometry.thumbDiameter, height: geometry.thumbDiameter)
                        .offset(x: configuration.isOn ? geometry.travel : -geometry.travel)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: configuration.isOn)
                }
                .opacity(isEnabled ? 1 : 0.4)
            }
            .modifier(NeumorphicControlBoundsModifier())
        }
        .buttonStyle(.plain)
        .stateAccessibilityValue(configuration.isOn)
    }

}

private extension View {
    func stateAccessibilityValue(_ isOn: Bool) -> some View {
        accessibility(value: Text(LocalizedStringKey(isOn ? "On" : "Off")))
    }
}

public extension View {
    /// Applies a switch style using platform and `controlSize` defaults.
    ///
    /// - Parameters:
    ///   - tint: The track color while on.
    ///   - offTint: The track color while off.
    ///   - mainColor: The surface color.
    ///   - darkShadowColor: The lower-right shadow color.
    ///   - lightShadowColor: The upper-left highlight color.
    ///   - labelsHidden: Whether to hide the label.
    func switchToggleStyle(
        tint: Color = .green, offTint: Color = Color.Neumorphic.main, mainColor: Color = Color.Neumorphic.main,
        darkShadowColor: Color = Color.Neumorphic.darkShadow, lightShadowColor: Color = Color.Neumorphic.lightShadow,
        labelsHidden: Bool = false
    ) -> some View {
        toggleStyle(
            NeumorphicSwitchToggleStyle(
                tint: tint, offTint: offTint, mainColor: mainColor, darkShadowColor: darkShadowColor,
                lightShadowColor: lightShadowColor, labelsHidden: labelsHidden))
    }

    /// Applies the Neumorphic switch toggle style.
    ///
    /// - Parameters:
    ///   - tint: The track color while the control is on.
    ///   - offTint: The track color while the control is off.
    ///   - mainColor: The switch surface color.
    ///   - darkShadowColor: The shadow color applied toward the lower-right edge.
    ///   - lightShadowColor: The highlight color applied toward the upper-left edge.
    ///   - labelsHidden: A Boolean value that hides the label when `true`.
    ///   - height: An explicit surface height, overriding platform sizing. Invalid values become 1.
    func switchToggleStyle(
        tint: Color = .green, offTint: Color = Color.Neumorphic.main, mainColor: Color = Color.Neumorphic.main,
        darkShadowColor: Color = Color.Neumorphic.darkShadow, lightShadowColor: Color = Color.Neumorphic.lightShadow,
        labelsHidden: Bool = false, height: CGFloat = 30
    ) -> some View {
        toggleStyle(
            NeumorphicSwitchToggleStyle(
                tint: tint, offTint: offTint, mainColor: mainColor, darkShadowColor: darkShadowColor,
                lightShadowColor: lightShadowColor, labelsHidden: labelsHidden, height: height))
    }
}

public extension ToggleStyle where Self == NeumorphicSwitchToggleStyle {
    /// The default Neumorphic switch style.
    static var neumorphicSwitch: Self { .init() }
}

struct SwitchToggleStyleBox: View {
    @State var isEnabled: Bool = true
    var body: some View {
        VStack {
            Text("isEnabled: \(isEnabled ? "ON" : "OFF")")

            Toggle("isEnabled", isOn: $isEnabled)
                .switchToggleStyle(tint: .accentColor, height: 20)
            Toggle("isEnabled", isOn: $isEnabled)
                .toggleStyle(
                    SoftSwitchToggleStyle(
                        tintColor: .accentColor, offTintColor: Color.Neumorphic.main, mainColor: Color.Neumorphic.main,
                        darkShadowColor: Color.Neumorphic.darkShadow, lightShadowColor: Color.Neumorphic.lightShadow,
                        hideLabel: false))
            Toggle("isEnabled", isOn: $isEnabled)
                .toggleStyle(
                    SoftDynamicToggleStyle(
                        RoundedRectangle(cornerRadius: 10, style: .continuous), mainColor: Color.Neumorphic.main,
                        textColor: Color.Neumorphic.secondary, darkShadowColor: Color.Neumorphic.darkShadow,
                        lightShadowColor: Color.Neumorphic.lightShadow, pressedEffect: .hard, padding: 10))
        }
        .padding()
        .background(Color.Neumorphic.main)
    }
}

struct SwitchToggleStyleBox_Previews: PreviewProvider {
    static var previews: some View {
        SwitchToggleStyleBox()
    }
}
