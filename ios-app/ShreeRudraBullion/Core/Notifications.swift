import BackgroundTasks
import Foundation
import UserNotifications

/// Local "Account approved" alert, same text as AppNotifier.kt.
@MainActor
enum AppNotifier {
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func showApproved() {
        let content = UNMutableNotificationContent()
        content.title = "Account approved"
        content.body = "Your account has been approved. You can now log in with your mobile number and password."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "account-approved", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

/// iOS replacement for ApprovalStatusWorker. iOS decides when background refresh runs,
/// so the push from the admin approval is the primary signal and this is a best-effort fallback.
@MainActor
enum ApprovalChecker {
    static let taskIdentifier = "com.shreerudra.bullion.approval-check"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: .main) { task in
            MainActor.assumeIsolated {
                handle(task)
            }
        }
    }

    static func schedule() {
        guard !SessionStore.shared.pendingSignupMobile.isEmpty else { return }
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(_ task: BGTask) {
        schedule()
        let work = Task {
            await checkPendingApproval()
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = { @Sendable in
            work.cancel()
        }
    }

    @discardableResult
    static func checkPendingApproval() async -> SignupStatusResponse? {
        let mobile = SessionStore.shared.pendingSignupMobile
        guard !mobile.isEmpty, let status = try? await API.signupStatus(mobile: mobile) else { return nil }
        if status.status == "approved" {
            SessionStore.shared.setPendingSignup("")
            AppNotifier.showApproved()
        }
        return status
    }
}
