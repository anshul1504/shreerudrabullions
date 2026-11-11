import Foundation

/// Client-side search, filters and paging, same rules as ProductsScreen on Android.
struct ProductFilter: Equatable {
    static let all = "All"
    static let pageSize = 6

    var search = ""
    var category = all
    var metal = all
    var purity = all
    var stockOnly = false

    func apply(to list: [ProductItem]) -> [ProductItem] {
        let query = search.trimmingCharacters(in: .whitespaces)
        return list.filter { item in
            let matchesQuery = query.isEmpty || [item.title, item.category, item.subcategory, item.metalType, item.purity, item.price]
                .contains { $0.localizedCaseInsensitiveContains(query) }
            return matchesQuery
                && (category == Self.all || item.category == category)
                && (metal == Self.all || item.metalType.caseInsensitiveCompare(metal) == .orderedSame)
                && (purity == Self.all || item.purity == purity)
                && (!stockOnly || item.isInStock)
        }
    }

    mutating func clearFilters() {
        category = Self.all
        metal = Self.all
        purity = Self.all
        stockOnly = false
    }

    static func categories(in list: [ProductItem]) -> [String] {
        [all] + distinct(list.map(\.category))
    }

    static func metals(in list: [ProductItem]) -> [String] {
        [all] + distinct(list.map { $0.metalType.capitalizedFirst })
    }

    static func purities(in list: [ProductItem]) -> [String] {
        [all] + distinct(list.map(\.purity))
    }

    static func categoryCount(_ category: String, in list: [ProductItem]) -> Int {
        category == all ? list.count : list.filter { $0.category == category }.count
    }

    static func pageCount(for count: Int) -> Int {
        max(1, (count + pageSize - 1) / pageSize)
    }

    static func page(_ page: Int, of list: [ProductItem]) -> [ProductItem] {
        Array(list.dropFirst(page * pageSize).prefix(pageSize))
    }

    private static func distinct(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { !$0.isBlank && seen.insert($0).inserted }
    }
}
