import SwiftUI

/// A neumorphic checkbox control.
public struct NeumorphicCheckbox: View {
    @Environment(\.neumorphicTheme) private var theme
    @Binding private var isOn: Bool
    private let label: String

    public init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }

    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 6).fill(theme.mainColor).frame(width: 28, height: 28)
                    .softInnerShadow(
                        RoundedRectangle(cornerRadius: 6),
                        darkShadow: theme.darkShadowColor,
                        lightShadow: theme.lightShadowColor,
                        spread: 0.55,
                        radius: 3
                    )
                    .overlay(Text("✓").font(.caption.weight(.bold)).foregroundColor(.accentColor).opacity(isOn ? 1 : 0))
                Text(label).foregroundColor(theme.secondaryColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphicSelectionAccessibility(label: label, selected: isOn)
        .frame(minHeight: 44)
    }
}

/// A neumorphic radio button control.
public struct NeumorphicRadio<Value: Hashable>: View {
    @Environment(\.neumorphicTheme) private var theme
    @Binding private var selection: Value
    private let value: Value
    private let label: String

    public init(_ label: String, value: Value, selection: Binding<Value>) {
        self.label = label
        self.value = value
        self._selection = selection
    }

    public var body: some View {
        Button {
            selection = value
        } label: {
            HStack(spacing: 10) {
                Circle().fill(theme.mainColor).frame(width: 28, height: 28)
                    .softInnerShadow(
                        Circle(),
                        darkShadow: theme.darkShadowColor,
                        lightShadow: theme.lightShadowColor,
                        spread: 0.55,
                        radius: 3
                    )
                    .overlay(
                        Circle().fill(Color.accentColor).frame(width: 10, height: 10).opacity(
                            selection == value ? 1 : 0))
                Text(label).foregroundColor(theme.secondaryColor)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphicSelectionAccessibility(label: label, selected: selection == value)
        .frame(minHeight: 44)
    }
}
