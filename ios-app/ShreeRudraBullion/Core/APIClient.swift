import Foundation

enum APIError: Error {
    case http(status: Int, body: Data)
    case network(URLError)
    case decoding(Error)
    case invalidResponse

    var statusCode: Int? {
        if case .http(let status, _) = self { return status }
        return nil
    }

    var isUnauthorized: Bool { statusCode == 401 }
}

/// URLSession wrapper with the same behaviour as the Android Retrofit/OkHttp setup:
/// JWT bearer auth, a single-flight token refresh on 401, and session expiry when refresh fails.
@MainActor
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var refreshTask: Task<Bool, Never>?

    init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            configuration.timeoutIntervalForResource = 30
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            self.session = URLSession(configuration: configuration)
        }
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func send<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        authorized: Bool = true
    ) async throws -> T {
        var request = try makeRequest(path, method: method, query: query, body: body)
        if authorized {
            request.setValue(SessionStore.shared.authorization, forHTTPHeaderField: "Authorization")
        }

        var (data, status) = try await perform(request)

        if status == 401 && authorized {
            let sentToken = request.value(forHTTPHeaderField: "Authorization")
            let refreshed: Bool
            if sentToken != SessionStore.shared.authorization && SessionStore.shared.isLoggedIn {
                // Another request already refreshed the token while this one was in flight.
                refreshed = true
            } else {
                refreshed = await refreshAccessToken()
            }
            if refreshed {
                request.setValue(SessionStore.shared.authorization, forHTTPHeaderField: "Authorization")
                (data, status) = try await perform(request)
            }
            if status == 401 {
                SessionStore.shared.expireSession()
                throw APIError.http(status: status, body: data)
            }
        }

        guard (200..<300).contains(status) else {
            throw APIError.http(status: status, body: data)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeRequest(_ path: String, method: String, query: [URLQueryItem], body: (any Encodable)?) throws -> URLRequest {
        guard var components = URLComponents(url: AppConfig.apiBaseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }
        // appendingPathComponent drops the trailing slash Django expects.
        if path.hasSuffix("/") && !components.path.hasSuffix("/") {
            components.path += "/"
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(body)
        }
        return request
    }

    private func perform(_ request: URLRequest) async throws -> (Data, Int) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            return (data, http.statusCode)
        } catch let error as URLError {
            throw APIError.network(error)
        }
    }

    private func refreshAccessToken() async -> Bool {
        if let refreshTask {
            return await refreshTask.value
        }
        let refreshToken = SessionStore.shared.refreshToken
        guard !refreshToken.isEmpty else { return false }

        let task = Task<Bool, Never> {
            do {
                let request = try makeRequest("auth/refresh/", method: "POST", query: [], body: TokenRefreshRequest(refresh: refreshToken))
                let (data, status) = try await perform(request)
                guard (200..<300).contains(status) else { return false }
                let response = try decoder.decode(TokenRefreshResponse.self, from: data)
                guard !response.access.isEmpty else { return false }
                SessionStore.shared.updateAccessToken(response.access)
                return true
            } catch {
                return false
            }
        }
        refreshTask = task
        let result = await task.value
        refreshTask = nil
        return result
    }
}

// MARK: - Error messages (same rules as apiMessage / networkMessage on Android)

enum ErrorMessage {
    /// Extracts the Django REST Framework message from an error body: `detail` first,
    /// then the first field-error list, then the first string value.
    static func api(_ error: Error, fallback: String) -> String {
        guard case APIError.http(_, let data)? = error as? APIError,
              let body = String(data: data, encoding: .utf8),
              !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            if case APIError.network? = error as? APIError {
                return network(error, fallback: fallback)
            }
            return fallback
        }
        return parseBody(body) ?? fallback
    }

    static func parseBody(_ body: String) -> String? {
        if let match = body.firstMatch(of: /"detail"\s*:\s*"([^"]+)"/) {
            return String(match.1)
        }
        if let match = body.firstMatch(of: /\[\s*"([^"]+)"\s*]/) {
            return String(match.1)
        }
        if let match = body.firstMatch(of: /"[^"]+"\s*:\s*"([^"]+)"/) {
            return String(match.1)
        }
        return nil
    }

    static func network(_ error: Error, fallback: String) -> String {
        switch error as? APIError {
        case .network(let urlError):
            switch urlError.code {
            case .timedOut:
                return "Connection timed out. Please check your internet connection and try again."
            case .notConnectedToInternet, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .networkConnectionLost:
                return "Server is not reachable. Please check your network connection."
            default:
                return fallback
            }
        case .http(let status, _):
            return status == 401 ? "Your session has expired. Please sign in again." : fallback
        default:
            return fallback
        }
    }
}
