import SwiftUI

struct ContentView: View {
    @State private var selectedTab = ExampleSizingLaunch.section == nil ? "examples" : "sizing"

    var body: some View {
        TabView(selection: $selectedTab) {
            ExampleShowcaseView()
                .tag("examples")
                .tabItem {
                    ExampleTabLabel("Examples", systemImage: "square.grid.2x2")
                }
            ExampleSizingView()
                .tag("sizing")
                .tabItem {
                    ExampleTabLabel("Sizing", systemImage: "ruler")
                }
            ExampleSettingsView()
                .tag("settings")
                .tabItem {
                    ExampleTabLabel("Settings", systemImage: "gearshape")
                }
        }
        .modifier(ExampleCaptureEnvironment())
    }
}

private struct ExampleTabLabel: View {
    let title: String
    let systemImage: String

    init(_ title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        Label(title, systemImage: systemImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.colorScheme, .light)
            ContentView().environment(\.colorScheme, .dark)
        }
    }
}

private struct ExampleCaptureEnvironment: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if ExampleSizingLaunch.value("--sizing-capture") == "yes" {
            content
                .environment(\.colorScheme, .light)
                .environment(\.locale, Locale(identifier: "en_US"))
                .environment(\.sizeCategory, .large)
        } else {
            content
        }
    }
}
