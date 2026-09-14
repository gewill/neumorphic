#if os(macOS)
    import AppKit
    import SwiftUI
    import XCTest

    @testable import Neumorphic

    final class ButtonSizingTests: XCTestCase {
        @MainActor
        func testDefaultFixedButtonUsesMacMinimum() {
            for side: CGFloat in [10, 28, 30] {
                assertSize(
                    Button {
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .fixedSizeSoftButtonStyle(Circle(), size: CGSize(width: side, height: side)),
                    CGSize(width: max(28, side), height: max(28, side))
                )
            }
        }

        @MainActor
        func testExplicitMinimumAllowsCompactFixedButtons() {
            for side: CGFloat in [28, 30] {
                assertSize(
                    Button {
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .fixedSizeSoftButtonStyle(
                        Circle(), size: CGSize(width: side, height: side),
                        minimumSize: CGSize(width: 28, height: 28)),
                    CGSize(width: side, height: side)
                )
            }
            assertSize(
                Button {
                } label: {
                    Color.clear.frame(width: 10, height: 10)
                }
                .fixedSizeSoftButtonStyle(
                    Circle(), size: CGSize(width: 28, height: 30),
                    minimumSize: CGSize(width: 44, height: 44)),
                CGSize(width: 44, height: 44)
            )
        }

        @MainActor
        func testDynamicMinimumPreservesPaddingAndNaturalGrowth() {
            let button = Button {
            } label: {
                Color.clear.frame(width: 10, height: 12)
            }
            assertSize(button.softButtonStyle(Circle(), padding: 0), CGSize(width: 28, height: 28))
            assertSize(
                button.disabled(true).softButtonStyle(Circle(), padding: 0),
                CGSize(width: 28, height: 28)
            )
            assertSize(
                button.neumorphicThemedButtonStyle(Circle(), padding: 0),
                CGSize(width: 28, height: 28)
            )
            assertSize(
                button.neumorphicThemedButtonStyle(Circle(), role: .accent, padding: 0),
                CGSize(width: 28, height: 28)
            )
            assertSize(
                button.softButtonStyle(Circle(), padding: 0, minimumSize: CGSize(width: 28, height: 28)),
                CGSize(width: 28, height: 28)
            )
            assertSize(
                button.softButtonStyle(Circle(), padding: 4, minimumSize: .zero),
                CGSize(width: 18, height: 20)
            )
            // Exercise styling a composed view as well as a direct Button.
            assertSize(
                button.disabled(true)
                    .softButtonStyle(Circle(), padding: 0, minimumSize: CGSize(width: 28, height: 28)),
                CGSize(width: 28, height: 28)
            )
            let label = Text("Large text\non multiple lines").font(.system(size: 36)).fixedSize()
            let naturalSize = NSHostingView(rootView: label.padding(4)).fittingSize
            assertSize(
                Button {
                } label: {
                    label
                }
                .softButtonStyle(Capsule(), padding: 4, minimumSize: CGSize(width: 28, height: 28)),
                naturalSize
            )
        }

        @MainActor
        func testFixedInitializerAddsPaddingOutsideLabelSize() {
            let platformDefault = FixedSizeSoftDynamicButtonStyle(
                Circle(), mainColor: .gray, textColor: .black, darkShadowColor: .black,
                lightShadowColor: .white, pressedEffect: .hard, padding: 5,
                size: CGSize(width: 50, height: 20))
            let explicit = FixedSizeSoftDynamicButtonStyle(
                Circle(), mainColor: .gray, textColor: .black, darkShadowColor: .black,
                lightShadowColor: .white, pressedEffect: .hard, padding: 5,
                size: CGSize(width: 50, height: 20), minimumSize: CGSize(width: 28, height: 28))
            let button = Button("Copy") {}
            assertSize(button.buttonStyle(platformDefault), CGSize(width: 60, height: 30))
            assertSize(button.buttonStyle(explicit), CGSize(width: 60, height: 30))
        }

        @MainActor
        func testInvalidMinimumComponentsBehaveAsZero() {
            let button = Button {
            } label: {
                Color.clear.frame(width: 10, height: 12)
            }
            for minimum in [
                CGSize(width: -1, height: -20),
                CGSize(width: CGFloat.nan, height: CGFloat.infinity),
            ] {
                assertSize(
                    button.softButtonStyle(Rectangle(), padding: 0, minimumSize: minimum),
                    CGSize(width: 10, height: 12)
                )
                assertSize(
                    button.fixedSizeSoftButtonStyle(size: CGSize(width: 10, height: 12), minimumSize: minimum),
                    CGSize(width: 10, height: 12)
                )
            }
        }

        @MainActor
        func testTransparentCornersActivateOnlyEnabledButtons() {
            _ = NSApplication.shared
            for minimumSize: CGSize? in [nil, CGSize(width: 44, height: 44)] {
                let side: CGFloat = minimumSize?.width ?? 28
                for fixed in [false, true] {
                    for enabled in [true, false] {
                        var activations = 0
                        let button = Button {
                            activations += 1
                        } label: {
                            Color.clear.frame(width: 10, height: 10)
                        }
                        let view: AnyView
                        if minimumSize == nil {
                            if fixed {
                                view = AnyView(
                                    button.fixedSizeSoftButtonStyle(Circle(), size: CGSize(width: 10, height: 10)))
                            } else {
                                view = AnyView(button.softButtonStyle(Circle(), padding: 0))
                            }
                        } else if fixed {
                            view = AnyView(
                                button.fixedSizeSoftButtonStyle(
                                    Circle(), size: CGSize(width: 10, height: 10),
                                    minimumSize: CGSize(width: 44, height: 44)))
                        } else {
                            view = AnyView(
                                button.softButtonStyle(
                                    Circle(), padding: 0, minimumSize: CGSize(width: 44, height: 44)))
                        }
                        let host = NSHostingView(rootView: view.disabled(!enabled).fixedSize())
                        let window = NSWindow(
                            contentRect: NSRect(x: 0, y: 0, width: side, height: side),
                            styleMask: .borderless, backing: .buffered, defer: false)
                        window.isReleasedWhenClosed = false
                        window.contentView = host
                        window.orderFront(nil)
                        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
                        host.layoutSubtreeIfNeeded()
                        defer { window.close() }

                        // All four corners are outside the small circular surface. Releasing
                        // at the same edge also catches a hit region that shrinks on press.
                        for point in [
                            NSPoint(x: 0.25, y: 0.25), NSPoint(x: side - 0.25, y: 0.25),
                            NSPoint(x: 0.25, y: side - 0.25), NSPoint(x: side - 0.25, y: side - 0.25),
                        ] {
                            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                                let event = NSEvent.mouseEvent(
                                    with: type, location: point, modifierFlags: [],
                                    timestamp: ProcessInfo.processInfo.systemUptime,
                                    windowNumber: window.windowNumber, context: nil,
                                    eventNumber: 0, clickCount: 1, pressure: type == .leftMouseDown ? 1 : 0)!
                                window.sendEvent(event)
                                RunLoop.current.run(until: Date().addingTimeInterval(0.01))
                                XCTAssertEqual(host.fittingSize, CGSize(width: side, height: side))
                            }
                        }
                        XCTAssertEqual(
                            activations, enabled ? 4 : 0, "minimum: \(side), fixed: \(fixed), enabled: \(enabled)")
                    }
                }
            }
        }

        @MainActor
        private func assertSize<V: View>(
            _ view: V, _ expected: CGSize, file: StaticString = #filePath, line: UInt = #line
        ) {
            let actual = NSHostingView(rootView: view.fixedSize()).fittingSize
            XCTAssertEqual(actual.width, expected.width, accuracy: 0.01, file: file, line: line)
            XCTAssertEqual(actual.height, expected.height, accuracy: 0.01, file: file, line: line)
        }
    }
#endif
