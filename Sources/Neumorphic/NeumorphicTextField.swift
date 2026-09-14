import SwiftUI

/// A text field with a soft inset surface and focus treatment.
public struct NeumorphicTextField: View {
    private let title: String
    @Binding private var text: String
    private let isSecure: Bool

    /// Creates a text input on a soft inset surface.
    ///
    /// - Parameters:
    ///   - title: The prompt shown when the field is empty.
    ///   - text: A binding to the editable text.
    ///   - secure: A Boolean value that uses a secure field when `true`.
    public init(_ title: String, text: Binding<String>, secure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = secure
    }

    /// The rendered text field.
    public var body: some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            NeumorphicFocusableTextField(content: field)
        } else {
            NeumorphicLegacyTextFieldFocus(content: field.modifier(NeumorphicTextFieldSurface()))
                .frame(maxWidth: .infinity)
        }
    }

    private var field: some View {
        Group {
            if isSecure { SecureField(title, text: $text) } else { TextField(title, text: $text) }
        }
        .textFieldStyle(PlainTextFieldStyle())
    }
}

private struct NeumorphicTextFieldSurface: ViewModifier {
    @Environment(\.neumorphicTheme) private var theme
    @NeumorphicControlSizing private var metrics

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .frame(minHeight: metrics.minimumDimension)
            .foregroundColor(theme.secondaryColor)
            .background(
                RoundedRectangle(cornerRadius: metrics.cornerRadius)
                    .fill(theme.mainColor)
                    .softInnerShadow(
                        RoundedRectangle(cornerRadius: metrics.cornerRadius),
                        darkShadow: theme.darkShadowColor, lightShadow: theme.lightShadowColor,
                        spread: 0.55, radius: 3
                    )
            )
    }
}

@available(iOS 15.0, macOS 12.0, *)
private struct NeumorphicFocusableTextField<Content: View>: View {
    let content: Content
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        content
            .focused($isFocused)
            .modifier(NeumorphicTextFieldSurface())
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    if isEnabled { isFocused = true }
                }
            )
    }
}

struct NeumorphicLegacyTextFieldFocus<Content: View>: View {
    let content: Content

    var body: some View {
        NeumorphicLegacyTextFieldContainer(content: content)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// Before FocusState, host only this field so gutter clicks can join its native responder chain.
// Native text hits pass through unchanged, preserving selection, menus, and keyboard navigation.
#if os(macOS)
    import AppKit

    struct NeumorphicLegacyTextFieldContainer<Content: View>: NSViewRepresentable {
        let content: Content

        func makeNSView(context: Context) -> NeumorphicFieldFocusHost<Content> {
            NeumorphicFieldFocusHost(content: content)
        }

        func updateNSView(_ view: NeumorphicFieldFocusHost<Content>, context: Context) {
            view.host.rootView = AnyView(content.environment(\.self, context.environment))
            view.isEnabled = context.environment.isEnabled
            view.invalidateIntrinsicContentSize()
        }
    }

    final class NeumorphicFieldFocusHost<Content: View>: NSView {
        let host: NSHostingView<AnyView>
        var isEnabled = true

        init(content: Content) {
            host = NSHostingView(rootView: AnyView(content.environment(\.self, EnvironmentValues())))
            super.init(frame: .zero)
            host.translatesAutoresizingMaskIntoConstraints = false
            addSubview(host)
            NSLayoutConstraint.activate([
                host.leadingAnchor.constraint(equalTo: leadingAnchor),
                host.trailingAnchor.constraint(equalTo: trailingAnchor),
                host.topAnchor.constraint(equalTo: topAnchor),
                host.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        required init?(coder: NSCoder) { nil }

        override var intrinsicContentSize: NSSize { host.fittingSize }

        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { isEnabled }

        override func hitTest(_ point: NSPoint) -> NSView? {
            guard let hit = super.hitTest(point) else { return nil }
            var ancestor: NSView? = hit
            while let view = ancestor, view !== self {
                if view is NSTextField || view is NSTextView { return hit }
                ancestor = view.superview
            }
            return self
        }

        override func mouseDown(with event: NSEvent) {
            guard isEnabled, let field = textField(in: host) else { return }
            if field.currentEditor() == nil { field.selectText(nil) }
        }

        private func textField(in view: NSView) -> NSTextField? {
            if let field = view as? NSTextField { return field }
            return view.subviews.lazy.compactMap { self.textField(in: $0) }.first
        }
    }
#elseif os(iOS)
    import UIKit

    struct NeumorphicLegacyTextFieldContainer<Content: View>: UIViewControllerRepresentable {
        let content: Content

        func makeUIViewController(context: Context) -> NeumorphicFieldFocusController<Content> {
            NeumorphicFieldFocusController(content: content)
        }

        func updateUIViewController(_ controller: NeumorphicFieldFocusController<Content>, context: Context) {
            let view = controller.fieldView
            view.host.rootView = AnyView(content.environment(\.self, context.environment))
            view.isEnabled = context.environment.isEnabled
            view.invalidateIntrinsicContentSize()
            controller.preferredContentSize = view.intrinsicContentSize
        }
    }

    final class NeumorphicFieldFocusController<Content: View>: UIViewController {
        let fieldView: NeumorphicFieldFocusHost<Content>

        init(content: Content) {
            fieldView = NeumorphicFieldFocusHost(content: content)
            super.init(nibName: nil, bundle: nil)
            addChild(fieldView.host)
            view = fieldView
            fieldView.host.didMove(toParent: self)
        }

        required init?(coder: NSCoder) { nil }
    }

    final class NeumorphicFieldFocusHost<Content: View>: UIView {
        let host: UIHostingController<AnyView>
        var isEnabled = true

        init(content: Content) {
            host = UIHostingController(rootView: AnyView(content.environment(\.self, EnvironmentValues())))
            super.init(frame: .zero)
            host.view.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(host.view)
            NSLayoutConstraint.activate([
                host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                host.view.topAnchor.constraint(equalTo: topAnchor),
                host.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        required init?(coder: NSCoder) { nil }

        override var intrinsicContentSize: CGSize {
            host.sizeThatFits(
                in: CGSize(
                    width: bounds.width > 0 ? bounds.width : UIView.layoutFittingExpandedSize.width,
                    height: UIView.layoutFittingExpandedSize.height))
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hit = super.hitTest(point, with: event) else { return nil }
            var ancestor: UIView? = hit
            while let view = ancestor, view !== self {
                if view is UITextField { return hit }
                ancestor = view.superview
            }
            return self
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard isEnabled else { return }
            textField(in: host.view)?.becomeFirstResponder()
        }

        private func textField(in view: UIView) -> UITextField? {
            if let field = view as? UITextField { return field }
            return view.subviews.lazy.compactMap { self.textField(in: $0) }.first
        }
    }
#endif
