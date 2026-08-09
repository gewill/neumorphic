import SwiftUI

/// A neumorphic slider with an inset track and raised thumb.
public struct NeumorphicSlider: View {
    @Environment(\.neumorphicTheme) private var theme
    @Binding private var value: Double
    @State private var editingSession = NeumorphicSliderEditingSession()
    private let bounds: ClosedRange<Double>
    private let step: Double
    private let tint: Color
    private let accessibilityLabel: String
    private let onEditingChanged: (Bool) -> Void

    public init(
        value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1, step: Double = 0, tint: Color = .accentColor,
        accessibilityLabel: String = "Slider", onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.bounds = bounds
        self.step = max(step, 0)
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.onEditingChanged = onEditingChanged
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let progress = normalizedValue
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
                Capsule().fill(tint.opacity(0.8)).frame(width: max(0, width * progress), height: 6)
                Circle().fill(theme.mainColor).frame(width: 28, height: 28)
                    .softOuterShadow(
                        darkShadow: theme.darkShadowColor,
                        lightShadow: theme.lightShadowColor,
                        offset: 3,
                        radius: 2
                    )
                    .overlay(Circle().fill(tint).frame(width: 10, height: 10))
                    .offset(x: max(0, min(width - 28, width * progress - 14)))
            }
            .frame(height: 28)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { gesture in
                    if editingSession.begin() {
                        onEditingChanged(true)
                    }
                    updateValue(at: gesture.location.x, width: width)
                }.onEnded { _ in
                    if editingSession.end() {
                        onEditingChanged(false)
                    }
                })
        }
        .frame(minHeight: 44)
        .neumorphicSliderAccessibility(label: accessibilityLabel, value: String(format: "%.2f", value)) { direction in
            switch direction {
            case .increment:
                value = NeumorphicSliderMath.adjustedValue(value, in: bounds, step: step, incrementing: true)
            case .decrement:
                value = NeumorphicSliderMath.adjustedValue(value, in: bounds, step: step, incrementing: false)
            @unknown default: break
            }
        }
    }

    private var normalizedValue: CGFloat {
        guard bounds.upperBound > bounds.lowerBound else { return 0 }
        return CGFloat(
            (min(max(value, bounds.lowerBound), bounds.upperBound) - bounds.lowerBound)
                / (bounds.upperBound - bounds.lowerBound))
    }

    private func updateValue(at x: CGFloat, width: CGFloat) {
        value = NeumorphicSliderMath.value(
            at: Double(min(max(x / width, 0), 1)),
            in: bounds,
            step: step
        )
    }
}

struct NeumorphicSliderEditingSession {
    private(set) var isEditing = false

    mutating func begin() -> Bool {
        guard !isEditing else { return false }
        isEditing = true
        return true
    }

    mutating func end() -> Bool {
        guard isEditing else { return false }
        isEditing = false
        return true
    }
}

enum NeumorphicSliderMath {
    static func value(at fraction: Double, in bounds: ClosedRange<Double>, step: Double) -> Double {
        let clampedFraction = min(max(fraction, 0), 1)
        let rawValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * clampedFraction
        return snappedValue(rawValue, in: bounds, step: step)
    }

    static func adjustedValue(
        _ value: Double,
        in bounds: ClosedRange<Double>,
        step: Double,
        incrementing: Bool
    ) -> Double {
        let clampedValue = min(max(value, bounds.lowerBound), bounds.upperBound)
        guard step.isFinite, step > 0 else {
            let delta = (bounds.upperBound - bounds.lowerBound) / 20
            return min(
                max(clampedValue + (incrementing ? delta : -delta), bounds.lowerBound),
                bounds.upperBound
            )
        }

        let position = (clampedValue - bounds.lowerBound) / step
        let nearestPosition = position.rounded()
        let tolerance = Double.ulpOfOne * 16 * max(1, abs(position))
        let isAligned = abs(position - nearestPosition) <= tolerance
        let targetPosition: Double
        if incrementing {
            targetPosition = isAligned ? nearestPosition + 1 : position.rounded(.up)
        } else {
            targetPosition = isAligned ? nearestPosition - 1 : position.rounded(.down)
        }

        return min(
            max(bounds.lowerBound + targetPosition * step, bounds.lowerBound),
            bounds.upperBound
        )
    }

    private static func snappedValue(
        _ value: Double,
        in bounds: ClosedRange<Double>,
        step: Double
    ) -> Double {
        let clampedValue = min(max(value, bounds.lowerBound), bounds.upperBound)
        guard step.isFinite, step > 0 else { return clampedValue }
        let stepCount = ((clampedValue - bounds.lowerBound) / step).rounded()
        return min(
            max(bounds.lowerBound + stepCount * step, bounds.lowerBound),
            bounds.upperBound
        )
    }
}
