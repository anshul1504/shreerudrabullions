import Foundation

enum AppConfig {
    /// Read from Info.plist (`APIBaseURL` = `$(API_BASE_URL)` build setting), always ending with a slash.
    static let apiBaseURL: URL = {
        let raw = (Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let value = raw.isEmpty || raw.hasPrefix("$(") ? "https://shreerudrabullion.com/api/v1/" : raw
        return URL(string: value.hasSuffix("/") ? value : value + "/")!
    }()

    static let isFirebaseConfigured: Bool =
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
}
