import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

/// Firebase Cloud Messaging setup. The backend (website/push_notifications.py) sends the
/// "account_approved" push through FCM, which delivers it to iOS over APNs.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        URLCache.shared = URLCache(memoryCapacity: 30 * 1024 * 1024, diskCapacity: 150 * 1024 * 1024)
        if AppConfig.isUITesting {
            SessionStore.shared.clear()
        }

        if AppConfig.isFirebaseConfigured {
            FirebaseApp.configure()
            Messaging.messaging().delegate = self
        }
        UNUserNotificationCenter.current().delegate = self
        ApprovalChecker.register()

        Task {
            _ = await AppNotifier.requestAuthorization()
            application.registerForRemoteNotifications()
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard AppConfig.isFirebaseConfigured else { return }
        // FCM then reports the token through messaging(_:didReceiveRegistrationToken:).
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        if (userInfo["type"] as? String) == "account_approved" {
            SessionStore.shared.setPendingSignup("")
            return .newData
        }
        return .noData
    }
}

extension AppDelegate: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, !fcmToken.isEmpty else { return }
        Task { @MainActor in
            SessionStore.shared.updateFcmToken(fcmToken)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
