import SwiftUI

struct LoginForm: View {
    let onSignup: () -> Void
    let onForgotPassword: () -> Void
    let onBack: () -> Void

    @State private var mobile = ""
    @State private var password = ""
    @State private var message = ""
    @State private var loading = false
    @State private var mobileError = ""
    @State private var passwordError = ""

    var body: some View {
        AuthPanel {
            AuthFormHeader(
                title: "Sign in",
                subtitle: "Access live bullion rates, products, and account tools.",
                onBack: onBack
            )
            MobileField(text: $mobile, error: mobileError)
                .onChange(of: mobile) { mobileError = "" }
            AppField(label: "Password", text: $password, isSecure: true, error: passwordError, contentType: .password)
                .onChange(of: password) { passwordError = "" }
            HStack {
                Spacer()
                Button("Forgot password?", action: onForgotPassword)
                    .font(.poppins(13, .bold))
                    .foregroundStyle(Color.gold)
            }
            .padding(.bottom, 18)
            PrimaryButton(title: "Sign in", loading: loading, action: submit)
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .font(.poppins(13))
                    .foregroundStyle(Color.muted)
                Button("Sign up", action: onSignup)
                    .font(.poppins(14, .extraBold))
                    .foregroundStyle(Color.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)
            if !message.isEmpty {
                MessageText(text: message)
            }
        }
    }

    private func submit() {
        let cleanMobile = mobile.indianMobileDigits
        mobileError = cleanMobile.isValidIndianMobile ? "" : "Enter a valid 10 digit mobile number."
        passwordError = password.count < 6 ? "Password must be at least 6 characters." : ""
        guard mobileError.isEmpty, passwordError.isEmpty else { return }
        Task {
            loading = true
            message = ""
            do {
                let response = try await API.login(LoginRequest(mobile: cleanMobile, password: password))
                SessionStore.shared.setSession(response)
            } catch {
                message = ErrorMessage.api(error, fallback: "Invalid mobile number or password.")
            }
            loading = false
        }
    }
}

struct SignupForm: View {
    let onBack: () -> Void
    let onLogin: () -> Void

    @State private var name = ""
    @State private var mobile = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var successMessage = ""
    @State private var loading = false
    @State private var nameError = ""
    @State private var mobileError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""

    var body: some View {
        AuthPanel {
            AuthFormHeader(
                title: "Create account",
                subtitle: "Submit your request. Access is enabled after admin approval.",
                onBack: onBack
            )
            AppField(label: "Full name", text: $name, error: nameError, contentType: .name, capitalization: .words)
                .onChange(of: name) { nameError = "" }
            MobileField(text: $mobile, error: mobileError)
                .onChange(of: mobile) { mobileError = "" }
            AppField(label: "Password", text: $password, isSecure: true, error: passwordError, contentType: .newPassword)
                .onChange(of: password) { passwordError = "" }
            AppField(label: "Confirm password", text: $confirmPassword, isSecure: true, error: confirmPasswordError, contentType: .newPassword)
                .onChange(of: confirmPassword) { confirmPasswordError = "" }
            PrimaryButton(title: "Send Request", loading: loading, action: submit)
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(.poppins(13))
                    .foregroundStyle(Color.muted)
                Button("Sign in", action: onLogin)
                    .font(.poppins(14, .extraBold))
                    .foregroundStyle(Color.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)
            if !message.isEmpty {
                MessageText(text: message)
            }
        }
        .timedSuccessAlert("Request Submitted", message: $successMessage, onFinish: onLogin)
    }

    private func submit() {
        let cleanMobile = mobile.indianMobileDigits
        nameError = name.trimmingCharacters(in: .whitespaces).count < 3 ? "Enter your full name." : ""
        mobileError = cleanMobile.isValidIndianMobile ? "" : "Enter a valid 10 digit mobile number."
        passwordError = password.count < 6 ? "Password must be at least 6 characters." : ""
        confirmPasswordError = confirmPassword != password ? "Password and confirm password must match." : ""
        guard [nameError, mobileError, passwordError, confirmPasswordError].allSatisfy(\.isEmpty) else { return }
        Task {
            loading = true
            message = ""
            do {
                let response = try await API.signupRequest(
                    SignupRequest(
                        name: name.trimmingCharacters(in: .whitespaces),
                        mobile: cleanMobile,
                        password: password,
                        confirmPassword: confirmPassword,
                        fcmToken: SessionStore.shared.fcmToken
                    )
                )
                SessionStore.shared.setPendingSignup(cleanMobile)
                ApprovalChecker.schedule()
                successMessage = response.message.ifBlank("Your request has been submitted successfully.")
            } catch {
                message = ErrorMessage.api(error, fallback: "Unable to submit request. Please check details and try again.")
            }
            loading = false
        }
    }
}

struct ForgotPasswordForm: View {
    let onBack: () -> Void
    let onLogin: () -> Void

    @State private var mobile = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var successMessage = ""
    @State private var loading = false
    @State private var mobileError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""

    var body: some View {
        AuthPanel {
            AuthFormHeader(
                title: "Reset password",
                subtitle: "Enter your approved mobile number and choose a new password.",
                onBack: onBack
            )
            MobileField(text: $mobile, error: mobileError)
                .onChange(of: mobile) { mobileError = "" }
            AppField(label: "New password", text: $password, isSecure: true, error: passwordError, contentType: .newPassword)
                .onChange(of: password) { passwordError = "" }
            AppField(label: "Confirm password", text: $confirmPassword, isSecure: true, error: confirmPasswordError, contentType: .newPassword)
                .onChange(of: confirmPassword) { confirmPasswordError = "" }
            PrimaryButton(title: "Reset Password", loading: loading, action: submit)
            if !message.isEmpty {
                MessageText(text: message)
            }
        }
        .timedSuccessAlert("Password Reset Successful", message: $successMessage, onFinish: onLogin)
    }

    private func submit() {
        let cleanMobile = mobile.indianMobileDigits
        mobileError = cleanMobile.isValidIndianMobile ? "" : "Enter a valid 10 digit mobile number."
        passwordError = password.count < 6 ? "Password must be at least 6 characters." : ""
        confirmPasswordError = confirmPassword != password ? "Password and confirm password must match." : ""
        guard [mobileError, passwordError, confirmPasswordError].allSatisfy(\.isEmpty) else { return }
        Task {
            loading = true
            message = ""
            do {
                _ = try await API.forgotPassword(ForgotPasswordRequest(mobile: cleanMobile, password: password, confirmPassword: confirmPassword))
                successMessage = "Your password has been reset successfully. Please sign in with your new password."
            } catch {
                message = ErrorMessage.api(error, fallback: "Unable to reset password. Please check details and try again.")
            }
            loading = false
        }
    }
}

private extension View {
    /// Success alert that moves on by itself after 5 seconds, like the Android dialog.
    func timedSuccessAlert(_ title: String, message: Binding<String>, onFinish: @escaping () -> Void) -> some View {
        let isPresented = Binding(
            get: { !message.wrappedValue.isEmpty },
            set: { presented in
                if !presented && !message.wrappedValue.isEmpty {
                    message.wrappedValue = ""
                    onFinish()
                }
            }
        )
        return alert(title, isPresented: isPresented) {
            Button("OK") {}
        } message: {
            Text(message.wrappedValue)
        }
        .task(id: message.wrappedValue) {
            guard !message.wrappedValue.isEmpty else { return }
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled, !message.wrappedValue.isEmpty else { return }
            message.wrappedValue = ""
            onFinish()
        }
    }
}
