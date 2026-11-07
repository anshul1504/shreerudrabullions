import SwiftUI

struct HomeView: View {
    let onViewProducts: () -> Void
    let onProductClick: (String) -> Void

    @State private var home: HomeInfo?
    @State private var productSearch = ""
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let data = home {
                content(data)
            } else if !error.isEmpty {
                ErrorCard(text: error)
            } else {
                LoadingBox()
            }
        }
        .task {
            guard home == nil else { return }
            do {
                home = try await API.home()
            } catch {
                self.error = ErrorMessage.network(error, fallback: "Home details are currently unavailable.")
            }
        }
    }

    @ViewBuilder
    private func content(_ data: HomeInfo) -> some View {
        ProductSearchBar(text: $productSearch, placeholder: "Search products")
            .padding(.bottom, 12)
        HomeSlider(data: data)
            .padding(.bottom, 12)
        ServiceStrip()
            .padding(.bottom, 16)

        SectionTitle(eyebrow: "Why Choose Us", title: "India's Trusted Bullion Partner")
        Text("Premium bullion and jewellery solutions with verified purity, transparent pricing, and dedicated dealer support.")
            .font(.poppins(15))
            .foregroundStyle(Color.muted)
            .padding(.bottom, 12)
        HomeWhyGrid()
            .padding(.bottom, 16)

        if !data.categories.isEmpty {
            SectionTitle(eyebrow: "Featured Category", title: "Explore Our Featured Categories")
            AutoScrollRow(count: data.categories.count, interval: .milliseconds(1800), animation: .linear(duration: 0.85)) { index in
                HomeCategoryCard(category: data.categories[index])
            }
            .frame(height: 170)
            .padding(.bottom, 16)
        }

        if !data.products.isEmpty {
            let query = productSearch.trimmingCharacters(in: .whitespaces)
            let searched = data.products.filter {
                query.isEmpty
                    || $0.title.localizedCaseInsensitiveContains(query)
                    || $0.category.localizedCaseInsensitiveContains(query)
                    || $0.price.localizedCaseInsensitiveContains(query)
            }
            SectionTitle(eyebrow: "Featured Collection", title: "Our Products")
            Text("Browse gold, silver, and hallmark jewellery collections.")
                .font(.poppins(15))
                .foregroundStyle(Color.muted)
                .padding(.bottom, 12)
            ForEach(Array(searched.prefix(8).enumerated()), id: \.offset) { _, product in
                HomeProductCard(product: product) { onProductClick(product.slug) }
                    .padding(.bottom, 12)
            }
            if searched.isEmpty {
                EmptyCard(text: "No products found for this search.")
            }
            PrimaryButton(title: "View Products", action: onViewProducts)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }

        CommitmentSection()
            .padding(.bottom, 16)

        if !data.testimonials.isEmpty {
            SectionTitle(eyebrow: "Testimonials", title: "What Clients Say")
            AutoScrollRow(count: data.testimonials.count) { index in
                TestimonialCard(testimonial: data.testimonials[index])
                    .frame(width: 300)
            }
            .padding(.bottom, 16)
        }

        TrustStrip()
            .padding(.bottom, 16)

        Panel {
            Text("Ready to Trade with Confidence?")
                .font(.poppins(20, .extraBold))
                .foregroundStyle(Color.dark)
            Text("Connect with our team for live rates, bulk quotes, and quick support.")
                .font(.poppins(15))
                .foregroundStyle(Color.muted)
                .padding(.bottom, 12)
            InfoLine(label: "Phone", value: data.phone.ifBlank("-"), systemImage: "phone")
            InfoLine(label: "Address", value: data.address.ifBlank("-"), systemImage: "mappin.and.ellipse")
            InfoLine(label: data.weekdayLabel.ifBlank("Business hours"), value: data.weekdayTime.ifBlank("-"), systemImage: "rosette")
        }
    }
}

struct HomeSlider: View {
    let data: HomeInfo
    @State private var active = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.dark
            if !data.sliders.isEmpty {
                TabView(selection: $active) {
                    ForEach(Array(data.sliders.enumerated()), id: \.offset) { index, slide in
                        ZStack {
                            if !slide.image.isEmpty {
                                RemoteImage(url: slide.image)
                                Color.black.opacity(0.28)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(data.siteName.ifBlank("Shree Rudra Bullion"))
                    .font(.poppins(24, .extraBold))
                    .foregroundStyle(.white)
                Text(data.tagline.ifBlank("Trusted bullion rates, products, and customer support."))
                    .font(.poppins(15))
                    .foregroundStyle(.white.opacity(0.86))
            }
            .padding(20)
            .allowsHitTesting(false)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .task(id: data.sliders.count) {
            guard data.sliders.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(2600))
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: 0.5)) {
                    active = (active + 1) % data.sliders.count
                }
            }
        }
    }
}

struct ServiceStrip: View {
    private let services = [
        "Gold Coins & Bars", "Silver Coins, Bars & Utensils", "BIS Hallmarked Jewellery",
        "Certified Purity Assurance", "Live Gold & Silver Rates", "Bulk Dealer Pricing Support",
        "Quick WhatsApp Rate Assistance",
    ]

    var body: some View {
        AutoScrollRow(count: services.count, spacing: 8, interval: .milliseconds(1500), animation: .linear(duration: 0.6)) { index in
            Text(services[index])
                .font(.poppins(13, .bold))
                .foregroundStyle(Color.textDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line.opacity(0.45), lineWidth: 1))
        }
        .frame(height: 40)
    }
}

struct HomeWhyGrid: View {
    private let items: [(String, String, String)] = [
        ("BIS Certified", "Hallmarked products with purity standards trusted by buyers.", "checkmark.shield"),
        ("Live Market Rates", "Real-time gold and silver rates updated regularly.", "chart.line.uptrend.xyaxis"),
        ("Secure Deals", "Transparent billing and documented transactions.", "lock.shield"),
        ("Dealer Support", "Dedicated assistance for bulk orders and rate checks.", "headset"),
        ("Fast Fulfilment", "Prompt order processing and delivery coordination.", "shippingbox"),
        ("Quick Response", "Rapid quote and support via call or WhatsApp.", "phone"),
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(items, id: \.0) { title, text, icon in
                VStack(alignment: .leading, spacing: 0) {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(Color.gold)
                        .frame(height: 26)
                        .padding(.bottom, 12)
                    Text(title)
                        .font(.poppins(16, .bold))
                        .foregroundStyle(Color.dark)
                    Text(text)
                        .font(.poppins(14))
                        .foregroundStyle(Color.muted)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

struct HomeCategoryCard: View {
    let category: HomeCategoryItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.dark
            if !category.image.isEmpty {
                RemoteImage(url: category.image)
                Color.black.opacity(0.42)
            }
            VStack(alignment: .leading, spacing: 0) {
                if !category.subtitle.isBlank {
                    Text(category.subtitle)
                        .font(.poppins(13, .bold))
                        .foregroundStyle(Color.gold)
                }
                Text(category.title)
                    .font(.poppins(20, .extraBold))
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
        .frame(width: 260, height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct HomeProductCard: View {
    let product: HomeProductItem
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                RemoteImage(url: product.image, placeholderIcon: "shippingbox")
                    .frame(width: 108, height: 122)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.category)
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
                    HStack {
                        Text("View Detail")
                            .font(.poppins(12, .extraBold))
                            .foregroundStyle(Color.gold)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        Spacer()
                        ChevronBadge()
                    }
                    .padding(.top, 10)
                }
                .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white).shadow(color: .black.opacity(0.05), radius: 2, y: 1))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CommitmentSection: View {
    var body: some View {
        Panel {
            HStack(spacing: 10) {
                CounterStat(value: "40+", label: "Years")
                CounterStat(value: "999", label: "Purity")
                CounterStat(value: "100%", label: "BIS Focused")
            }
            .padding(.bottom, 16)
            Text("Our Commitment")
                .font(.poppins(13, .extraBold))
                .foregroundStyle(Color.gold)
            Text("Why Investors Choose Us")
                .font(.poppins(21, .extraBold))
                .foregroundStyle(Color.dark)
                .padding(.bottom, 12)
            InfoLine(label: "Real-Time Pricing", value: "Rates linked to market movement with timely updates.", systemImage: "chart.line.uptrend.xyaxis")
            InfoLine(label: "Transparency First", value: "Clear pricing visibility before every transaction.", systemImage: "checkmark.shield")
            InfoLine(label: "Certified Products", value: "Bullion and hallmark details shared for confidence.", systemImage: "rosette")
            InfoLine(label: "Expert Guidance", value: "Dedicated support for fast and reliable decisions.", systemImage: "phone")
        }
    }
}

struct CounterStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.poppins(18, .extraBold))
                .foregroundStyle(Color.gold)
            Text(label)
                .font(.poppins(12, .bold))
                .foregroundStyle(Color.textDark)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct TrustStrip: View {
    private let badges = ["BIS Hallmarked", "GST Registered", "Transparent Pricing", "Secure Billing", "Verified Purity", "Dealer Support"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(badges, id: \.self) { badge in
                    Text(badge)
                        .font(.poppins(13, .extraBold))
                        .foregroundStyle(Color.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }
}

struct TestimonialCard: View {
    let testimonial: Testimonial

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if !testimonial.photo.isEmpty {
                    RemoteImage(url: testimonial.photo)
                } else {
                    Text(testimonial.name.prefix(1).uppercased().ifBlank("C"))
                        .font(.poppins(18, .extraBold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gold)
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 0) {
                Text(testimonial.message)
                    .font(.poppins(15))
                    .foregroundStyle(Color.dark)
                    .fixedSize(horizontal: false, vertical: true)
                Text(testimonial.name)
                    .font(.poppins(16, .extraBold))
                    .foregroundStyle(Color.dark)
                    .padding(.top, 8)
                if !testimonial.role.isBlank {
                    Text(testimonial.role)
                        .font(.poppins(13, .bold))
                        .foregroundStyle(Color.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.line.opacity(0.5), lineWidth: 1))
    }
}
