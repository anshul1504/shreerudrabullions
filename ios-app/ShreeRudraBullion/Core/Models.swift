import Foundation

// Mirrors android-app/.../data/ApiModels.kt. JSON keys are snake_case and are
// converted automatically by APIClient (convertFromSnakeCase / convertToSnakeCase).

// MARK: - Lenient decoding

protocol DecodableDefault {
    associatedtype Value: Decodable & Sendable
    static var defaultValue: Value { get }
}

enum DefaultEmptyString: DecodableDefault {
    static var defaultValue: String { "" }
}

enum DefaultTrue: DecodableDefault {
    static var defaultValue: Bool { true }
}

enum DefaultFalse: DecodableDefault {
    static var defaultValue: Bool { false }
}

enum DefaultZero: DecodableDefault {
    static var defaultValue: Int { 0 }
}

enum DefaultEmptyList<Element: Decodable & Sendable>: DecodableDefault {
    static var defaultValue: [Element] { [] }
}

/// Falls back to a default when the key is missing, null, or has an unexpected type,
/// the same way Gson leaves Kotlin defaults in place on Android.
@propertyWrapper
struct Default<Source: DecodableDefault>: Decodable, Sendable {
    var wrappedValue: Source.Value

    init() {
        wrappedValue = Source.defaultValue
    }

    init(wrappedValue: Source.Value) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(Source.Value.self)) ?? Source.defaultValue
    }
}

extension KeyedDecodingContainer {
    func decode<S>(_ type: Default<S>.Type, forKey key: Key) throws -> Default<S> {
        try decodeIfPresent(type, forKey: key) ?? Default()
    }
}

typealias DString = Default<DefaultEmptyString>

// MARK: - Auth

struct SignupRequest: Encodable, Sendable {
    let name: String
    let mobile: String
    let password: String
    let confirmPassword: String
    var message: String = ""
    var fcmToken: String = ""
}

struct SignupResponse: Decodable, Sendable {
    @Default<DefaultZero> var id: Int
    @DString var status: String
    @DString var message: String
}

struct SignupStatusResponse: Decodable, Sendable {
    @DString var mobile: String
    @DString var status: String
    @DString var message: String
}

struct LoginRequest: Encodable, Sendable {
    let mobile: String
    let password: String
}

struct LoginResponse: Decodable, Sendable {
    let access: String
    let refresh: String
    let user: AppUser
}

struct TokenRefreshRequest: Encodable, Sendable {
    let refresh: String
}

struct TokenRefreshResponse: Decodable, Sendable {
    let access: String
}

struct ForgotPasswordRequest: Encodable, Sendable {
    let mobile: String
    let password: String
    let confirmPassword: String
}

struct DeleteAccountRequest: Encodable, Sendable {
    let currentPassword: String
    var reason: String = ""
}

struct MessageResponse: Decodable, Sendable {
    @DString var message: String
}

struct ContactRequest: Encodable, Sendable {
    let name: String
    let email: String
    let phone: String
    var enquiryType: String = "gold_bullion"
    var subject: String = "App enquiry"
    let message: String
}

struct ProfileUpdateRequest: Encodable, Sendable {
    let name: String
    let mobile: String
    var city: String = ""
    var message: String = ""
}

struct AppUser: Decodable, Sendable {
    @Default<DefaultZero> var id: Int
    @DString var name: String
    @DString var mobile: String
    @DString var profileImage: String
}

// MARK: - Live rates

struct LiveRatesResponse: Decodable, Sendable {
    @Default<DefaultFalse> var marketOpen: Bool
    @DString var rateSource: String
    @DString var rateUpdated: String
    @Default<DefaultEmptyList<RateRow>> var rows: [RateRow]
}

struct RateRow: Decodable, Sendable, Identifiable {
    @DString var key: String
    @DString var label: String
    @DString var unit: String
    @DString var buy: String
    @DString var sell: String

    var id: String { key.isEmpty ? label : key }
}

// MARK: - Products

struct ProductsResponse: Decodable, Sendable {
    @Default<DefaultEmptyList<ProductItem>> var products: [ProductItem]
}

struct ProductItem: Decodable, Sendable, Identifiable, Hashable {
    @Default<DefaultZero> var id: Int
    @DString var title: String
    @DString var slug: String
    @DString var category: String
    @DString var subcategory: String
    @DString var metalType: String
    @DString var purity: String
    @DString var price: String
    @DString var oldPrice: String
    @DString var weight: String
    @Default<DefaultTrue> var isInStock: Bool
    @DString var image: String

    static func == (lhs: ProductItem, rhs: ProductItem) -> Bool { lhs.id == rhs.id && lhs.slug == rhs.slug }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(slug)
    }
}

struct ProductDetail: Decodable, Sendable {
    @Default<DefaultZero> var id: Int
    @DString var title: String
    @DString var slug: String
    @DString var category: String
    @DString var subcategory: String
    @DString var metalType: String
    @DString var purity: String
    @DString var price: String
    @DString var oldPrice: String
    @DString var weight: String
    @DString var makingCharges: String
    @DString var hallmark: String
    @DString var description: String
    @DString var shippingDetails: String
    @Default<DefaultTrue> var isInStock: Bool
    @Default<DefaultEmptyList<String>> var images: [String]
}

// MARK: - Content

struct ContactInfo: Decodable, Sendable {
    @DString var phone: String
    @DString var email: String
    @DString var address: String
    @Default<DefaultEmptyList<String>> var footerPhoneNumbers: [String]

    /// First footer number, falling back to the main phone (same as Android).
    var primaryPhone: String {
        (footerPhoneNumbers.first ?? phone).ifBlank(phone)
    }
}

struct HomeInfo: Decodable, Sendable {
    @DString var siteName: String
    @DString var tagline: String
    @DString var logo: String
    @DString var phone: String
    @DString var address: String
    @DString var footerText: String
    @DString var weekdayLabel: String
    @DString var weekdayTime: String
    @DString var sundayLabel: String
    @DString var sundayTime: String
    @Default<DefaultTrue> var appHomePageIsVisible: Bool
    @Default<DefaultTrue> var appProductsPageIsVisible: Bool
    @Default<DefaultEmptyList<HomeSliderItem>> var sliders: [HomeSliderItem]
    @Default<DefaultEmptyList<HomeCategoryItem>> var categories: [HomeCategoryItem]
    @Default<DefaultEmptyList<HomeProductItem>> var products: [HomeProductItem]
    @Default<DefaultEmptyList<Testimonial>> var testimonials: [Testimonial]
}

struct HomeSliderItem: Decodable, Sendable {
    @DString var title: String
    @DString var image: String
    @DString var link: String
}

struct HomeCategoryItem: Decodable, Sendable {
    @Default<DefaultZero> var id: Int
    @DString var title: String
    @DString var subtitle: String
    @DString var slug: String
    @DString var image: String
}

struct HomeProductItem: Decodable, Sendable {
    @Default<DefaultZero> var id: Int
    @DString var title: String
    @DString var slug: String
    @DString var category: String
    @DString var price: String
    @DString var oldPrice: String
    @DString var image: String
}

struct AboutInfo: Decodable, Sendable {
    @DString var headerTitle: String
    @DString var headerSubtitle: String
    @DString var headerBackground: String
    @DString var visionTitle: String
    @DString var visionText: String
    @DString var missionTitle: String
    @DString var missionText: String
    @DString var whoTitle: String
    @DString var whoSubtitle: String
    @DString var whoDescription: String
    @DString var whoButtonText: String
    @DString var whoButtonUrl: String
    @DString var whoImage: String
    @Default<DefaultEmptyList<AboutBrand>> var brands: [AboutBrand]
    @Default<DefaultEmptyList<Testimonial>> var testimonials: [Testimonial]
}

struct AboutBrand: Decodable, Sendable {
    @DString var name: String
    @DString var logo: String
}

struct Testimonial: Decodable, Sendable {
    @DString var name: String
    @DString var role: String
    @DString var message: String
    @DString var photo: String
}

struct PrivacyPolicy: Decodable, Sendable {
    @DString var title: String
    @DString var effectiveDate: String
    @DString var content: String
}
