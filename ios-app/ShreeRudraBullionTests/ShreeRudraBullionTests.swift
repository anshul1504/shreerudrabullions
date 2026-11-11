import Foundation
import Testing
@testable import ShreeRudraBullion

struct MobileNumberTests {
    @Test(arguments: [
        ("9876543210", "9876543210"),
        ("+91 98765 43210", "9876543210"),
        ("919876543210", "9876543210"),
        ("98765432109999", "9876543210"),
        ("abc", ""),
    ])
    func normalisesIndianMobile(input: String, expected: String) {
        #expect(input.indianMobileDigits == expected)
    }

    @Test func validatesFirstDigitAndLength() {
        #expect("9876543210".isValidIndianMobile)
        #expect("6000000000".isValidIndianMobile)
        #expect(!"5876543210".isValidIndianMobile)
        #expect(!"987654321".isValidIndianMobile)
    }
}

struct FormattingTests {
    @Test func titleCase() {
        #expect("  rAHUL   kumar ".titleCased == "Rahul Kumar")
    }

    @Test func ifBlankFallsBack() {
        #expect("  ".ifBlank("Customer") == "Customer")
        #expect("Asha".ifBlank("Customer") == "Asha")
    }

    @Test func rateMovement() {
        #expect(RateMovement.compare("1,25,400", "1,25,300") == 1)
        #expect(RateMovement.compare("125300", "125400") == -1)
        #expect(RateMovement.compare("125300", "125300") == 0)
        #expect(RateMovement.compare("-", "125300") == 0)
        #expect(RateMovement.compare("125300", nil) == 0)
    }

    @Test func htmlToPlainText() {
        let html = "<p>Pure&nbsp;gold &amp; silver</p><ul><li>BIS</li><li>999</li></ul>Line<br/>Two"
        #expect(HTMLText.plainText(html) == "Pure gold & silver\n• BIS\n• 999\nLine\nTwo")
    }
}

struct ErrorMessageTests {
    @Test func prefersDetail() {
        #expect(ErrorMessage.parseBody(#"{"detail": "Invalid mobile number or password."}"#) == "Invalid mobile number or password.")
    }

    @Test func fallsBackToFirstFieldError() {
        let body = #"{"mobile": ["A signup request for this mobile number is already pending."]}"#
        #expect(ErrorMessage.parseBody(body) == "A signup request for this mobile number is already pending.")
    }

    @Test func httpErrorUsesBody() {
        let error = APIError.http(status: 400, body: Data(#"{"detail":"Current password is incorrect."}"#.utf8))
        #expect(ErrorMessage.api(error, fallback: "x") == "Current password is incorrect.")
    }

    @Test func unauthorizedNetworkMessage() {
        let error = APIError.http(status: 401, body: Data())
        #expect(ErrorMessage.network(error, fallback: "x") == "Your session has expired. Please sign in again.")
    }
}

struct DecodingTests {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    @Test func decodesProductListWithMissingAndNullFields() throws {
        let json = #"""
        {"products": [{"id": 3, "title": "Gold Coin 10g", "slug": "gold-coin-10g", "category": "Coins",
          "metal_type": "gold", "purity": "999", "price": "72000.00", "old_price": null,
          "is_in_stock": false, "image": ""}]}
        """#
        let response = try decoder.decode(ProductsResponse.self, from: Data(json.utf8))
        let product = try #require(response.products.first)
        #expect(product.title == "Gold Coin 10g")
        #expect(product.metalType == "gold")
        #expect(product.oldPrice == "")
        #expect(product.subcategory == "")
        #expect(product.isInStock == false)
    }

    @Test func decodesHomeVisibilityFlagsWithDefaults() throws {
        let json = #"{"site_name": "Shree Rudra Bullion", "app_products_page_is_visible": false}"#
        let home = try decoder.decode(HomeInfo.self, from: Data(json.utf8))
        #expect(home.appHomePageIsVisible)
        #expect(!home.appProductsPageIsVisible)
        #expect(home.sliders.isEmpty)
    }

    @Test func decodesLiveRatesIgnoringExtraKeys() throws {
        let json = #"""
        {"market_open": true, "rate_source": "live", "rate_updated": "10:30",
         "market_summary": {"usd_inr": "84.1"}, "market_base_rates": {},
         "rows": [{"key": "gold999", "label": "Gold 999", "unit": "10 GM", "buy": "1,25,000", "sell": "1,25,400", "formula": ""}]}
        """#
        let rates = try decoder.decode(LiveRatesResponse.self, from: Data(json.utf8))
        #expect(rates.marketOpen)
        #expect(rates.rows.first?.sell == "1,25,400")
    }

    @Test func encodesRequestsInSnakeCase() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(SignupRequest(name: "A", mobile: "9876543210", password: "p", confirmPassword: "p", fcmToken: "t"))
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["confirm_password"] as? String == "p")
        #expect(object["fcm_token"] as? String == "t")
    }
}

struct ProductFilterTests {
    private func product(_ id: Int, category: String, metal: String, purity: String, inStock: Bool = true) -> ProductItem {
        let json: [String: Any] = [
            "id": id, "title": "Item \(id)", "slug": "item-\(id)", "category": category,
            "metal_type": metal, "purity": purity, "price": "\(id)00", "is_in_stock": inStock,
        ]
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // swiftlint:disable:next force_try
        return try! decoder.decode(ProductItem.self, from: JSONSerialization.data(withJSONObject: json))
    }

    private var items: [ProductItem] {
        [
            product(1, category: "Coins", metal: "gold", purity: "999"),
            product(2, category: "Coins", metal: "silver", purity: "999", inStock: false),
            product(3, category: "Bars", metal: "gold", purity: "995"),
        ]
    }

    @Test func filtersByCategoryMetalPurityAndStock() {
        var filter = ProductFilter()
        filter.category = "Coins"
        #expect(filter.apply(to: items).map(\.id) == [1, 2])
        filter.metal = "Silver"
        #expect(filter.apply(to: items).map(\.id) == [2])
        filter.stockOnly = true
        #expect(filter.apply(to: items).isEmpty)
        filter.clearFilters()
        filter.purity = "995"
        #expect(filter.apply(to: items).map(\.id) == [3])
    }

    @Test func searchMatchesTitleCategoryAndPrice() {
        var filter = ProductFilter()
        filter.search = "bars"
        #expect(filter.apply(to: items).map(\.id) == [3])
        filter.search = "200"
        #expect(filter.apply(to: items).map(\.id) == [2])
    }

    @Test func optionListsAndPaging() {
        #expect(ProductFilter.categories(in: items) == ["All", "Coins", "Bars"])
        #expect(ProductFilter.metals(in: items) == ["All", "Gold", "Silver"])
        #expect(ProductFilter.categoryCount("All", in: items) == 3)
        #expect(ProductFilter.pageCount(for: 0) == 1)
        #expect(ProductFilter.pageCount(for: 13) == 3)
        let many = (1...13).map { product($0, category: "C", metal: "gold", purity: "999") }
        #expect(ProductFilter.page(2, of: many).map(\.id) == [13])
    }
}

@MainActor
struct SessionStoreTests {
    @Test func sessionLifecycle() throws {
        let suite = "session-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let keychain = KeychainStore(service: "com.shreerudra.bullion.tests.\(UUID().uuidString)")
        defer { keychain.removeAll() }

        let store = SessionStore(defaults: defaults, keychain: keychain)
        #expect(!store.isLoggedIn)

        let login = try JSONDecoder().decode(
            LoginResponse.self,
            from: Data(#"{"access":"a1","refresh":"r1","user":{"id":1,"name":"Tester","mobile":"9876543210"}}"#.utf8)
        )
        store.setPendingSignup("9876543210")
        store.setSession(login)
        #expect(store.isLoggedIn)
        #expect(store.authorization == "Bearer a1")
        #expect(store.pendingSignupMobile.isEmpty)

        let reloaded = SessionStore(defaults: defaults, keychain: keychain)
        #expect(reloaded.accessToken == "a1")
        #expect(reloaded.userName == "Tester")

        store.signOut()
        #expect(!store.isLoggedIn)
        #expect(store.signedOutMessage == SessionStore.signedOutMessageText)
    }
}
