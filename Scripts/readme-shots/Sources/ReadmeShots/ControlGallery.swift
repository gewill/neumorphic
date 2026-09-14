import AppKit
import Neumorphic
import SwiftUI

/// Renders one mounted view at a time so native editors and SwiftUI share the same layout.
@MainActor
func renderControlGallery(to directory: URL) {
    NSApplication.shared.setActivationPolicy(.accessory)
    for kind in GalleryControl.allCases {
        let content = GalleryControlView(kind: kind)
            .frame(width: 360)
            .padding(32)
            .background(Color.Neumorphic.main)
            .environment(\.colorScheme, .light)
            .environment(\.locale, Locale(identifier: "en_US"))
            .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)
            .controlSize(.regular)
            .fixedSize(horizontal: false, vertical: true)
        let host = NSHostingView(rootView: content)
        host.appearance = NSAppearance(named: .aqua)
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 424, height: 240),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = host
        window.orderFrontRegardless()
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.15))
        window.setContentSize(host.fittingSize)
        host.layoutSubtreeIfNeeded()
        window.makeFirstResponder(nil)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.15))
        guard window.backingScaleFactor == 2 else {
            fatalError("Gallery images require a 2x display to match their @2x filenames")
        }
        let url = directory.appendingPathComponent("gallery-\(kind.rawValue)@2x.png")
        let capture = Process()
        capture.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        capture.arguments = ["-x", "-o", "-l", String(window.windowNumber), url.path]
        do {
            try capture.run()
            capture.waitUntilExit()
            guard capture.terminationStatus == 0 else {
                fatalError("Cannot capture \(kind.rawValue); check Screen Recording permission")
            }
            print("wrote \(url.path)")
        } catch {
            fatalError("Cannot capture \(url.path): \(error)")
        }
        window.close()
    }
}

private enum GalleryControl: String, CaseIterable {
    case buttons, toggles, slider, textField = "text-field", secureField = "secure-field"
    case stepper, datePicker = "date-picker", picker, menu, checkbox, radio
    case progress, circularProgress = "circular-progress", disclosure, link, card, shadows, focus
}

private struct GalleryControlView: View {
    let kind: GalleryControl
    @State private var text = "Hello, Neumorphic"
    @State private var password = ""
    @State private var value = 0.65
    @State private var isOn = true
    @State private var count = 2
    @State private var selection = "Light"
    @State private var date = Date(timeIntervalSince1970: 1_789_344_000)

    @ViewBuilder var body: some View {
        switch kind {
        case .buttons:
            HStack(spacing: 28) {
                Button("Continue") {}.softButtonStyle(Capsule(), padding: 8)
                Button {
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .fixedSizeSoftButtonStyle(Circle(), size: CGSize(width: 28, height: 28))
                Button("Save") {}.neumorphicThemedButtonStyle(Capsule(), role: .accent, padding: 8)
            }
        case .toggles:
            HStack(spacing: 36) {
                Toggle("Enabled", isOn: $isOn).switchToggleStyle()
                Toggle(isOn: $isOn) { Image(systemName: "play.fill") }
                    .neumorphicThemedToggleStyle(Circle(), padding: 12)
            }
        case .slider: NeumorphicSlider(value: $value).accessibilityLabel("Volume")
        case .textField: NeumorphicTextField("Name", text: $text)
        case .secureField: NeumorphicTextField("Password", text: $password, secure: true)
        case .stepper: NeumorphicStepper("Quantity", value: $count, in: 0...5)
        case .datePicker: NeumorphicDatePicker("Date", selection: $date, displayedComponents: .date)
        case .picker: NeumorphicPicker(selection: $selection, options: ["Light", "Dark"])
        case .menu: NeumorphicMenu("Appearance", selection: $selection, options: ["Light", "Dark"])
        case .checkbox: NeumorphicCheckbox("Remember me", isOn: $isOn)
        case .radio:
            HStack(spacing: 24) {
                NeumorphicRadio("Light", value: "Light", selection: $selection)
                NeumorphicRadio("Dark", value: "Dark", selection: $selection)
            }
        case .progress:
            VStack(spacing: 16) {
                Text("Downloading · 65%")
                NeumorphicProgressView(value: value)
            }
        case .circularProgress:
            HStack(spacing: 24) {
                NeumorphicCircularProgressView(value: value)
                Text("65% complete")
            }
        case .disclosure:
            NeumorphicDisclosureGroup("Details", isExpanded: $isOn) {
                Text("Additional information").frame(maxWidth: .infinity, alignment: .leading)
            }
        case .link: NeumorphicLink("Visit website", destination: URL(string: "https://example.com")!)
        case .card:
            VStack(alignment: .leading, spacing: 12) {
                Text("Your workspace").font(.headline)
                Text("Group related content on a raised surface.")
            }.frame(maxWidth: .infinity, alignment: .leading).neumorphicCard()
        case .shadows:
            HStack(spacing: 40) {
                Circle().fill(Color.Neumorphic.main).frame(width: 72, height: 72).softOuterShadow()
                Circle().fill(Color.Neumorphic.main).frame(width: 72, height: 72).softInnerShadow(Circle())
            }
        case .focus:
            HStack(spacing: 28) {
                Button("Focus") {}.softButtonStyle(Capsule(), padding: 8)
                    .neumorphicFocusRing(Capsule(), isFocused: $isOn)
                Button("Hover") {}.softButtonStyle(Capsule(), padding: 8)
                    .neumorphicHover(Capsule(), isHovered: $isOn)
            }
        }
    }
}
