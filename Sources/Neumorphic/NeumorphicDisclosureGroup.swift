import SwiftUI

/// An expandable group with a soft raised header.
public struct NeumorphicDisclosureGroup<Content: View>: View {
    @NeumorphicControlSizing private var metrics
    @Environment(\.neumorphicTheme) private var theme
    private let title: String
    @Binding private var isExpanded: Bool
    private let content: Content

    /// Creates an expandable neumorphic group.
    ///
    /// - Parameters:
    ///   - title: The text displayed in the group header.
    ///   - isExpanded: A binding that controls whether the content is visible.
    ///   - content: The content revealed when the group is expanded.
    public init(_ title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isExpanded = isExpanded
        self.content = content()
    }

    /// The rendered disclosure group.
    public var body: some View {
        VStack(alignment: .leading, spacing: metrics.spacing) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack {
                    Text(title).font(.headline)
                    Spacer()
                    Text(isExpanded ? "⌃" : "⌄").font(.headline)
                }
                .foregroundColor(theme.secondaryColor)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, metrics.verticalPadding)
                .modifier(NeumorphicControlBoundsModifier())
            }
            .buttonStyle(PlainButtonStyle())
            .neumorphicButtonAccessibility(
                label: title, hint: isExpanded ? "Double-tap to collapse" : "Double-tap to expand")
            if isExpanded {
                content
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: metrics.cornerRadius)
                .fill(theme.mainColor)
                .softOuterShadow(.subtle)
        )
    }
}
