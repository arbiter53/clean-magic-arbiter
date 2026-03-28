import SwiftUI

@main
struct cleanerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 780, height: 560)
        .commands {
            CommandGroup(replacing: .newItem) {}  // hide File > New Window
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") {}
                    .disabled(true)
            }
        }
    }
}
