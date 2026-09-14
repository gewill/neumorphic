import SwiftUI

/// A neumorphic checkbox control.
public struct NeumorphicCheckbox: View {
    @NeumorphicControlSizing private var metrics
    @Environment(\.neumorphicTheme) private var theme
    @Binding private var isOn: Bool
    private let label: String

    /// Creates a checkbox bound to a Boolean value.
    ///
    /// - Parameters:
    ///   - label: The visible and accessibility label for the checkbox.
    ///   - isOn: A binding that stores the checkbox state.
    public init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }

    /// The rendered checkbox.
    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: metrics.spacing) {
                RoundedRectangle(cornerRadius: metrics.indicatorDiameter / 4).fill(theme.mainColor).frame(
                    width: metrics.indicatorDiameter, height: metrics.indicatorDiameter
                )
                .softInnerShadow(
                    RoundedRectangle(cornerRadius: metrics.indicatorDiameter / 4),
                    darkShadow: theme.darkShadowColor,
                    lightShadow: theme.lightShadowColor,
                    spread: 0.55,
                    radius: 3
                )
                .overlay(Text("✓").font(.caption.weight(.bold)).foregroundColor(.accentColor).opacity(isOn ? 1 : 0))
                Text(label).foregroundColor(theme.secondaryColor)
            }
            .modifier(NeumorphicControlBoundsModifier())
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphicSelectionAccessibility(label: label, selected: isOn)
    }
}

/// A neumorphic radio button control.
public struct NeumorphicRadio<Value: Hashable>: View {
    @NeumorphicControlSizing private var metrics
    @Environment(\.neumorphicTheme) private var theme
    @Binding private var selection: Value
    private let value: Value
    private let label: String

    /// Creates a radio button for one candidate value.
    ///
    /// - Parameters:
    ///   - label: The visible and accessibility label for the radio button.
    ///   - value: The value this radio button selects.
    ///   - selection: A binding to the selected value in the radio group.
    public init(_ label: String, value: Value, selection: Binding<Value>) {
        self.label = label
        self.value = value
        self._selection = selection
    }

    /// The rendered radio button.
    public var body: some View {
        Button {
            selection = value
        } label: {
            HStack(spacing: metrics.spacing) {
                Circle().fill(theme.mainColor).frame(
                    width: metrics.indicatorDiameter, height: metrics.indicatorDiameter
                )
                .softInnerShadow(
                    Circle(),
                    darkShadow: theme.darkShadowColor,
                    lightShadow: theme.lightShadowColor,
                    spread: 0.55,
                    radius: 3
                )
                .overlay(
                    Circle().fill(Color.accentColor).frame(
                        width: metrics.indicatorDiameter * 0.4, height: metrics.indicatorDiameter * 0.4
                    ).opacity(
                        selection == value ? 1 : 0))
                Text(label).foregroundColor(theme.secondaryColor)
            }
            .modifier(NeumorphicControlBoundsModifier())
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphicSelectionAccessibility(label: label, selected: selection == value)
    }
}
