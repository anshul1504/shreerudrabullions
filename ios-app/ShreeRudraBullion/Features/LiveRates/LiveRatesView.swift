import SwiftUI

struct LiveRatesView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var data: LiveRatesResponse?
    @State private var error = ""
    @State private var loading = true
    @State private var movements: [String: Int] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LiveRatesHeader(loading: loading) {
                Task { await refresh(showLoader: true) }
            }
            .padding(.bottom, 12)

            if !error.isEmpty && data == nil {
                ErrorCard(text: error)
            } else if loading && data == nil {
                LoadingBox()
            } else if let rates = data {
                if !error.isEmpty {
                    MessageText(text: error)
                }
                RateTableHeader()
                ForEach(rates.rows) { row in
                    RateRowCard(
                        row: row,
                        buyMovement: movements["\(row.key):buy"] ?? 0,
                        sellMovement: movements["\(row.key):sell"] ?? 0
                    )
                }
                if rates.rows.isEmpty {
                    EmptyCard(text: "Live rates are currently unavailable. Please check back shortly.")
                }
                Text("Rates are indicative and may change without notice. Please confirm final dealing rates with the bullion desk before placing an order.")
                    .font(.poppins(11))
                    .foregroundStyle(Color.muted)
                    .padding(.top, 12)
            }
        }
        .task(id: scenePhase) {
            // Poll every 3 s while the tab is visible and the app is in the foreground.
            guard scenePhase == .active else { return }
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    private func refresh(showLoader: Bool = false) async {
        if showLoader || data == nil { loading = true }
        do {
            let response = try await API.liveRates()
            let previous = Dictionary((data?.rows ?? []).map { ($0.key, $0) }, uniquingKeysWith: { first, _ in first })
            var next: [String: Int] = [:]
            for row in response.rows {
                next["\(row.key):buy"] = RateMovement.compare(row.buy, previous[row.key]?.buy)
                next["\(row.key):sell"] = RateMovement.compare(row.sell, previous[row.key]?.sell)
            }
            movements = next
            data = response
            error = ""
        } catch is CancellationError {
        } catch APIError.network(let urlError) where urlError.code == .cancelled {
        } catch {
            // A 401 that cannot be refreshed already signed the user out in APIClient.
            self.error = ErrorMessage.network(error, fallback: "Live rates are currently unavailable.")
        }
        loading = false
    }
}

struct RateTableHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Product")
                .font(.poppins(13, .extraBold))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Buy")
                .font(.poppins(14, .extraBold))
                .frame(maxWidth: .infinity)
            Text("Sell")
                .font(.poppins(14, .extraBold))
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.dark, in: RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 8)
    }
}

struct RateRowCard: View {
    let row: RateRow
    let buyMovement: Int
    let sellMovement: Int

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(row.label)
                    .font(.poppins(14, .extraBold))
                    .foregroundStyle(Color.dark)
                    .fixedSize(horizontal: false, vertical: true)
                if !row.unit.isEmpty {
                    Text(row.unit)
                        .font(.poppins(10, .extraBold))
                        .foregroundStyle(Color.muted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.softSurface, in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            RateBox(value: row.buy, color: .buyGreen, movement: buyMovement)
            RateBox(value: row.sell, color: .sellRed, movement: sellMovement)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white).shadow(color: .black.opacity(0.06), radius: 3, y: 1))
        .padding(.bottom, 9)
        .accessibilityElement(children: .combine)
    }
}

struct RateBox: View {
    let value: String
    let color: Color
    let movement: Int

    var body: some View {
        let moved = movement != 0 && !value.isBlank
        // Rate went up: green, went down: red. Only the number is highlighted; the box keeps its colour.
        let highlight: Color = movement > 0 ? .flashUp : .flashDown
        Text(value.isBlank ? "-" : value)
            .font(.poppins(16, .extraBold))
            .foregroundStyle(moved ? highlight : color)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(moved ? highlight.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 4)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(color.opacity(0.11), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.22), lineWidth: 1))
            .animation(.easeOut(duration: 0.25), value: moved)
    }
}

struct LiveRatesHeader: View {
    let loading: Bool
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AppLogo(size: 52, background: .surface)
            Text("Live Rates")
                .font(.poppins(20, .extraBold))
                .foregroundStyle(Color.textDark)
            Spacer(minLength: 8)
            Button(action: onRefresh) {
                HStack(spacing: 6) {
                    if loading {
                        ProgressView().tint(.white).controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Refresh")
                            .font(.poppins(12, .extraBold))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.dark.opacity(loading ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(loading)
            .accessibilityLabel("Refresh live rates")
        }
        .padding(14)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.line.opacity(0.5), lineWidth: 1))
    }
}
