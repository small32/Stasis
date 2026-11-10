import SwiftUI

@main
struct StasisApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppLanguage.applyAtLaunch()
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
