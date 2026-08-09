import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExampleShowcaseView()
                .tabItem { Label("Examples", systemImage: "square.grid.2x2") }
            ExampleSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
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
