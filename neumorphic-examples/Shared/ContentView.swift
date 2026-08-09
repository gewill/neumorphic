import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExampleShowcaseView()
                .tabItem {
                    ExampleTabLabel("Examples", systemImage: "square.grid.2x2")
                }
            ExampleSettingsView()
                .tabItem {
                    ExampleTabLabel("Settings", systemImage: "gearshape")
                }
        }
    }
}

private struct ExampleTabLabel: View {
    let title: String
    let systemImage: String

    init(_ title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 14.0, macOS 11.0, *) {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
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
