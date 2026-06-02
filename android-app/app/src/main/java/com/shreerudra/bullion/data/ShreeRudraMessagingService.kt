package com.shreerudra.bullion.data

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class ShreeRudraMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        SessionStore.init(applicationContext)
        SessionStore.updateFcmToken(token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        AppNotifier.init(applicationContext)
        if (message.data["type"] == "account_approved") {
            AppNotifier.showApproved()
        }
    }
}
