import SwiftUI

struct ProductDetailView: View {
    let slug: String
    let onBack: () -> Void

    @State private var detail: ProductDetail?
    @State private var contact: ContactInfo?
    @State private var error = ""
    @State private var activeImage = 0
    @State private var descriptionText = ""
    @State private var shippingText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("Back to Products")
                        .font(.poppins(14, .bold))
                }
                .foregroundStyle(Color.gold)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if !error.isEmpty {
                ErrorCard(text: error)
            }
            if let item = detail {
                card(item)
            } else if error.isEmpty {
                LoadingBox()
            }
        }
        .task(id: slug) {
            detail = nil
            error = ""
            activeImage = 0
            contact = try? await API.contact()
            do {
                let item = try await API.productDetail(slug: slug)
                descriptionText = HTMLText.plainText(item.description)
                shippingText = HTMLText.plainText(item.shippingDetails)
                detail = item
            } catch {
                self.error = ErrorMessage.network(error, fallback: "Product detail is currently unavailable.")
            }
        }
    }

    private var businessPhone: String {
        contact?.primaryPhone ?? ""
    }

    @ViewBuilder
    private func card(_ item: ProductDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.images.indices.contains(activeImage) {
                ZoomableImage(url: item.images[activeImage])
                    .id(item.images[activeImage])
                if item.images.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(item.images.enumerated()), id: \.offset) { index, image in
                                Button {
                                    activeImage = index
                                } label: {
                                    RemoteImage(url: image)
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(index == activeImage ? Color.gold : Color.line, lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(2)
                    }
                    .padding(.top, 10)
                }
            }

            Text([item.category, item.subcategory].filter { !$0.isBlank }.joined(separator: " / "))
                .font(.poppins(14, .bold))
                .foregroundStyle(Color.gold)
                .padding(.top, 16)
            Text(item.title)
                .font(.poppins(25, .extraBold))
                .foregroundStyle(Color.dark)

            SummaryBox(item: item)
                .padding(.top, 10)

            PriceLine(price: item.price, oldPrice: item.oldPrice, size: 25, oldSize: 16)
                .padding(.top, 12)
            Text("Indicative pricing. Final bullion/jewellery rate may vary with live market movement.")
                .font(.poppins(13))
                .foregroundStyle(Color.muted)
            StockBadge(inStock: item.isInStock)
                .padding(.vertical, 10)

            TrustNote(text: "Live rate linked pricing support available.", systemImage: "chart.line.uptrend.xyaxis")
            TrustNote(text: "BIS/purity details shared transparently.", systemImage: "checkmark.shield")
            TrustNote(text: "Payment and billing support available.", systemImage: "indianrupeesign.circle")
            TrustNote(text: "Bulk quote available for dealer requirements.", systemImage: "bubble.left")

            if !descriptionText.isEmpty {
                Text("Description")
                    .font(.poppins(18, .extraBold))
                    .foregroundStyle(Color.dark)
                    .padding(.top, 12)
                Text(descriptionText)
                    .font(.poppins(15))
                    .foregroundStyle(Color.muted)
            }
            if !shippingText.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Shipping")
                        .font(.poppins(18, .extraBold))
                        .foregroundStyle(Color.dark)
                    Text(shippingText)
                        .font(.poppins(15))
                        .foregroundStyle(Color.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.softSurface, in: RoundedRectangle(cornerRadius: 10))
                .padding(.top, 12)
            }

            HStack(spacing: 10) {
                FilledButton(title: "Make a Call", systemImage: "phone", color: .gold, cornerRadius: 8, height: 52, fontSize: 13) {
                    ExternalLinks.dial(businessPhone)
                }
                FilledButton(title: "WhatsApp", systemImage: "bubble.left", color: .buyGreen, cornerRadius: 8, height: 52, fontSize: 13) {
                    ExternalLinks.whatsApp(businessPhone)
                }
            }
            .padding(.top, 14)
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.line.opacity(0.55), lineWidth: 1))
    }
}

/// Pinch to zoom (1x–4x) and pan while zoomed, like ZoomableProductImage on Android.
struct ZoomableImage: View {
    let url: String

    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero

    var body: some View {
        Color.softSurface
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RemoteImage(url: url, placeholderIcon: "shippingbox")
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = min(max(baseScale * value.magnification, 1), 4)
                    }
                    .onEnded { _ in
                        baseScale = scale
                        if scale == 1 { resetOffset() }
                    }
                    .simultaneously(with: DragGesture(minimumDistance: scale > 1 ? 0 : 10_000)
                        .onChanged { value in
                            guard scale > 1 else { return }
                            let limit = 140 * scale
                            offset = CGSize(
                                width: min(max(baseOffset.width + value.translation.width, -limit), limit),
                                height: min(max(baseOffset.height + value.translation.height, -limit), limit)
                            )
                        }
                        .onEnded { _ in baseOffset = offset }
                    )
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if scale > 1 {
                        scale = 1
                        baseScale = 1
                        resetOffset()
                    } else {
                        scale = 2
                        baseScale = 2
                    }
                }
            }
            .accessibilityLabel("Product image. Pinch or double tap to zoom.")
    }

    private func resetOffset() {
        offset = .zero
        baseOffset = .zero
    }
}

struct SummaryBox: View {
    let item: ProductDetail

    var body: some View {
        VStack(spacing: 0) {
            SummaryRow(label: "Category", value: [item.category, item.subcategory].filter { !$0.isBlank }.joined(separator: " / "))
            SummaryRow(label: "Metal", value: item.metalType.ifBlank("-").capitalizedFirst)
            if !item.weight.isBlank { SummaryRow(label: "Weight", value: "\(item.weight) KG") }
            if !item.purity.isBlank { SummaryRow(label: "Purity", value: item.purity) }
            if !item.hallmark.isBlank { SummaryRow(label: "Hallmark", value: item.hallmark) }
            if !item.makingCharges.isBlank { SummaryRow(label: "Making Charges", value: "Rs. \(item.makingCharges)") }
        }
        .padding(12)
        .background(Color.softSurface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.poppins(13, .bold))
                .foregroundStyle(Color.muted)
                .frame(width: 118, alignment: .leading)
            Text(value.ifBlank("-"))
                .font(.poppins(14, .extraBold))
                .foregroundStyle(Color.dark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }
}

struct TrustNote: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            IconBadge(systemImage: systemImage, size: 24, iconSize: 11)
            Text(text)
                .font(.poppins(14))
                .foregroundStyle(Color.muted)
        }
        .padding(.vertical, 2)
    }
}
