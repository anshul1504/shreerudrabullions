import SwiftUI

struct EditProfileSection: View {
    @State private var name = SessionStore.shared.userName.ifBlank("Customer").titleCased
    @State private var mobile = SessionStore.shared.mobile
    @State private var city = ""
    @State private var requestNote = ""
    @State private var message = ""
    @State private var loading = false

    var body: some View {
        Panel {
            Text("Edit Profile")
                .font(.poppins(18, .extraBold))
                .foregroundStyle(Color.dark)
            Text("Changes will be sent for admin approval before they appear on your account.")
                .font(.poppins(14))
                .foregroundStyle(Color.muted)
                .padding(.bottom, 14)
            AppField(label: "Name", text: $name, contentType: .name, capitalization: .words)
            MobileField(text: $mobile)
            AppField(label: "City", text: $city, contentType: .addressCity, capitalization: .words)
            AppField(label: "Requested changes", text: $requestNote, multiline: true)
            PrimaryButton(title: "Submit For Approval", loading: loading, action: submit)
            if !message.isEmpty {
                MessageText(text: message)
            }
        }
        .onChange(of: [name, mobile, city, requestNote]) { message = "" }
    }

    private func submit() {
        if name.trimmingCharacters(in: .whitespaces).count < 3 {
            message = "Please enter your full name."
            return
        }
        if mobile.indianMobileDigits.count != 10 {
            message = "Please enter a valid 10 digit mobile number."
            return
        }
        Task {
            loading = true
            do {
                _ = try await API.profileUpdateRequest(
                    ProfileUpdateRequest(
                        name: name.titleCased,
                        mobile: mobile.indianMobileDigits,
                        city: city.titleCased,
                        message: requestNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                )
                message = "Your profile changes have been submitted for admin approval."
            } catch {
                message = ErrorMessage.api(error, fallback: "Unable to submit profile changes right now.")
            }
            loading = false
        }
    }
}

struct ResetPasswordSection: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var loading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(eyebrow: "Security", title: "Reset Password")
            Panel {
                Text("Set a new password for your approved mobile account.")
                    .font(.poppins(13))
                    .foregroundStyle(Color.muted)
                    .padding(.bottom, 12)
                AppField(label: "New password", text: $password, isSecure: true, contentType: .newPassword)
                AppField(label: "Confirm password", text: $confirmPassword, isSecure: true, contentType: .newPassword)
                PrimaryButton(title: "Reset Password", loading: loading, action: submit)
                if !message.isEmpty {
                    MessageText(text: message)
                }
            }
        }
    }

    private func submit() {
        if password != confirmPassword {
            message = "Password and confirm password must match."
            return
        }
        Task {
            loading = true
            message = ""
            do {
                _ = try await API.forgotPassword(
                    ForgotPasswordRequest(mobile: SessionStore.shared.mobile, password: password, confirmPassword: confirmPassword)
                )
                password = ""
                confirmPassword = ""
                message = "Your password has been reset successfully."
            } catch {
                message = ErrorMessage.api(error, fallback: "Unable to reset password. Please check the details and try again.")
            }
            loading = false
        }
    }
}

struct DeleteAccountSection: View {
    @State private var password = ""
    @State private var reason = ""
    @State private var message = ""
    @State private var loading = false
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(eyebrow: "Security", title: "Delete Account")
            Panel {
                Text("This will permanently remove your app account and login access. Enter your current password to confirm.")
                    .font(.poppins(13))
                    .foregroundStyle(Color.muted)
                    .padding(.bottom, 12)
                AppField(label: "Current password", text: $password, isSecure: true, contentType: .password)
                AppField(label: "Reason (optional)", text: $reason, multiline: true)
                PrimaryButton(title: "Delete Account", loading: loading, color: .sellRed) {
                    if password.isEmpty {
                        message = "Please enter your current password."
                    } else {
                        confirmDelete = true
                    }
                }
                if !message.isEmpty {
                    MessageText(text: message)
                }
            }
        }
        .onChange(of: [password, reason]) { message = "" }
        .alert("Delete account permanently?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: submit)
        } message: {
            Text("Your account and login access will be removed. This cannot be undone.")
        }
    }

    private func submit() {
        Task {
            loading = true
            message = ""
            do {
                _ = try await API.deleteAccount(DeleteAccountRequest(currentPassword: password, reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)))
                SessionStore.shared.signOut()
            } catch {
                message = ErrorMessage.api(error, fallback: "Unable to delete your account right now.")
            }
            loading = false
        }
    }
}

struct SupportSection: View {
    @State private var contact: ContactInfo?
    @State private var subject = "Bullion enquiry"
    @State private var enquiry = ""
    @State private var message = ""
    @State private var loading = false

    private var primaryPhone: String {
        contact?.primaryPhone.ifBlank(SessionStore.shared.mobile) ?? SessionStore.shared.mobile
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Text("SUPPORT DESK")
                    .font(.poppins(11, .extraBold))
                    .foregroundStyle(Color.gold)
                Text("How can we help?")
                    .font(.poppins(24, .extraBold))
                    .foregroundStyle(.white)
                Text("Reach our team for live rates, product enquiries, profile help, or account support.")
                    .font(.poppins(13))
                    .foregroundStyle(.white.opacity(0.72))
                HStack(spacing: 10) {
                    FilledButton(title: "Call", systemImage: "phone", color: .gold) {
                        ExternalLinks.dial(primaryPhone)
                    }
                    FilledButton(title: "WhatsApp", systemImage: "bubble.left", color: .buyGreen) {
                        ExternalLinks.whatsApp(primaryPhone)
                    }
                }
                .padding(.top, 16)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.dark, in: RoundedRectangle(cornerRadius: 28))

            Panel {
                InfoLine(label: "Phone", value: primaryPhone.ifBlank("-"), systemImage: "phone")
                if let email = contact?.email, !email.isBlank {
                    Button { ExternalLinks.email(email) } label: {
                        InfoLine(label: "Email", value: email, systemImage: "envelope")
                    }
                    .buttonStyle(.plain)
                }
                if let address = contact?.address, !address.isBlank {
                    InfoLine(label: "Address", value: address, systemImage: "mappin.and.ellipse")
                }
            }

            Panel {
                Text("Send an enquiry")
                    .font(.poppins(18, .extraBold))
                    .foregroundStyle(Color.dark)
                Text("Your message will be visible in admin with your account details.")
                    .font(.poppins(14))
                    .foregroundStyle(Color.muted)
                    .padding(.bottom, 10)
                AppField(label: "Subject", text: $subject)
                AppField(label: "Message", text: $enquiry, multiline: true)
                PrimaryButton(title: "Submit Enquiry", loading: loading, action: submit)
                if !message.isEmpty {
                    MessageText(text: message)
                }
            }
        }
        .task {
            contact = try? await API.contact()
        }
    }

    private func submit() {
        let text = enquiry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            message = "Please enter your enquiry message."
            return
        }
        Task {
            loading = true
            message = ""
            do {
                _ = try await API.submitContact(
                    ContactRequest(
                        name: SessionStore.shared.userName.ifBlank("App Customer"),
                        email: "",
                        phone: SessionStore.shared.mobile,
                        subject: subject.trimmingCharacters(in: .whitespaces).ifBlank("App enquiry"),
                        message: text
                    )
                )
                enquiry = ""
                message = "Your enquiry has been submitted successfully."
            } catch {
                message = ErrorMessage.network(error, fallback: "Unable to submit your enquiry right now.")
            }
            loading = false
        }
    }
}

struct PrivacyPolicySection: View {
    private let blocks: [(String, String)] = [
        ("Information You Provide Directly", "We may collect information you provide when you sign up, log in, update your profile, upload a profile image, submit a support form, call us, message us on WhatsApp, request live rates, or otherwise communicate with us. This may include name, phone number, address or location details, inquiry details, product interest, bullion rate requirements, profile image, and message content."),
        ("Information Collected Automatically", "When you use the app or website, some technical information may be collected automatically to help operate, secure, and improve the service. This may include IP address, device information, operating system, pages or screens viewed, links clicked, date, time, duration of visits, and standard server log information."),
        ("Information From Other Sources", "We may receive limited information from publicly available sources, business partners, website analytics providers, bullion rate data providers, or communication platforms where you contact us, as permitted by applicable law."),
        ("How We Use Information", "We may use collected information to respond to inquiries and support requests, provide rate-related, product-related, jewellery-related, or service-related information, improve app and website performance, maintain internal records, send important updates where legally permitted, and protect against misuse, fraud, unauthorized activity, or security risks."),
        ("Sharing of Information", "We do not sell your personal information. We may share information only when reasonably necessary with service providers who help operate the app or website, manage hosting, process enquiries, or respond to customer requests; to comply with legal obligations or valid government requests; or to protect our rights, customers, business operations, security, or lawful interests."),
        ("Marketing and Communication Choices", "If you receive promotional or service-related communications from us, you may request that we stop sending non-essential communications. You may also contact us directly to update or correct the information you have shared with us."),
        ("Data Security", "We use reasonable administrative, technical, and physical safeguards to protect information from unauthorized access, misuse, loss, or disclosure. However, no internet-based system or method of electronic storage can be guaranteed to be completely secure."),
        ("Links to Other Services", "The app or website may contain links to third-party services including WhatsApp, payment, map, social media, analytics, or rate-related services. We are not responsible for the privacy practices, security, or content of those third-party services."),
        ("Children's Privacy", "Our app and website are not intended for children, and we do not knowingly collect personal information from children."),
        ("Changes to This Policy", "We may update this Privacy Policy from time to time to reflect changes in our practices, app or website functionality, or legal requirements. Updated versions will be posted with the revised effective date."),
        ("Contact Us", "For privacy-related questions or requests, please contact Shree Rudra Bullion & Jewels through the contact details available in the app."),
    ]

    var body: some View {
        Panel {
            Text("Overview")
                .font(.poppins(13, .extraBold))
                .foregroundStyle(Color.gold)
            Text("Privacy Policy")
                .font(.poppins(21, .extraBold))
                .foregroundStyle(Color.dark)
                .padding(.bottom, 8)
            Text("Shree Rudra Bullion & Jewels is committed to protecting your privacy and handling personal information responsibly. This Privacy Policy explains what information may be collected through our app and website, how that information may be used, and the choices available to you.\n\nBy using this app, contacting us, or sharing your information with us, you agree to the practices described in this Privacy Policy.\n\nEffective date: May 5, 2026")
                .font(.poppins(15))
                .foregroundStyle(Color.muted)
            ForEach(blocks, id: \.0) { title, body in
                Text(title)
                    .font(.poppins(16, .extraBold))
                    .foregroundStyle(Color.dark)
                    .padding(.top, 16)
                    .padding(.bottom, 6)
                Text(body)
                    .font(.poppins(15))
                    .foregroundStyle(Color.muted)
            }
        }
    }
}
