import Neumorphic
import SwiftUI

/// Launch options let the capture script open the same interactive page as the example app.
enum ExampleSizingLaunch {
    static func value(_ key: String) -> String? {
        #if DEBUG
            let arguments = ProcessInfo.processInfo.arguments
            guard let index = arguments.firstIndex(of: key), index + 1 < arguments.count else { return nil }
            return arguments[index + 1]
        #else
            return nil
        #endif
    }

    static var section: String? { value("--sizing-section") }
}

struct ExampleSizingView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    @State private var section = ExampleSizingLaunch.section ?? "Controls"
    @State private var size =
        SizingChoice(rawValue: ExampleSizingLaunch.value("--sizing-size") ?? "Regular") ?? .regular
    @State private var control =
        SizingControl(rawValue: ExampleSizingLaunch.value("--sizing-control") ?? "Stepper") ?? .stepper
    @State private var button = SizingButtonCase.platform
    @State private var showBounds = true
    @State private var longLabels = false
    @State private var disabled = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Sizing").font(.title).fontWeight(.semibold).accessibilityAddTraits(.isHeader)
                    Text(
                        "Compare native and Neumorphic layouts."
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    Picker("Sizing category", selection: $section) {
                        Text("Buttons").tag("Buttons")
                        Text("Controls").tag("Controls")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("sizing.category")
                    options
                    if section == "Buttons" {
                        buttons(horizontal: proxy.size.width >= 680 && !sizeCategory.isAccessibilityCategory)
                    } else {
                        controls(horizontal: proxy.size.width >= 680 && !sizeCategory.isAccessibilityCategory)
                    }
                    displayOptions
                    Text(
                        "Dashed outline: layout only. Try the controls, their edges, and Disabled separately. Larger text can increase the layout height."
                    )
                    .font(.caption).fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .frame(maxWidth: 900, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color.Neumorphic.main.ignoresSafeArea())
        }
        .foregroundColor(Color.Neumorphic.secondary)
    }

    private var options: some View {
        VStack(alignment: .leading, spacing: 16) {
            if section == "Controls" {
                Picker("Control", selection: $control) {
                    ForEach(SizingControl.allCases) { Text($0.rawValue).tag($0) }
                }
                .accessibilityIdentifier("sizing.control")
                if #available(iOS 15, *) {
                    Picker("Control size", selection: $size) {
                        ForEach(SizingChoice.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("sizing.size")
                } else {
                    Text("This iOS version uses Regular sizing. Size selection requires iOS 15.").font(.caption)
                }
            } else {
                Picker("Button example", selection: $button) {
                    ForEach(SizingButtonCase.allCases) { Text($0.rawValue).tag($0) }
                }
                .accessibilityIdentifier("sizing.button")
            }

        }
    }

    private var displayOptions: some View {
        DisclosureGroup("Display options") {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Show layout bounds", isOn: $showBounds).accessibilityIdentifier("sizing.bounds")
                Toggle("Long labels", isOn: $longLabels).accessibilityIdentifier("sizing.long-labels")
                Toggle("Disabled", isOn: $disabled).accessibilityIdentifier("sizing.disabled")
            }.padding(.vertical, 12)
        }
    }

    private func controls(horizontal: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(control.rawValue).font(.headline).accessibilityAddTraits(.isHeader)
            SizingComparison(horizontal: horizontal) {
                SizingControlSample(kind: control, native: true, longLabels: longLabels)
                    .modifier(SizingOutline(visible: showBounds))
            } custom: {
                SizingControlSample(kind: control, native: false, longLabels: longLabels)
                    .modifier(SizingOutline(visible: showBounds))
            }
            .modifier(SizingEnvironment(choice: size))
            .disabled(disabled)
            .id(control)
            Text(
                "macOS minima: 20 / 24 / 28 / 32 pt. iOS minima: 44 / 44 / 44 / 52 pt. These are library policies, not every native control’s visible height."
            )
            .font(.caption).fixedSize(horizontal: false, vertical: true)
            Text(control.note).font(.caption).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func buttons(horizontal: Bool) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(button.rawValue).font(.headline).accessibilityAddTraits(.isHeader)
            Text(
                "Dynamic button styles use explicit size, padding and minimumSize. They do not adopt the Controls size selector."
            )
            .font(.caption).fixedSize(horizontal: false, vertical: true)
            SizingComparison(horizontal: horizontal) {
                SizingButtonSample(kind: button, native: true, longLabels: longLabels, showBounds: showBounds)
            } custom: {
                SizingButtonSample(kind: button, native: false, longLabels: longLabels, showBounds: showBounds)
            }
            .disabled(disabled)
            Text(button.note).font(.caption).fixedSize(horizontal: false, vertical: true)
        }
    }
}

private enum SizingChoice: String, CaseIterable, Identifiable {
    case mini = "Mini", small = "Small", regular = "Regular", large = "Large"
    var id: Self { self }

    @available(iOS 15, *)
    var controlSize: ControlSize {
        switch self {
        case .mini: return .mini
        case .small: return .small
        case .regular: return .regular
        case .large: return .large
        }
    }
}

private struct SizingEnvironment: ViewModifier {
    let choice: SizingChoice
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 15, *) { content.controlSize(choice.controlSize) } else { content }
    }
}

private struct SizingOutline: ViewModifier {
    let visible: Bool
    func body(content: Content) -> some View {
        content.overlay(
            Rectangle().stroke(
                Color.primary.opacity(visible ? 0.55 : 0), style: StrokeStyle(lineWidth: 1, dash: [4, 3])
            )
            .allowsHitTesting(false).accessibilityHidden(true)
        )
    }
}

private struct SizingComparison<Native: View, Custom: View>: View {
    let horizontal: Bool
    let native: Native
    let custom: Custom

    init(horizontal: Bool, @ViewBuilder native: () -> Native, @ViewBuilder custom: () -> Custom) {
        self.horizontal = horizontal
        self.native = native()
        self.custom = custom()
    }

    var body: some View {
        VStack(spacing: 20) {
            if horizontal {
                HStack(spacing: 40) {
                    caption("Native SwiftUI")
                    caption("Neumorphic")
                }
                HStack(alignment: .center, spacing: 40) {
                    native.frame(maxWidth: .infinity)
                    custom.frame(maxWidth: .infinity)
                }
                .frame(minHeight: 72)
            } else {
                caption("Native SwiftUI")
                native.frame(maxWidth: .infinity, minHeight: 72)
                caption("Neumorphic")
                custom.frame(maxWidth: .infinity, minHeight: 72)
            }
        }
        .padding(.vertical, 12)
    }

    private func caption(_ text: String) -> some View {
        Text(text).font(.caption).frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum SizingControl: String, CaseIterable, Identifiable {
    case textField = "TextField", secureField = "SecureField", slider = "Slider", toggle = "Switch"
    case stepper = "Stepper", picker = "Picker", menu = "Menu", checkbox = "Checkbox", radio = "Radio"
    case date = "DatePicker", disclosure = "Disclosure"
    var id: Self { self }
    var note: String {
        switch self {
        case .checkbox: return "Native reference: Toggle semantics. iOS has no native checkbox appearance."
        case .radio:
            return
                "Native reference: a segmented Picker. It demonstrates single selection, not matching radio geometry."
        case .date:
            return
                "DatePicker retains its native editor size plus decoration padding; it is not forced to the minimum height."
        case .toggle:
            return
                "Switch height is omitted so the surface follows the platform and control size. The outline includes layout margins."
        default:
            return
                "Native and Neumorphic controls have independent values. Use Long labels to check natural text wrapping."
        }
    }
}

private struct SizingControlSample: View {
    let kind: SizingControl
    let native: Bool
    let longLabels: Bool
    @State private var text = "Example"
    @State private var password = ""
    @State private var value = 0.5
    @State private var on = true
    @State private var count = 2
    @State private var selection = "One"
    @State private var expanded = false
    @State private var date = Date(timeIntervalSince1970: 1_789_344_000)

    private var title: String { longLabels ? "A longer label that can wrap as text grows" : "Enabled" }
    private func option(_ value: String) -> String { longLabels ? "\(value): a longer option" : value }

    @ViewBuilder var body: some View {
        switch kind {
        case .textField:
            if native {
                TextField("Name", text: $text).textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                NeumorphicTextField("Name", text: $text)
            }
        case .secureField:
            if native {
                SecureField("Password", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                NeumorphicTextField("Password", text: $password, secure: true)
            }
        case .slider:
            if native {
                Slider(value: $value).accessibilityLabel("Volume")
            } else {
                NeumorphicSlider(value: $value).accessibilityLabel("Volume")
            }
        case .toggle:
            if native {
                Toggle(title, isOn: $on).toggleStyle(SwitchToggleStyle()).labelsHidden()
            } else {
                Toggle(title, isOn: $on).switchToggleStyle(labelsHidden: true)
            }
        case .stepper:
            if native {
                Stepper("\(longLabels ? title : "Value"): \(count)", value: $count, in: 0...5)
            } else {
                NeumorphicStepper(longLabels ? title : "Value", value: $count, in: 0...5)
            }
        case .picker, .radio:
            if native {
                Picker("Choice", selection: $selection) {
                    Text(option("One")).tag("One")
                    Text(option("Two")).tag("Two")
                }.pickerStyle(SegmentedPickerStyle()).labelsHidden()
            } else if kind == .radio {
                NeumorphicRadio(longLabels ? title : "Two", value: "Two", selection: $selection)
            } else {
                NeumorphicPicker(selection: $selection, options: ["One", "Two"], label: option)
            }
        case .menu:
            if native {
                Menu(option(selection)) {
                    Button(option("One")) { selection = "One" }
                    Button(option("Two")) { selection = "Two" }
                }
            } else {
                NeumorphicMenu("Choice", selection: $selection, options: ["One", "Two"], label: option)
            }
        case .checkbox:
            if native { Toggle(title, isOn: $on) } else { NeumorphicCheckbox(title, isOn: $on) }
        case .date:
            if native {
                DatePicker("Date", selection: $date, displayedComponents: .date).datePickerStyle(
                    CompactDatePickerStyle())
            } else {
                NeumorphicDatePicker("Date", selection: $date, displayedComponents: .date)
            }
        case .disclosure:
            if native {
                DisclosureGroup(longLabels ? title : "Details", isExpanded: $expanded) { Text("Expanded content") }
            } else {
                NeumorphicDisclosureGroup(longLabels ? title : "Details", isExpanded: $expanded) {
                    Text("Expanded content")
                }
            }
        }
    }
}

private enum SizingButtonCase: String, CaseIterable, Identifiable {
    case platform = "Platform minimum", expanded = "Expanded target", padded = "Label plus padding", growing =
        "Growing text"
    var id: Self { self }
    var note: String {
        switch self {
        case .platform:
            return
                "size: 28 × 28, padding: 0. The label frame is 28 pt; the minimum layout is 28 × 28 on macOS and 44 × 44 on iOS."
        case .expanded:
            return
                "size: 28 × 28, padding: 0, minimumSize: 44 × 44. The small surface keeps a larger transparent interaction region."
        case .padded:
            return
                "size: 28 × 28, padding: 6. The surface is 40 × 40 before the platform minimum is applied. Shadows reserve no layout space."
        case .growing:
            return
                "softButtonStyle with padding: 6. Content grows naturally; fixed size applies to the label before padding and can truncate long text."
        }
    }
}

private struct SizingButtonSample: View {
    @Environment(\.neumorphicTheme) private var theme
    let kind: SizingButtonCase
    let native: Bool
    let longLabels: Bool
    let showBounds: Bool
    @State private var clicks = 0

    private var button: some View {
        Button {
            clicks += 1
        } label: {
            if kind == .growing {
                Text(longLabels ? "Continue with a longer action label that can wrap" : "Continue")
            } else {
                Image(systemName: "doc.on.doc")
            }
        }
        .accessibilityLabel(kind == .growing ? "Continue" : "Copy")
    }

    var body: some View {
        VStack(spacing: 16) {
            styledButton.modifier(SizingOutline(visible: showBounds)).frame(minHeight: 72)
            Text("Activations: \(clicks)").font(.caption)
        }
    }

    @ViewBuilder private var styledButton: some View {
        if native {
            button
        } else {
            switch kind {
            case .platform: button.fixedSizeSoftButtonStyle(Circle(), size: CGSize(width: 28, height: 28))
            case .expanded:
                button.fixedSizeSoftButtonStyle(
                    Circle(), size: CGSize(width: 28, height: 28), minimumSize: CGSize(width: 44, height: 44))
            case .padded:
                button.buttonStyle(
                    FixedSizeSoftDynamicButtonStyle(
                        Circle(), mainColor: theme.mainColor, textColor: theme.secondaryColor,
                        darkShadowColor: theme.darkShadowColor, lightShadowColor: theme.lightShadowColor,
                        pressedEffect: .hard, padding: 6, size: CGSize(width: 28, height: 28)
                    )
                )
            case .growing: button.softButtonStyle(Capsule(), padding: 6)
            }
        }
    }
}
