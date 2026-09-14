import SwiftUI

// Geometry belongs to the library's visual language; target sizes follow the input platform.
struct NeumorphicControlMetrics {
    enum Size { case mini, small, regular, large }

    var size: Size = .regular

    var minimumDimension: CGFloat {
        #if os(macOS)
            switch size {
            case .mini: return 20
            case .small: return 24
            case .regular: return 28
            case .large: return 32
            }
        #else
            return size == .large ? 52 : 44
        #endif
    }

    var horizontalPadding: CGFloat {
        switch size {
        case .mini: return 6
        case .small: return 8
        case .regular: return 10
        case .large: return 12
        }
    }

    var verticalPadding: CGFloat {
        #if os(macOS)
            return size == .large ? 4 : 2
        #else
            return size == .large ? 10 : 6
        #endif
    }

    var spacing: CGFloat { horizontalPadding }
    var cornerRadius: CGFloat { minimumDimension / 4 }

    var indicatorDiameter: CGFloat {
        #if os(macOS)
            switch size {
            case .mini: return 12
            case .small: return 14
            case .regular: return 16
            case .large: return 20
            }
        #else
            switch size {
            case .mini: return 20
            case .small: return 24
            case .regular: return 28
            case .large: return 32
            }
        #endif
    }

    var sliderThumbDiameter: CGFloat {
        #if os(macOS)
            return indicatorDiameter + 4
        #else
            return indicatorDiameter
        #endif
    }

    var sliderTrackHeight: CGFloat { size == .large ? 6 : 4 }

    var switchGeometry: NeumorphicSwitchGeometry {
        #if os(macOS)
            switch size {
            case .mini: return .init(width: 36, height: 16, thumbDiameter: 12)
            case .small: return .init(width: 44, height: 20, thumbDiameter: 16)
            case .regular: return .init(width: 54, height: 24, thumbDiameter: 20)
            case .large: return .init(width: 64, height: 28, thumbDiameter: 24)
            }
        #else
            switch size {
            case .mini: return .init(height: 24)
            case .small: return .init(height: 27)
            case .regular: return .init(height: 30)
            case .large: return .init(height: 36)
            }
        #endif
    }
}

struct NeumorphicSwitchGeometry {
    var width: CGFloat
    var height: CGFloat
    var thumbDiameter: CGFloat
    var inset: CGFloat
    var travel: CGFloat

    init(width: CGFloat, height: CGFloat, thumbDiameter: CGFloat) {
        self.width = width
        self.height = height
        self.thumbDiameter = thumbDiameter
        inset = 2
        travel = max(0, (width - thumbDiameter) / 2 - inset)
    }

    // Explicit heights retain the original switch proportions.
    init(height: CGFloat) {
        let height = height.isFinite ? max(1, height) : 1
        self.height = height
        width = height * 75 / 45
        thumbDiameter = height * 30 / 45
        inset = height * 2.5 / 45
        travel = height * 15 / 45
    }
}

// iOS 13–14 has no controlSize environment; use regular metrics there.
@propertyWrapper
struct NeumorphicControlSizing: DynamicProperty {
    @Environment(\.self) private var environment

    var wrappedValue: NeumorphicControlMetrics {
        if #available(iOS 15.0, *) {
            switch environment.controlSize {
            case .mini: return .init(size: .mini)
            case .small: return .init(size: .small)
            case .regular: return .init(size: .regular)
            default: return .init(size: .large)
            }
        }
        return .init()
    }
}
