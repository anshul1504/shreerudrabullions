import SwiftUI

enum ProfileSection {
    case menu, edit, password, delete, support, privacy

    var title: String {
        switch self {
        case .menu: "Profile"
        case .edit: "Edit Profile"
        case .password: "Reset Password"
        case .delete: "Delete Account"
        case .support: "Help & Support"
        case .privacy: "Privacy Policy"
        }
    }
}

struct ProfileView: View {
    let resetSignal: Int

    @Environment(SessionStore.self) private var session
    @State private var section: ProfileSection = .menu
    @State private var showLogoutDialog = false

    private var displayName: String {
        session.userName.ifBlank("Customer").titleCased
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfileTopBar(title: section.title, showBack: section != .menu) {
                section = .menu
            }
            ProfilePhoto(name: displayName)
                .padding(.top, 20)
            Text(displayName)
                .font(.poppins(20, .extraBold))
                .foregroundStyle(Color.textDark)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            Text("+91 \(session.mobile)")
                .font(.poppins(12, .bold))
                .foregroundStyle(Color.muted)
                .padding(.bottom, 24)

            Group {
                switch section {
                case .edit: EditProfileSection()
                case .password: ResetPasswordSection()
                case .delete: DeleteAccountSection()
                case .support: SupportSection()
                case .privacy: PrivacyPolicySection()
                case .menu: menu
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .onChange(of: resetSignal) {
            section = .menu
        }
        .alert("Logout?", isPresented: $showLogoutDialog) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive) {
                session.signOut()
            }
        } message: {
            Text("Do you really want to logout?")
        }
    }

    private var menu: some View {
        VStack(spacing: 0) {
            ProfileMenuRow(label: "Edit Profile", systemImage: "pencil") { section = .edit }
            ProfileMenuRow(label: "Reset Password", systemImage: "lock.shield") { section = .password }
            ProfileMenuRow(label: "Delete Account", systemImage: "trash", color: .sellRed) { section = .delete }
            ProfileMenuRow(label: "Help & Support", systemImage: "headset") { section = .support }
            ProfileMenuRow(label: "Privacy Policy", systemImage: "lock") { section = .privacy }
            ProfileMenuRow(label: "Logout", systemImage: "rectangle.portrait.and.arrow.right", color: .sellRed, showDivider: false) {
                showLogoutDialog = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.line.opacity(0.55), lineWidth: 1))
    }
}

struct ProfileTopBar: View {
    let title: String
    let showBack: Bool
    let onBack: () -> Void

    var body: some View {
        HStack {
            if showBack {
                BackCircleButton(size: 40, action: onBack)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
            Text(title)
                .font(.poppins(18, .extraBold))
                .foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity)
            Color.clear.frame(width: 40, height: 40)
        }
    }
}

struct ProfilePhoto: View {
    let name: String

    var body: some View {
        Text(name.prefix(1).uppercased().ifBlank("C"))
            .font(.poppins(32, .extraBold))
            .foregroundStyle(.white)
            .frame(width: 86, height: 86)
            .background(Color.gold.opacity(0.95), in: Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
    }
}

struct ProfileMenuRow: View {
    let label: String
    let systemImage: String
    var color: Color = .textDark
    var showDivider = true
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.system(size: 17))
                        .foregroundStyle(color)
                        .frame(width: 22)
                    Text(label)
                        .font(.poppins(14, .bold))
                        .foregroundStyle(color)
                    Spacer()
                    if color != .sellRed {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.muted)
                    }
                }
                .frame(height: 58)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if showDivider {
                Color.line.opacity(0.42).frame(height: 1)
            }
        }
    }
}
