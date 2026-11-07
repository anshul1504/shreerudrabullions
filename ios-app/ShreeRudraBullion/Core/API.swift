import Foundation

/// All backend endpoints (website/api_urls.py), same set as Android's ApiService.
@MainActor
enum API {
    private static var client: APIClient { .shared }

    static func signupRequest(_ request: SignupRequest) async throws -> SignupResponse {
        try await client.send("auth/signup-request/", method: "POST", body: request, authorized: false)
    }

    static func signupStatus(mobile: String) async throws -> SignupStatusResponse {
        try await client.send("auth/signup-status/", query: [URLQueryItem(name: "mobile", value: mobile)], authorized: false)
    }

    static func login(_ request: LoginRequest) async throws -> LoginResponse {
        try await client.send("auth/login/", method: "POST", body: request, authorized: false)
    }

    static func forgotPassword(_ request: ForgotPasswordRequest) async throws -> MessageResponse {
        try await client.send("auth/forgot-password/", method: "POST", body: request, authorized: false)
    }

    static func profile() async throws -> AppUser {
        try await client.send("profile/")
    }

    static func profileUpdateRequest(_ request: ProfileUpdateRequest) async throws -> MessageResponse {
        try await client.send("profile/update-request/", method: "POST", body: request)
    }

    static func deleteAccount(_ request: DeleteAccountRequest) async throws -> MessageResponse {
        try await client.send("profile/delete-account/", method: "POST", body: request)
    }

    static func home() async throws -> HomeInfo {
        try await client.send("home/")
    }

    static func about() async throws -> AboutInfo {
        try await client.send("about/")
    }

    static func liveRates() async throws -> LiveRatesResponse {
        try await client.send("live-rates/")
    }

    static func products() async throws -> [ProductItem] {
        let response: ProductsResponse = try await client.send("products/")
        return response.products
    }

    static func productDetail(slug: String) async throws -> ProductDetail {
        let escaped = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? slug
        return try await client.send("products/\(escaped)/")
    }

    static func contact() async throws -> ContactInfo {
        try await client.send("contact/")
    }

    static func submitContact(_ request: ContactRequest) async throws -> MessageResponse {
        try await client.send("contact/", method: "POST", body: request)
    }

    static func privacyPolicy() async throws -> PrivacyPolicy {
        try await client.send("privacy-policy/", authorized: false)
    }
}
