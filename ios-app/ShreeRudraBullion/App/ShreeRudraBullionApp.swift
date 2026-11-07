import SwiftUI

@main
struct ShreeRudraBullionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(SessionStore.shared)
                .tint(.gold)
                .preferredColorScheme(.light)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                ApprovalChecker.schedule()
            }
        }
    }
}

/// Splash → Auth / Signed out / Dashboard, same flow as ShreeRudraApp() on Android.
struct RootView: View {
    @Environment(SessionStore.self) private var session
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if session.isLoggedIn {
                DashboardView()
                    .transition(.opacity)
            } else if !session.signedOutMessage.isEmpty {
                SignedOutView(message: session.signedOutMessage) {
                    session.signedOutMessage = ""
                }
                .transition(.opacity)
            } else {
                AuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showSplash)
        .animation(.easeInOut(duration: 0.25), value: session.isLoggedIn)
        .task {
            try? await Task.sleep(for: .milliseconds(3400))
            showSplash = false
        }
    }
}
