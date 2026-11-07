import SwiftUI

// Shared building blocks, matching the composables at the bottom of ShreeRudraApp.kt.

struct Panel<Content: View>: View {
    var padding: CGFloat = 22
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padding)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct BorderedCard<Content: View>: View {
    var cornerRadius: CGFloat = 22
    var padding: CGFloat = 16
    var shadow = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padding)
        .background(Color.white, in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.line.opacity(0.55), lineWidth: 1))
        .shadow(color: .black.opacity(shadow ? 0.06 : 0), radius: 3, y: 1)
    }
}

struct SectionTitle: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(eyebrow.uppercased())
                .font(.poppins(13, .bold))
                .foregroundStyle(Color.gold)
            Text(title)
                .font(.poppins(24, .bold))
                .foregroundStyle(Color.dark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 14)
    }
}

struct AppField: View {
    let label: String
    @Binding var text: String
    var isSecure = false
    var error = ""
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?
    var capitalization: TextInputAutocapitalization = .sentences
    var multiline = false
    var prefix: String?

    @State private var revealed = false
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.poppins(13, .bold))
                .foregroundStyle(error.isEmpty ? (focused ? Color.gold : Color.muted) : Color.sellRed)
            HStack(spacing: 8) {
                if let prefix {
                    Text(prefix)
                        .font(.poppins(16, .bold))
                        .foregroundStyle(Color.dark)
                }
                input
                    .font(.poppins(16))
                    .foregroundStyle(Color.dark)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .textInputAutocapitalization(isSecure ? .never : capitalization)
                    .autocorrectionDisabled(isSecure || keyboard != .default)
                    .focused($focused)
                if isSecure {
                    Button(revealed ? "Hide" : "Show") { revealed.toggle() }
                        .font(.poppins(13, .bold))
                        .foregroundStyle(Color.gold)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, multiline ? 12 : 0)
            .frame(minHeight: 54)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error.isEmpty ? (focused ? Color.gold : Color.line) : Color.sellRed, lineWidth: focused ? 2 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
            if !error.isEmpty {
                Text(error)
                    .font(.poppins(12))
                    .foregroundStyle(Color.sellRed)
            }
        }
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var input: some View {
        if isSecure && !revealed {
            SecureField("", text: $text)
        } else if multiline {
            TextField("", text: $text, axis: .vertical)
                .lineLimit(1...6)
        } else {
            TextField("", text: $text)
        }
    }
}

struct MobileField: View {
    @Binding var text: String
    var error = ""

    var body: some View {
        AppField(
            label: "Mobile number",
            text: $text,
            error: error,
            keyboard: .numberPad,
            contentType: .telephoneNumber,
            capitalization: .never,
            prefix: "+91"
        )
        .onChange(of: text) { _, value in
            let clean = value.indianMobileDigits
            if clean != value { text = clean }
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var loading = false
    var color: Color = .gold
    let action: () -> Void

    var body: some View {
        Button {
            hideKeyboard()
            action()
        } label: {
            ZStack {
                if loading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.poppins(15, .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color.opacity(loading ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .disabled(loading)
    }
}

struct FilledButton: View {
    let title: String
    var systemImage: String?
    var imageAsset: String?
    var color: Color = .gold
    var cornerRadius: CGFloat = 18
    var height: CGFloat = 50
    var fontSize: CGFloat = 14
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 15, weight: .semibold))
                }
                Text(title).font(.poppins(fontSize, .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(color, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

struct OutlineButton: View {
    let title: String
    var enabled = true
    var cornerRadius: CGFloat = 14
    var height: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.poppins(14, .bold))
                .foregroundStyle(Color.dark.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.line, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct MessageText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.poppins(14, .bold))
            .foregroundStyle(Color.gold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
    }
}

struct ErrorCard: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("!")
                .font(.poppins(16, .extraBold))
                .foregroundStyle(Color.sellRed)
                .frame(width: 36, height: 36)
                .background(Color.sellRed.opacity(0.1), in: Circle())
            Text(text)
                .font(.poppins(13, .bold))
                .foregroundStyle(Color.dark)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct EmptyCard: View {
    let text: String

    var body: some View {
        Panel {
            Text(text)
                .font(.poppins(15))
                .foregroundStyle(Color.dark)
        }
    }
}

struct LoadingBox: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .tint(.gold)
            .frame(maxWidth: .infinity)
            .padding(24)
    }
}

struct StockBadge: View {
    let inStock: Bool

    var body: some View {
        let color: Color = inStock ? .buyGreen : .sellRed
        Text(inStock ? "In stock" : "Sold out")
            .font(.poppins(12, .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct IconBadge: View {
    let systemImage: String
    var size: CGFloat = 36
    var iconSize: CGFloat = 17
    var color: Color = .gold

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSize, weight: .medium))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.12), in: Circle())
    }
}

struct InfoLine: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemImage: systemImage)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.poppins(13, .bold))
                    .foregroundStyle(Color.muted)
                Text(value)
                    .font(.poppins(15, .bold))
                    .foregroundStyle(Color.dark)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

struct FilterChip: View {
    let label: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.poppins(12, .extraBold))
                .foregroundStyle(active ? Color.gold : Color.textDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(active ? Color.gold.opacity(0.14) : Color.white, in: Capsule())
                .overlay(Capsule().stroke(active ? Color.gold : Color.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct PriceLine: View {
    let price: String
    let oldPrice: String
    var size: CGFloat = 18
    var oldSize: CGFloat = 12

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("Rs. \(price)")
                .font(.poppins(size, .extraBold))
                .foregroundStyle(Color.gold)
            if !oldPrice.isBlank {
                Text("Rs. \(oldPrice)")
                    .font(.poppins(oldSize))
                    .strikethrough()
                    .foregroundStyle(Color.muted)
            }
        }
    }
}

struct ChevronBadge: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.gold)
            .frame(width: 30, height: 30)
            .background(Color.gold.opacity(0.16), in: Circle())
    }
}

struct BackCircleButton: View {
    var size: CGFloat = 42
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textDark)
                .frame(width: size, height: size)
                .background(Color.softSurface, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

struct RemoteImage: View {
    let url: String
    var placeholderIcon: String?

    var body: some View {
        Color.softSurface
            .overlay {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    default:
                        if url.isEmpty { placeholder } else { ProgressView().tint(.gold) }
                    }
                }
            }
            .clipped()
    }

    @ViewBuilder
    private var placeholder: some View {
        if let placeholderIcon {
            Image(systemName: placeholderIcon)
                .font(.system(size: 30))
                .foregroundStyle(Color.gold)
        }
    }
}

struct OmBackground: View {
    var overlayOpacity: Double = 0.68

    var body: some View {
        ZStack {
            Color.dark
            Image("SplashBackground")
                .resizable()
                .scaledToFill()
            Color.dark.opacity(overlayOpacity)
        }
        .ignoresSafeArea()
    }
}

struct AppLogo: View {
    var size: CGFloat
    var background: Color = .white

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(background)
            .clipShape(Circle())
            .accessibilityLabel("Shree Rudra Bullion")
    }
}

/// Horizontal row that advances by one item on a timer, like HorizontalCards / ServiceStrip on Android.
struct AutoScrollRow<Content: View>: View {
    let count: Int
    var spacing: CGFloat = 12
    var interval: Duration = .milliseconds(2400)
    var animation: Animation = .easeInOut(duration: 0.65)
    @ViewBuilder let content: (Int) -> Content

    @State private var position: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { index in
                    content(index).id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $position, anchor: .leading)
        .task(id: count) {
            guard count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { break }
                let current = position ?? 0
                withAnimation(animation) {
                    position = current >= count - 1 ? 0 : current + 1
                }
            }
        }
    }
}

@MainActor
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
