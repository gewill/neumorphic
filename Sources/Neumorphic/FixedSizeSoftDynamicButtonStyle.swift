import SwiftUI
 
public struct FixedSizeSoftDynamicButtonStyle<S: Shape>: ButtonStyle {
    var shape: S
    var mainColor: Color
    var textColor: Color
    var darkShadowColor: Color
    var lightShadowColor: Color
    var pressedEffect: SoftButtonPressedEffect
    var padding: CGFloat
    var size: CGSize
    
    public init(_ shape: S, mainColor: Color, textColor: Color, darkShadowColor: Color, lightShadowColor: Color, pressedEffect: SoftButtonPressedEffect, padding: CGFloat = 16, size: CGSize) {
        self.shape = shape
        self.mainColor = mainColor
        self.textColor = textColor
        self.darkShadowColor = darkShadowColor
        self.lightShadowColor = lightShadowColor
        self.pressedEffect = pressedEffect
        self.padding = padding
        self.size = size
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        SoftDynamicButton(configuration: configuration, shape: shape, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor, lightShadowColor: lightShadowColor, pressedEffect: pressedEffect, padding: padding, size: size)
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
        var size: CGSize
    
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        var body: some View {
            configuration.label
                .foregroundColor(isEnabled ? textColor : darkShadowColor)
                .frame(width: size.width, height: size.height)
                .padding(padding)
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .background(
                    ZStack {
                        if isEnabled {
                            if pressedEffect == .flat {
                                shape.stroke(darkShadowColor, lineWidth: configuration.isPressed ? 1 : 0)
                                    .opacity(configuration.isPressed ? 1 : 0)
                                shape.fill(mainColor)
                            } else if pressedEffect == .hard {
                                shape.fill(mainColor)
                                    .softInnerShadow(shape, darkShadow: darkShadowColor, lightShadow: lightShadowColor, spread: 0.15, radius: 3)
                                    .opacity(configuration.isPressed ? 1 : 0)
                            }
                            shape.fill(mainColor)
                                .softOuterShadow(darkShadow: darkShadowColor, lightShadow: lightShadowColor, offset: 6, radius: 3)
                                .opacity(pressedEffect == .none ? 1 : (configuration.isPressed ? 0 : 1))
                        } else {
                            shape.stroke(darkShadowColor, lineWidth: 1)
                                .opacity(1)
                            shape.fill(mainColor)
                        }
                    }
                )
        }
    }
}

public extension View {
    func fixedSizeSoftButtonStyle<S: Shape>(_ content: S = Circle(), mainColor: Color = Color.Neumorphic.main, textColor: Color = Color.Neumorphic.secondary, darkShadowColor: Color = Color.Neumorphic.darkShadow, lightShadowColor: Color = Color.Neumorphic.lightShadow, pressedEffect: SoftButtonPressedEffect = .hard, size: CGSize = .init(width: 30, height: 30)) -> some View {
        buttonStyle(FixedSizeSoftDynamicButtonStyle(content, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor, lightShadowColor: lightShadowColor, pressedEffect: pressedEffect, padding: 0, size: size))
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        Button {} label: {
            Text("Close")
        }
        .fixedSizeSoftButtonStyle(RoundedRectangle(cornerRadius: 12), mainColor: Color.accentColor, textColor: Color.Neumorphic.main, size: .init(width: 60, height: 60))
        .padding()
    }
}
