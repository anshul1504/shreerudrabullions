import Foundation
import Observation
import Security

/// Mirrors SessionStore.kt. Tokens live in the Keychain; profile basics in UserDefaults.
@MainActor
@Observable
final class SessionStore {
    static let shared = SessionStore()

    static let signedOutMessageText = "You have been signed out. Please sign in again to continue."

    private(set) var accessToken = ""
    private(set) var refreshToken = ""
    private(set) var userName = ""
    private(set) var mobile = ""
    private(set) var pendingSignupMobile = ""
    private(set) var fcmToken = ""

    /// Non-empty while the "Sign in required" screen should be shown.
    var signedOutMessage = ""

    var authorization: String { "Bearer \(accessToken)" }
    var isLoggedIn: Bool { !accessToken.isEmpty }

    private let defaults: UserDefaults
    private let keychain: KeychainStore

    private enum Key {
        static let access = "access_token"
        static let refresh = "refresh_token"
        static let name = "user_name"
        static let mobile = "mobile"
        static let pendingSignupMobile = "pending_signup_mobile"
        static let fcmToken = "fcm_token"
        static let installed = "has_launched_before"
    }

    init(defaults: UserDefaults = .standard, keychain: KeychainStore = KeychainStore(service: "com.shreerudra.bullion.session")) {
        self.defaults = defaults
        self.keychain = keychain
        // Keychain items survive an uninstall; start fresh on a new install.
        if !defaults.bool(forKey: Key.installed) {
            keychain.removeAll()
            defaults.set(true, forKey: Key.installed)
        }
        accessToken = keychain.string(for: Key.access)
        refreshToken = keychain.string(for: Key.refresh)
        userName = defaults.string(forKey: Key.name) ?? ""
        mobile = defaults.string(forKey: Key.mobile) ?? ""
        pendingSignupMobile = defaults.string(forKey: Key.pendingSignupMobile) ?? ""
        fcmToken = defaults.string(forKey: Key.fcmToken) ?? ""
    }

    func setSession(_ response: LoginResponse) {
        accessToken = response.access
        refreshToken = response.refresh
        userName = response.user.name
        mobile = response.user.mobile
        pendingSignupMobile = ""
        signedOutMessage = ""
        save()
    }

    func updateAccessToken(_ token: String) {
        accessToken = token
        save()
    }

    func setPendingSignup(_ mobileNumber: String) {
        pendingSignupMobile = mobileNumber
        save()
    }

    func updateFcmToken(_ token: String) {
        fcmToken = token
        save()
    }

    /// Logout, account deletion, or an expired session: clear and show the signed-out screen.
    func signOut() {
        clear()
        signedOutMessage = Self.signedOutMessageText
    }

    func expireSession() {
        guard isLoggedIn else { return }
        signOut()
    }

    func clear() {
        accessToken = ""
        refreshToken = ""
        userName = ""
        mobile = ""
        pendingSignupMobile = ""
        // The FCM token belongs to the device, not the user, so it is kept for the next signup.
        save()
    }

    private func save() {
        keychain.set(accessToken, for: Key.access)
        keychain.set(refreshToken, for: Key.refresh)
        defaults.set(userName, forKey: Key.name)
        defaults.set(mobile, forKey: Key.mobile)
        defaults.set(pendingSignupMobile, forKey: Key.pendingSignupMobile)
        defaults.set(fcmToken, forKey: Key.fcmToken)
    }
}

struct KeychainStore {
    let service: String

    func string(for key: String) -> String {
        var query = baseQuery(key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    func set(_ value: String, for key: String) {
        let query = baseQuery(key)
        guard !value.isEmpty else {
            SecItemDelete(query as CFDictionary)
            return
        }
        let data = Data(value.utf8)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecItemNotFound {
            var insert = query
            insert.merge(attributes) { _, new in new }
            SecItemAdd(insert as CFDictionary, nil)
        }
    }

    func removeAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func baseQuery(_ key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
    }
}
