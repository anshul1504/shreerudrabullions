import SwiftUI

enum DashboardTab: String, CaseIterable, Identifiable {
    case home, products, rates, about, profile

    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: "Home"
        case .products: "Products"
        case .rates: "Live"
        case .about: "About"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .products: "shippingbox"
        case .rates: "chart.line.uptrend.xyaxis"
        case .about: "rosette"
        case .profile: "person"
        }
    }
}

struct DashboardView: View {
    @State private var tab: DashboardTab = .rates
    @State private var profileResetSignal = 0
    @State private var selectedProductSlug: String?
    @State private var contact: ContactInfo?
    @State private var showHomeTab = true
    @State private var showProductsTab = true

    private var tabs: [DashboardTab] {
        DashboardTab.allCases.filter { item in
            switch item {
            case .home: showHomeTab
            case .products: showProductsTab
            default: true
            }
        }
    }

    private var quickPhone: String {
        contact?.primaryPhone.ifBlank(SessionStore.shared.mobile) ?? SessionStore.shared.mobile
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 0).id("top")
                    if tab == .rates {
                        DashboardHeader(tab: tab)
                            .padding(.bottom, 12)
                    }
                    content
                    Spacer().frame(height: 72)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.softSurface.ignoresSafeArea())
            .overlay(alignment: .bottomTrailing) {
                QuickContactActions(
                    onCall: { ExternalLinks.dial(quickPhone) },
                    onWhatsApp: { ExternalLinks.whatsApp(quickPhone) }
                )
                .padding(.trailing, 18)
                .padding(.bottom, 12)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                FloatingTabBar(tabs: tabs, active: tab) { item in
                    if item == .profile { profileResetSignal += 1 }
                    if item == .products { selectedProductSlug = nil }
                    tab = item
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .onChange(of: selectedProductSlug) {
                proxy.scrollTo("top", anchor: .top)
            }
        }
        .task {
            if let info = try? await API.contact() {
                contact = info
            }
            if let home = try? await API.home() {
                showHomeTab = home.appHomePageIsVisible
                showProductsTab = home.appProductsPageIsVisible
                if (!showHomeTab && tab == .home) || (!showProductsTab && tab == .products) {
                    tab = .rates
                    selectedProductSlug = nil
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .home:
            HomeView(
                onViewProducts: {
                    selectedProductSlug = nil
                    tab = .products
                },
                onProductClick: { slug in
                    selectedProductSlug = slug
                    tab = .products
                }
            )
        case .products:
            ProductsView(selectedSlug: $selectedProductSlug)
        case .about:
            AboutView()
        case .profile:
            ProfileView(resetSignal: profileResetSignal)
        case .rates:
            LiveRatesView()
        }
    }
}

struct FloatingTabBar: View {
    let tabs: [DashboardTab]
    let active: DashboardTab
    let onSelect: (DashboardTab) -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs) { item in
                Button {
                    onSelect(item)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(item == active ? Color.gold : Color.textDark)
                            .frame(width: 36, height: 36)
                            .background(item == active ? Color.gold.opacity(0.16) : Color.softSurface, in: Circle())
                        Text(item.label)
                            .font(.poppins(11, .extraBold))
                            .foregroundStyle(item == active ? Color.gold : Color.textDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(item == active ? .isSelected : [])
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 86)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.line.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}

struct QuickContactActions: View {
    let onCall: () -> Void
    let onWhatsApp: () -> Void

    var body: some View {
        HStack(spacing: 7) {
            Button(action: onCall) {
                Image(systemName: "phone")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.gold, in: Circle())
            }
            .accessibilityLabel("Call")
            Button(action: onWhatsApp) {
                Image("WhatsAppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
            }
            .accessibilityLabel("WhatsApp")
        }
        .buttonStyle(.plain)
        .padding(6)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line.opacity(0.55), lineWidth: 1))
        .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
    }
}

struct DashboardHeader: View {
    let tab: DashboardTab

    private var title: String {
        switch tab {
        case .home: "Welcome"
        case .products: "Products"
        case .about: "About Us"
        case .profile: "My Account"
        case .rates: "Live Rates"
        }
    }

    private var subtitle: String {
        switch tab {
        case .home: "Hello, \(SessionStore.shared.userName.ifBlank("Customer"))"
        case .products: "Explore our active website catalogue"
        case .about: "Trusted bullion service and support"
        case .profile: "Manage your account and enquiries"
        case .rates: "Current bullion buy and sell rates"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            AppLogo(size: 52, background: .surface)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.poppins(20, .extraBold))
                    .foregroundStyle(Color.textDark)
                if tab != .rates {
                    Text(subtitle)
                        .font(.poppins(14))
                        .foregroundStyle(Color.muted)
                }
            }
            Spacer(minLength: 0)
            if tab != .rates {
                Text("Member")
                    .font(.poppins(11, .bold))
                    .foregroundStyle(Color.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
            }
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.line.opacity(0.5), lineWidth: 1))
    }
}
