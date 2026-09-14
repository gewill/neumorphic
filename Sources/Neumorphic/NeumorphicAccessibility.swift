import SwiftUI

extension View {
    func neumorphicSliderAccessibility(
        label: Text, value: String, adjust: @escaping (AccessibilityAdjustmentDirection) -> Void
    ) -> some View {
        accessibilityElement(children: .ignore)
            .accessibility(label: label)
            .accessibility(value: Text(verbatim: value))
            .accessibilityAdjustableAction(adjust)
    }

    func neumorphicProgressAccessibility(label: Text, value: Text) -> some View {
        accessibilityElement(children: .ignore)
            .accessibility(label: label)
            .accessibility(value: value)
    }

    @ViewBuilder
    func neumorphicSelectionAccessibility(label: String, selected: Bool) -> some View {
        if #available(iOS 14.0, macOS 11.0, *) {
            accessibility(label: Text(verbatim: label))
                .accessibilityAddTraits(selected ? .isSelected : [])
        } else {
            accessibility(label: Text(verbatim: label))
                .accessibility(value: Text(LocalizedStringKey(selected ? "Selected" : "Not selected")))
        }
    }

    @ViewBuilder
    func neumorphicButtonAccessibility(label: String, hint: String? = nil) -> some View {
        if let hint = hint {
            neumorphicButtonAccessibility(
                label: Text(verbatim: label),
                hint: Text(LocalizedStringKey(hint))
            )
        } else {
            neumorphicButtonAccessibility(label: Text(verbatim: label))
        }
    }

    @ViewBuilder
    func neumorphicButtonAccessibility(label: Text, hint: Text? = nil) -> some View {
        if let hint = hint {
            accessibility(label: label)
                .accessibility(hint: hint)
        } else {
            accessibility(label: label)
        }
    }
}

// Keep hit bounds outside the label's press transform and the surface's shadows.
struct NeumorphicButtonBoundsModifier: ViewModifier {
    let minimumSize: CGSize?

    static var defaultMinimumSize: CGSize {
        #if os(macOS)
            CGSize(width: 28, height: 28)
        #else
            CGSize(width: 44, height: 44)
        #endif
    }

    func body(content: Content) -> some View {
        let minimumSize = minimumSize ?? Self.defaultMinimumSize
        return
            content
            .frame(
                minWidth: minimumSize.width.isFinite ? max(0, minimumSize.width) : 0,
                minHeight: minimumSize.height.isFinite ? max(0, minimumSize.height) : 0
            )
            .contentShape(Rectangle())
    }
}
