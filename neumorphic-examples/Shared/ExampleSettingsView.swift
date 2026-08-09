import SwiftUI
import Neumorphic

struct ExampleSettingsView: View {
    @State private var highContrast = false
    @State private var focusEnabled = false
    @State private var isHovered = false
    @State private var reduceMotion = false
    @State private var isOn = false

    private var theme: NeumorphicTheme { highContrast ? .highContrast : .standard }

    var body: some View {
        ZStack {
            Color.Neumorphic.main.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Settings & States")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(Color.Neumorphic.secondary)
                    SettingsSection("Theme") {
                        Toggle("High Contrast Theme", isOn: $highContrast)
                            .neumorphicThemedSwitchStyle(labelsHidden: false)
                        HStack(spacing: 12) {
                            Button("Themed Button", action: {})
                                .neumorphicThemedButtonStyle(Capsule())
                            Toggle("Themed Toggle", isOn: $isOn)
                                .neumorphicThemedToggleStyle(Capsule(), padding: 10)
                        }
                    }
                    SettingsSection("Accessibility States") {
                        Button("Focus Ring", action: { focusEnabled.toggle() })
                            .neumorphicFocusRing(Capsule(), isFocused: $focusEnabled)
                            .neumorphicThemedButtonStyle(Capsule())
                        Text("Hover me")
                            .padding(.horizontal, 18)
                            .frame(minHeight: 44)
                            .neumorphicHover(Capsule(), isHovered: $isHovered)
                            .foregroundColor(Color.Neumorphic.secondary)
                        Toggle("Reduce Motion Preview", isOn: $reduceMotion)
                            .neumorphicThemedSwitchStyle(labelsHidden: false)
                    }
                    SettingsSection("Shadow Presets") {
                        HStack(spacing: 18) {
                            ShadowPresetDemo(title: "Standard", preset: .standard)
                            ShadowPresetDemo(title: "Subtle", preset: .subtle)
                            ShadowPresetDemo(title: "None", preset: .none)
                        }
                    }
                    SettingsSection("Style Entry Points") {
                        Button(action: {}) { Image(systemName: "star.fill") }
                            .fixedSizeSoftButtonStyle(Circle(), size: CGSize(width: 56, height: 56))
                        Toggle("Neumorphic Switch", isOn: $isOn)
                            .toggleStyle(.neumorphicSwitch)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .neumorphicTheme(theme)
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.Neumorphic.secondary)
            content
        }
    }
}

private struct ShadowPresetDemo: View {
    let title: String
    let preset: NeumorphicShadowPreset

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.Neumorphic.main)
                .frame(width: 58, height: 58)
                .softOuterShadow(preset)
            Text(title)
                .font(.caption)
                .foregroundColor(Color.Neumorphic.secondary)
        }
    }
}
