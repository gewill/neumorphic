//
//  SwitchToggleStyle.swift
//
//
//  Created by will on 2023/1/16.
//

import SwiftUI

public struct SwitchToggleStyle: ToggleStyle {
    var tintColor: Color
    var offTintColor: Color

    var mainColor: Color
    var darkShadowColor: Color
    var lightShadowColor: Color

    var hideLabel: Bool
    var height: CGFloat
    var ratio: CGFloat { height / 45 }

    public func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            if !hideLabel {
                configuration.label
                Spacer()
            }
            ZStack {
                Capsule()
                    .fill(mainColor)
                    .softOuterShadow()
                    .frame(width: 75 * ratio, height: 45 * ratio)

                Capsule()
                    .fill(configuration.isOn ? tintColor : offTintColor)
                    .softInnerShadow(Capsule(), darkShadow: configuration.isOn ? tintColor : darkShadowColor, lightShadow: configuration.isOn ? tintColor : lightShadowColor, spread: 0.35, radius: 3 * ratio)
                    .frame(width: 70 * ratio, height: 40 * ratio)

                Circle()
                    .fill(mainColor)
                    .softOuterShadow(darkShadow: darkShadowColor, lightShadow: lightShadowColor, offset: 2 * ratio, radius: 1 * ratio)
                    .frame(width: 30 * ratio, height: 30 * ratio)
                    .offset(x: configuration.isOn ? 15 * ratio : -15 * ratio)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

public extension Toggle {
    func switchToggleStyle(tint: Color = .green, offTint: Color = Color.Neumorphic.main, mainColor: Color = Color.Neumorphic.main, darkShadowColor: Color = Color.Neumorphic.darkShadow, lightShadowColor: Color = Color.Neumorphic.lightShadow, labelsHidden: Bool = false, height: CGFloat = 30) -> some View {
        return toggleStyle(SwitchToggleStyle(tintColor: tint, offTintColor: offTint, mainColor: mainColor, darkShadowColor: darkShadowColor, lightShadowColor: lightShadowColor, hideLabel: labelsHidden, height: height))
    }
}

struct SwitchToggleStyleBox: View {
    @State var isEnabled: Bool = true
    var body: some View {
        VStack {
            Text("isEnabled: \(isEnabled ? "ON" : "OFF")")

            Toggle("isEnabled", isOn: $isEnabled)
                .switchToggleStyle(tint: .accentColor, height: 20)
            Toggle("isEnabled", isOn: $isEnabled)
                .softSwitchToggleStyle(tint: .accentColor)
            Toggle("isEnabled", isOn: $isEnabled)
                .softToggleStyle(RoundedRectangle(cornerRadius: 10, style: .continuous), padding: 10)
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
