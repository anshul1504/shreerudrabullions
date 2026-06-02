package com.shreerudra.bullion

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.app.ActivityCompat
import com.google.firebase.messaging.FirebaseMessaging
import com.shreerudra.bullion.data.AppNotifier
import com.shreerudra.bullion.data.ApprovalStatusWorker
import com.shreerudra.bullion.data.SessionStore
import com.shreerudra.bullion.ui.ShreeRudraApp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SessionStore.init(applicationContext)
        AppNotifier.init(applicationContext)
        requestNotificationPermission()
        refreshFcmToken()
        ApprovalStatusWorker.schedule(applicationContext)
        setContent {
            ShreeRudraApp()
        }
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 10)
        }
    }

    private fun refreshFcmToken() {
        FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
            if (token.isNotBlank()) {
                SessionStore.updateFcmToken(token)
            }
        }
    }
}
