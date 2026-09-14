import SwiftUI
import XCTest

@testable import Neumorphic

final class ControlMetricsTests: XCTestCase {
    func testSliderMappingUsesEachSizeThumbGeometry() {
        for size in [NeumorphicControlMetrics.Size.mini, .small, .regular, .large] {
            let thumb = Double(NeumorphicControlMetrics(size: size).sliderThumbDiameter)
            XCTAssertEqual(NeumorphicSliderMath.fraction(at: thumb / 2, width: 240, thumbWidth: thumb), 0)
            XCTAssertEqual(NeumorphicSliderMath.fraction(at: 120, width: 240, thumbWidth: thumb), 0.5)
            XCTAssertEqual(NeumorphicSliderMath.fraction(at: 240 - thumb / 2, width: 240, thumbWidth: thumb), 1)
        }
    }

    func testSwitchExplicitHeightPreservesProportionsAndRejectsInvalidValues() {
        let geometry = NeumorphicSwitchGeometry(height: 30)
        XCTAssertEqual(geometry.width, 50)
        XCTAssertEqual(geometry.height, 30)
        XCTAssertEqual(geometry.thumbDiameter, 20)
        XCTAssertEqual(geometry.travel, 10)
        for height: CGFloat in [-1, 0, .infinity, .nan] {
            XCTAssertEqual(NeumorphicSwitchGeometry(height: height).height, 1)
        }
    }

    func testDefaultTargetsFollowPlatformAndIncreaseWithSize() {
        let sizes: [NeumorphicControlMetrics.Size] = [.mini, .small, .regular, .large]
        let dimensions = sizes.map { NeumorphicControlMetrics(size: $0).minimumDimension }
        #if os(macOS)
            XCTAssertEqual(dimensions, [20, 24, 28, 32])
        #else
            XCTAssertEqual(dimensions, [44, 44, 44, 52])
        #endif
    }
}

#if os(macOS)
    import AppKit

    final class ControlSizingTests: XCTestCase {
        @MainActor
        func testRegularControlsDoNotStackMinimumLabelSizeAndPadding() {
            let views: [AnyView] = [
                AnyView(NeumorphicTextField("Name", text: .constant("Example"))),
                AnyView(NeumorphicTextField("Password", text: .constant("Example"), secure: true)),
                AnyView(NeumorphicSlider(value: .constant(0.5))),
                AnyView(NeumorphicStepper(value: .constant(2))),
                AnyView(NeumorphicPicker(selection: .constant("One"), options: ["One", "Two"])),
                AnyView(NeumorphicMenu("Mode", selection: .constant("One"), options: ["One", "Two"])),
                AnyView(NeumorphicCheckbox("Enabled", isOn: .constant(true))),
                AnyView(NeumorphicRadio("One", value: "One", selection: .constant("One"))),
                AnyView(NeumorphicDisclosureGroup("Details", isExpanded: .constant(false)) { Text("Content") }),
            ]
            for view in views {
                XCTAssertEqual(measure(view.controlSize(.regular).frame(width: 240)).height, 28, accuracy: 0.5)
            }
        }

        @MainActor
        func testControlSizeUpdatesSwitchAndSliderGeometry() {
            for (size, width, height) in [
                (ControlSize.mini, 36.0, 20.0), (.small, 44.0, 24.0),
                (.regular, 54.0, 28.0), (.large, 64.0, 32.0),
            ] {
                for view in [
                    AnyView(Toggle("Enabled", isOn: .constant(true)).switchToggleStyle(labelsHidden: true)),
                    AnyView(Toggle("Enabled", isOn: .constant(true)).softSwitchToggleStyle(labelsHidden: true)),
                    AnyView(Toggle("Enabled", isOn: .constant(true)).neumorphicThemedSwitchStyle(labelsHidden: true)),
                ] {
                    let actual = measure(view.controlSize(size))
                    XCTAssertEqual(actual.width, width, accuracy: 0.5)
                    XCTAssertEqual(actual.height, height, accuracy: 0.5)
                }
                let slider = NeumorphicSlider(value: .constant(0.5)).controlSize(size).frame(width: 240)
                XCTAssertEqual(measure(slider).height, height, accuracy: 0.5)
            }
        }

        @MainActor
        func testLargeAndMultilineTextCanGrowPastMinimum() {
            let text = NeumorphicTextField("Name", text: .constant("Example")).font(.system(size: 48))
            XCTAssertGreaterThan(measure(text.frame(width: 300)).height, 28)
            let picker = NeumorphicPicker(selection: .constant("One\nTwo\nThree"), options: ["One\nTwo\nThree"])
            XCTAssertGreaterThan(measure(picker.frame(width: 100)).height, 28)
        }

        @MainActor
        func testFullToggleBoundsRespondAndDisabledControlsDoNot() {
            _ = NSApplication.shared
            for kind in 0..<6 {
                for enabled in [true, false] {
                    var changes = 0
                    let binding = Binding(get: { false }, set: { _ in changes += 1 })
                    let view: AnyView
                    switch kind {
                    case 0: view = AnyView(Toggle("Enabled", isOn: binding).switchToggleStyle(labelsHidden: true))
                    case 1:
                        view = AnyView(
                            Toggle("Enabled", isOn: binding).switchToggleStyle(labelsHidden: true, height: 20))
                    case 2: view = AnyView(NeumorphicCheckbox("Enabled", isOn: binding))
                    case 3: view = AnyView(NeumorphicRadio("Enabled", value: true, selection: binding))
                    case 4: view = AnyView(Toggle("Enabled", isOn: binding).softToggleStyle(Capsule(), padding: 0))
                    default:
                        view = AnyView(NeumorphicDisclosureGroup("Details", isExpanded: binding) { Text("Content") })
                    }
                    withWindow(view.disabled(!enabled)) { host, window in
                        let bounds = host.bounds
                        for point in [
                            CGPoint(x: bounds.midX, y: bounds.midY),
                            CGPoint(x: bounds.midX, y: 1), CGPoint(x: bounds.midX, y: bounds.height - 1),
                            CGPoint(x: 1, y: bounds.midY), CGPoint(x: bounds.width - 1, y: bounds.midY),
                        ] {
                            click(point, host: host, window: window)
                        }
                    }
                    XCTAssertEqual(changes, enabled ? 5 : 0, "kind: \(kind), enabled: \(enabled)")
                }
            }
        }

        @MainActor
        func testLegacyTextFieldGuttersFocusAndPreserveEditingAndDisabledState() {
            _ = NSApplication.shared
            for secure in [false, true] {
                for enabled in [true, false] {
                    var text = "Example"
                    let binding = Binding(get: { text }, set: { text = $0 })
                    let input = Group {
                        if secure { SecureField("Name", text: binding) } else { TextField("Name", text: binding) }
                    }
                    .textFieldStyle(.plain).padding(10)
                    let view = NeumorphicLegacyTextFieldFocus(content: input).frame(width: 240).disabled(!enabled)
                    withWindow(view) { host, window in
                        for point in [
                            CGPoint(x: 120, y: 1), CGPoint(x: 120, y: host.bounds.height - 1),
                            CGPoint(x: 1, y: host.bounds.midY), CGPoint(x: 239, y: host.bounds.midY),
                        ] {
                            window.makeFirstResponder(nil)
                            let location = host.convert(point, to: nil)
                            @MainActor func event(_ type: NSEvent.EventType) -> NSEvent {
                                NSEvent.mouseEvent(
                                    with: type, location: location, modifierFlags: [],
                                    timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
                                    context: nil, eventNumber: 0, clickCount: 1, pressure: 0)!
                            }
                            // Native text controls may track the release inside mouseDown.
                            NSApp.postEvent(event(.leftMouseUp), atStart: true)
                            window.sendEvent(event(.leftMouseDown))
                            if let up = NSApp.nextEvent(
                                matching: .leftMouseUp, until: .distantPast, inMode: .default, dequeue: true)
                            {
                                window.sendEvent(up)
                            }
                            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
                            XCTAssertEqual(window.firstResponder is NSTextView, enabled)
                        }
                        if enabled, let editor = window.firstResponder as? NSTextView {
                            editor.insertText(
                                "Updated", replacementRange: NSRange(location: 0, length: editor.string.utf16.count))
                            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
                            XCTAssertEqual(text, "Updated")
                        }
                    }
                }
            }
        }

        @MainActor
        private func measure<V: View>(_ view: V) -> CGSize {
            NSHostingView(rootView: view.fixedSize()).fittingSize
        }

        @MainActor
        private func withWindow<V: View>(_ view: V, run: (NSHostingView<V>, NSWindow) -> Void) {
            let host = NSHostingView(rootView: view)
            let window = NSWindow(
                contentRect: NSRect(origin: .zero, size: host.fittingSize), styleMask: .borderless, backing: .buffered,
                defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = host
            window.orderFront(nil)
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            host.layoutSubtreeIfNeeded()
            defer { window.close() }
            run(host, window)
        }

        @MainActor
        private func click<V: View>(_ point: CGPoint, host: NSHostingView<V>, window: NSWindow) {
            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                let event = NSEvent.mouseEvent(
                    with: type, location: host.convert(point, to: nil), modifierFlags: [],
                    timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber, context: nil,
                    eventNumber: 0, clickCount: 1, pressure: type == .leftMouseDown ? 1 : 0)!
                window.sendEvent(event)
                RunLoop.current.run(until: Date().addingTimeInterval(0.01))
            }
        }
    }
#endif
