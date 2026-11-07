import SwiftUI

enum AuthMode {
    case welcome, login, signup, forgotPassword
}

struct AuthView: View {
    @State private var mode: AuthMode = .welcome
    @State private var approvalMessage = ""

    var body: some View {
        ZStack {
            OmBackground()
            Color(hex: 0x111318, opacity: 0.69).ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        if !approvalMessage.isEmpty {
                            MessageText(text: approvalMessage)
                        }
                        Group {
                            switch mode {
                            case .welcome:
                                WelcomeView(onLogin: { mode = .login }, onSignup: { mode = .signup })
                            case .login:
                                LoginForm(
                                    onSignup: { mode = .signup },
                                    onForgotPassword: { mode = .forgotPassword },
                                    onBack: { mode = .welcome }
                                )
                            case .signup:
                                SignupForm(onBack: { mode = .welcome }, onLogin: { mode = .login })
                            case .forgotPassword:
                                ForgotPasswordForm(onBack: { mode = .login }, onLogin: { mode = .login })
                            }
                        }
                        .transition(.opacity)
                    }
                    .padding(24)
                    .frame(minHeight: geometry.size.height)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(.basedOnSize)
            }
            .animation(.easeInOut(duration: 0.2), value: mode)
        }
        .task {
            // Same 15 s approval polling as AuthScreen on Android.
            while !Task.isCancelled {
                let mobile = SessionStore.shared.pendingSignupMobile
                if !mobile.isEmpty, let status = try? await API.signupStatus(mobile: mobile) {
                    if status.status == "approved" {
                        SessionStore.shared.setPendingSignup("")
                        approvalMessage = status.message
                        AppNotifier.showApproved()
                    } else if status.status == "rejected" {
                        SessionStore.shared.setPendingSignup("")
                        approvalMessage = status.message
                    }
                }
                try? await Task.sleep(for: .seconds(15))
            }
        }
    }
}

struct WelcomeView: View {
    let onLogin: () -> Void
    let onSignup: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppLogo(size: 158)
            Text("Welcome Back")
                .font(.poppins(32, .extraBold))
                .foregroundStyle(.white)
                .padding(.top, 28)
            Text("Access live bullion rates and products")
                .font(.poppins(14))
                .foregroundStyle(.white.opacity(0.82))
            Button(action: onLogin) {
                Text("SIGN IN")
                    .font(.poppins(15, .extraBold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1))
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 34)
            Button(action: onSignup) {
                Text("SIGN UP")
                    .font(.poppins(15, .extraBold))
                    .foregroundStyle(Color.dark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            Text("Developed by The Webfix")
                .font(.poppins(12, .bold))
                .foregroundStyle(.white.opacity(0.72))
                .padding(.top, 32)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct AuthPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.line.opacity(0.55), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
    }
}

struct AuthFormHeader: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            BackCircleButton(action: onBack)
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.poppins(26, .extraBold))
                    .foregroundStyle(Color.dark)
                Text(subtitle)
                    .font(.poppins(14))
                    .foregroundStyle(Color.muted)
            }
        }
        .padding(.bottom, 20)
    }
}

struct SignedOutView: View {
    let message: String
    let onSignInAgain: () -> Void

    var body: some View {
        ZStack {
            OmBackground()
            Color(hex: 0x111318, opacity: 0.69).ignoresSafeArea()
            VStack(spacing: 0) {
                AppLogo(size: 92, background: .surface)
                Text("Sign in required")
                    .font(.poppins(22, .extraBold))
                    .foregroundStyle(Color.dark)
                    .padding(.top, 16)
                Text(message)
                    .font(.poppins(15))
                    .foregroundStyle(Color.muted)
                    .padding(.top, 8)
                PrimaryButton(title: "Sign in again", action: onSignInAgain)
                    .padding(.top, 20)
            }
            .multilineTextAlignment(.center)
            .padding(24)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 28))
            .padding(24)
        }
    }
}

#Preview {
    AuthView()
        .environment(SessionStore.shared)
}
