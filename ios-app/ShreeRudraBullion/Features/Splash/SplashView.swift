import SwiftUI

struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.dark.ignoresSafeArea()
            Image("SplashBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Color.dark.opacity(0.18).ignoresSafeArea()

            VStack(spacing: 0) {
                AppLogo(size: 138)
                    .overlay(Circle().stroke(Color.white.opacity(0.72), lineWidth: 1))
                Text("SHREE RUDRA BULLION")
                    .font(.poppins(16, .extraBold))
                    .foregroundStyle(.white)
                    .padding(.top, 14)
                Text("Purity • Trust • Live Rates")
                    .font(.poppins(12))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.top, 6)
            }
            .multilineTextAlignment(.center)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? -137 : -420)

            VStack {
                Spacer()
                ProgressView()
                    .tint(.white.opacity(0.85))
                    .padding(.bottom, 54)
            }
        }
        .onAppear {
            withAnimation(.timingCurve(0.4, 0, 0.2, 1, duration: 1.35)) {
                animate = true
            }
        }
    }
}

#Preview {
    SplashView()
}
