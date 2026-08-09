import SwiftUI

/// A linear progress indicator with an inset track.
public struct NeumorphicProgressView: View {
    @Environment(\.neumorphicTheme) private var theme
    private let value: Double?
    private let total: Double
    private let tint: Color
    private let height: CGFloat
    private let accessibilityLabel: String

    public init(
        value: Double?, total: Double = 1, tint: Color = .accentColor, height: CGFloat = 10,
        accessibilityLabel: String = "Progress"
    ) {
        self.value = value
        self.total = max(total, 0)
        self.tint = tint
        self.height = max(height, 2)
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        GeometryReader { proxy in
            let fraction = NeumorphicProgressMath.normalizedFraction(value: value, total: total)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.mainColor)
                    .softInnerShadow(
                        Capsule(),
                        darkShadow: theme.darkShadowColor,
                        lightShadow: theme.lightShadowColor,
                        spread: 0.5,
                        radius: 3
                    )
                if let fraction = fraction {
                    Capsule().fill(tint).frame(width: proxy.size.width * CGFloat(fraction))
                } else {
                    NeumorphicLinearIndeterminateIndicator(tint: tint, availableWidth: proxy.size.width)
                }
            }
        }
        .frame(height: height)
        .neumorphicProgressAccessibility(
            label: accessibilityLabel,
            value: NeumorphicProgressMath.normalizedFraction(value: value, total: total).map {
                Text(verbatim: String(format: "%.0f%%", $0 * 100))
            } ?? Text(LocalizedStringKey("In progress"))
        )
    }
}

private struct NeumorphicLinearIndeterminateIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    let tint: Color
    let availableWidth: CGFloat

    var body: some View {
        Capsule()
            .fill(tint)
            .frame(width: availableWidth * 0.35)
            .offset(x: reduceMotion ? availableWidth * 0.325 : (isAnimating ? availableWidth * 0.65 : 0))
            .opacity(reduceMotion ? 0.7 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

enum NeumorphicProgressMath {
    static func normalizedFraction(value: Double?, total: Double) -> Double? {
        guard let value = value else { return nil }
        guard value.isFinite, total.isFinite, total > 0 else { return 0 }
        return min(max(value / total, 0), 1)
    }
}
