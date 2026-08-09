import SwiftUI

/// A text field with a soft inset surface and focus treatment.
public struct NeumorphicTextField: View {
    @Environment(\.neumorphicTheme) private var theme
    private let title: String
    @Binding private var text: String
    private let isSecure: Bool

    public init(_ title: String, text: Binding<String>, secure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = secure
    }

    public var body: some View {
        Group {
            if isSecure { SecureField(title, text: $text) } else { TextField(title, text: $text) }
        }
        .textFieldStyle(PlainTextFieldStyle())
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
        .foregroundColor(theme.secondaryColor)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.mainColor)
                .softInnerShadow(
                    RoundedRectangle(cornerRadius: 12),
                    darkShadow: theme.darkShadowColor,
                    lightShadow: theme.lightShadowColor,
                    spread: 0.55,
                    radius: 3
                )
        )
    }
}
