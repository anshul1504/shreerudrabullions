import SwiftUI

struct AboutView: View {
    @State private var data: AboutInfo?
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let about = data {
                AboutHero(about: about)
                    .padding(.bottom, 14)
                AboutValueCard(eyebrow: "Our Direction", title: about.visionTitle, bodyText: about.visionText, systemImage: "checkmark.shield")
                    .padding(.bottom, 12)
                AboutValueCard(eyebrow: "Our Promise", title: about.missionTitle, bodyText: about.missionText, systemImage: "rosette")
                    .padding(.bottom, 14)
                AboutStoryCard(about: about)
                if !about.testimonials.isEmpty {
                    SectionTitle(eyebrow: "Client Feedback", title: "What Our Clients Say")
                        .padding(.top, 16)
                    AutoScrollRow(count: about.testimonials.count) { index in
                        TestimonialCard(testimonial: about.testimonials[index])
                            .frame(width: 300)
                    }
                }
            } else if !error.isEmpty {
                ErrorCard(text: error)
            } else {
                LoadingBox()
            }
        }
        .task {
            guard data == nil else { return }
            do {
                data = try await API.about()
                error = ""
            } catch {
                self.error = ErrorMessage.network(error, fallback: "About content is currently unavailable.")
            }
        }
    }
}

struct AboutHero: View {
    let about: AboutInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ABOUT US")
                .font(.poppins(13, .extraBold))
                .foregroundStyle(Color.gold)
                .padding(.bottom, 8)
            Text(about.headerTitle.ifBlank("Shree Rudra Bullion & Jewels"))
                .font(.poppins(25, .extraBold))
                .foregroundStyle(.white)
            if !about.headerSubtitle.isBlank {
                Text(about.headerSubtitle)
                    .font(.poppins(15))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(22)
        // At least 220 pt tall, and taller when the admin's subtitle needs more lines.
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .bottomLeading)
        .background {
            ZStack {
                Color.dark
                if !about.headerBackground.isEmpty {
                    RemoteImage(url: about.headerBackground)
                    Color.black.opacity(0.46)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

struct AboutValueCard: View {
    let eyebrow: String
    let title: String
    let bodyText: String
    let systemImage: String

    var body: some View {
        BorderedCard {
            IconBadge(systemImage: systemImage, size: 38, iconSize: 18)
                .padding(.bottom, 12)
            Text(eyebrow.uppercased())
                .font(.poppins(13, .extraBold))
                .foregroundStyle(Color.gold)
            Text(title.ifBlank("-"))
                .font(.poppins(19, .extraBold))
                .foregroundStyle(Color.dark)
            Text(HTMLText.plainText(bodyText).ifBlank("-"))
                .font(.poppins(15))
                .foregroundStyle(Color.muted)
                .padding(.top, 6)
        }
    }
}

struct AboutStoryCard: View {
    let about: AboutInfo

    var body: some View {
        BorderedCard(cornerRadius: 26, padding: 18) {
            if !about.whoImage.isEmpty {
                RemoteImage(url: about.whoImage)
                    .frame(maxWidth: .infinity)
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom, 16)
            }
            Text("WHO WE ARE")
                .font(.poppins(13, .extraBold))
                .foregroundStyle(Color.gold)
            Text(about.whoTitle.ifBlank("Who We Are"))
                .font(.poppins(21, .extraBold))
                .foregroundStyle(Color.dark)
            if !about.whoSubtitle.isBlank {
                Text(about.whoSubtitle)
                    .font(.poppins(14, .bold))
                    .foregroundStyle(Color.gold)
                    .padding(.top, 6)
            }
            Text(HTMLText.plainText(about.whoDescription).ifBlank("-"))
                .font(.poppins(15))
                .foregroundStyle(Color.muted)
                .padding(.top, 8)
        }
    }
}
