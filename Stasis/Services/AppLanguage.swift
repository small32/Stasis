import AppKit
import Defaults
import Foundation

enum AppLanguage: String, Defaults.Serializable, CaseIterable, Identifiable {
    case system
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: String(localized: "Follow System")
        case .simplifiedChinese: "简体中文"
        case .english: "English"
        }
    }

    private static let appleLanguagesKey = "AppleLanguages"

    // Bundle.main caches preferredLocalizations on the first lookup, so AppleLanguages
    // must be in the app's defaults domain before any localized string is read at launch.
    static func applyAtLaunch() {
        apply(Defaults[.appLanguage])
    }

    static func apply(_ language: AppLanguage) {
        if language == .system {
            UserDefaults.standard.removeObject(forKey: appleLanguagesKey)
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: appleLanguagesKey)
        }
    }

    @MainActor
    static func relaunch() async throws {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.activates = true
        _ = try await NSWorkspace.shared.openApplication(
            at: Bundle.main.bundleURL,
            configuration: configuration
        )
        NSApplication.shared.terminate(nil)
    }
}
