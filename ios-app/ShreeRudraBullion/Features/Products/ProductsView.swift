import SwiftUI

struct ProductsView: View {
    @Binding var selectedSlug: String?

    @State private var products: [ProductItem]?
    @State private var filter = ProductFilter()
    @State private var showFilters = false
    @State private var page = 0
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let slug = selectedSlug {
                ProductDetailView(slug: slug) { selectedSlug = nil }
            } else {
                list
            }
        }
        .onChange(of: filter) {
            // Any filter or search change goes back to the first page, as on Android.
            page = 0
        }
        .task {
            guard products == nil else { return }
            do {
                products = try await API.products()
            } catch {
                self.error = ErrorMessage.network(error, fallback: "Products are currently unavailable.")
            }
        }
    }

    @ViewBuilder
    private var list: some View {
        SectionTitle(eyebrow: "PRODUCTS", title: "Product Inventory")
        if !error.isEmpty {
            ErrorCard(text: error)
        }
        if let all = products {
            let filtered = filter.apply(to: all)
            let pageCount = ProductFilter.pageCount(for: filtered.count)
            let currentPage = min(page, pageCount - 1)

            ProductSearchBar(text: $filter.search, placeholder: "Search products")
                .padding(.bottom, 12)
            ProductToolbar(
                showFilters: showFilters,
                total: all.count,
                visible: filtered.count,
                activeCategory: filter.category
            ) {
                withAnimation(.easeInOut(duration: 0.2)) { showFilters.toggle() }
            }
            if showFilters {
                ProductFilterPanel(products: all, filter: $filter) {
                    withAnimation(.easeInOut(duration: 0.2)) { showFilters = false }
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            HStack {
                Text("Showing \(filtered.count) Products")
                    .font(.poppins(18, .extraBold))
                    .foregroundStyle(Color.dark)
                Spacer()
                Text("Page \(currentPage + 1) / \(pageCount)")
                    .font(.poppins(13, .bold))
                    .foregroundStyle(Color.muted)
            }
            .padding(.vertical, 12)
            .padding(.top, 2)

            if filtered.isEmpty {
                EmptyCard(text: "No products found for the selected filters.")
            } else {
                ForEach(ProductFilter.page(currentPage, of: filtered)) { product in
                    ProductListCard(product: product) { selectedSlug = product.slug }
                        .padding(.bottom, 12)
                }
            }
            ProductPagination(page: currentPage, pageCount: pageCount) { page = $0 }
        } else if error.isEmpty {
            LoadingBox()
        }
    }
}

struct ProductSearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.muted)
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.muted))
                .font(.poppins(15))
                .foregroundStyle(Color.dark)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.muted)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.line.opacity(0.6), lineWidth: 1))
    }
}

struct ProductToolbar: View {
    let showFilters: Bool
    let total: Int
    let visible: Int
    let activeCategory: String
    let onToggleFilters: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.gold)
                .frame(width: 40, height: 40)
                .background(Color.gold.opacity(0.16), in: Circle())
            VStack(alignment: .leading, spacing: 0) {
                Text("Browse Products")
                    .font(.poppins(17, .extraBold))
                    .foregroundStyle(.white)
                Text("\(activeCategory) | \(visible) matching | \(total) total")
                    .font(.poppins(12, .bold))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Button(action: onToggleFilters) {
                HStack(spacing: 5) {
                    Text(showFilters ? "Hide" : "Filter")
                        .font(.poppins(12, .extraBold))
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.gold, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.dark, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gold.opacity(0.35), lineWidth: 1))
    }
}

struct ProductFilterPanel: View {
    let products: [ProductItem]
    @Binding var filter: ProductFilter
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Filters")
                    .font(.poppins(19, .extraBold))
                    .foregroundStyle(Color.dark)
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.muted)
                    }
                    .accessibilityLabel("Close filters")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.softSurface)

            section("Category") {
                chips(ProductFilter.categories(in: products), selected: filter.category) { category in
                    "\(category) (\(ProductFilter.categoryCount(category, in: products)))"
                } onSelect: { filter.category = $0 }
            }
            section("Metal Type") {
                chips(ProductFilter.metals(in: products), selected: filter.metal) { $0 } onSelect: { filter.metal = $0 }
            }
            section("Purity") {
                chips(ProductFilter.purities(in: products), selected: filter.purity) { $0 } onSelect: { filter.purity = $0 }
            }
            section("Availability") {
                Button {
                    filter.stockOnly.toggle()
                } label: {
                    HStack {
                        Text("In Stock Only")
                            .font(.poppins(14, .extraBold))
                            .foregroundStyle(filter.stockOnly ? Color.gold : Color.dark)
                        Spacer()
                        Image(systemName: filter.stockOnly ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundStyle(filter.stockOnly ? Color.gold : Color.line)
                    }
                    .padding(12)
                    .background(filter.stockOnly ? Color.gold.opacity(0.12) : Color.softSurface, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(filter.stockOnly ? Color.gold : Color.line, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                OutlineButton(title: "Discard", cornerRadius: 18, height: 46) {
                    filter.clearFilters()
                }
                FilledButton(title: "Apply", cornerRadius: 18, height: 46, action: onClose)
            }
            .padding(14)
            .background(Color.softSurface)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.line.opacity(0.6), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.poppins(15, .extraBold))
                .foregroundStyle(Color.dark)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Color.line.opacity(0.5).frame(height: 1)
        }
    }

    private func chips(_ values: [String], selected: String, label: @escaping (String) -> String, onSelect: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(values, id: \.self) { value in
                    FilterChip(label: label(value), active: selected == value) { onSelect(value) }
                }
            }
            .padding(.vertical, 1)
        }
    }
}

struct ProductPagination: View {
    let page: Int
    let pageCount: Int
    let onPage: (Int) -> Void

    var body: some View {
        if pageCount > 1 {
            HStack(spacing: 8) {
                OutlineButton(title: "Prev", enabled: page > 0) { onPage(max(page - 1, 0)) }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(0..<pageCount, id: \.self) { index in
                            let active = index == page
                            Button {
                                onPage(index)
                            } label: {
                                Text("\(index + 1)")
                                    .font(.poppins(12, .extraBold))
                                    .foregroundStyle(active ? Color.white : Color.dark)
                                    .frame(width: active ? 32 : 28, height: active ? 32 : 28)
                                    .background(active ? Color.gold : Color.white, in: Circle())
                                    .overlay(Circle().stroke(active ? Color.gold : Color.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .fixedSize(horizontal: pageCount <= 5, vertical: false)
                OutlineButton(title: "Next", enabled: page < pageCount - 1) { onPage(min(page + 1, pageCount - 1)) }
            }
        }
    }
}

struct ProductListCard: View {
    let product: ProductItem
    let onClick: () -> Void

    private var categoryLine: String {
        [product.category, product.subcategory].filter { !$0.isBlank }.joined(separator: " / ")
    }

    private var meta: [String] {
        var lines: [String] = []
        if !product.weight.isBlank { lines.append("Weight: \(product.weight) KG") }
        let metalPurity = [product.metalType, product.purity].filter { !$0.isBlank }.joined(separator: " | ").uppercased()
        if !metalPurity.isEmpty { lines.append(metalPurity) }
        return lines
    }

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                RemoteImage(url: product.image, placeholderIcon: "shippingbox")
                    .frame(width: 112, height: 128)
                    .overlay(alignment: .topLeading) {
                        if !product.isInStock {
                            Text("Out of Stock")
                                .font(.poppins(10, .extraBold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.sellRed, in: RoundedRectangle(cornerRadius: 3))
                                .padding(8)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 0) {
                    Text(categoryLine)
                        .font(.poppins(12, .bold))
                        .foregroundStyle(Color.muted)
                        .lineLimit(2)
                    Text(product.title)
                        .font(.poppins(17, .extraBold))
                        .foregroundStyle(Color.dark)
                        .lineLimit(2)
                        .padding(.top, 4)
                    PriceLine(price: product.price, oldPrice: product.oldPrice)
                        .padding(.top, 8)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(meta, id: \.self) { line in
                            Text(line)
                                .font(.poppins(12, .bold))
                                .foregroundStyle(Color.muted)
                        }
                    }
                    .padding(.top, 8)
                    HStack {
                        StockBadge(inStock: product.isInStock)
                        Spacer()
                        ChevronBadge()
                    }
                    .padding(.top, 8)
                }
                .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line.opacity(0.55), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}
