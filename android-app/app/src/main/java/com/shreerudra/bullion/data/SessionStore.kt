package com.shreerudra.bullion.data

import android.content.Context

object SessionStore {
    private const val PREFS_NAME = "app_session"
    private const val KEY_ACCESS = "access_token"
    private const val KEY_REFRESH = "refresh_token"
    private const val KEY_NAME = "user_name"
    private const val KEY_MOBILE = "mobile"
    private const val KEY_PENDING_SIGNUP_MOBILE = "pending_signup_mobile"
    private const val KEY_FCM_TOKEN = "fcm_token"

    private var appContext: Context? = null

    var accessToken: String = ""
    var refreshToken: String = ""
    var userName: String = ""
    var mobile: String = ""
    var pendingSignupMobile: String = ""
    var fcmToken: String = ""

    val authorization: String
        get() = "Bearer $accessToken"

    val isLoggedIn: Boolean
        get() = accessToken.isNotBlank()

    fun init(context: Context) {
        appContext = context.applicationContext
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        accessToken = prefs.getString(KEY_ACCESS, "") ?: ""
        refreshToken = prefs.getString(KEY_REFRESH, "") ?: ""
        userName = prefs.getString(KEY_NAME, "") ?: ""
        mobile = prefs.getString(KEY_MOBILE, "") ?: ""
        pendingSignupMobile = prefs.getString(KEY_PENDING_SIGNUP_MOBILE, "") ?: ""
        fcmToken = prefs.getString(KEY_FCM_TOKEN, "") ?: ""
    }

    fun setSession(response: LoginResponse) {
        accessToken = response.access
        refreshToken = response.refresh
        userName = response.user.name
        mobile = response.user.mobile
        pendingSignupMobile = ""
        save()
    }

    fun setPendingSignup(mobileNumber: String) {
        pendingSignupMobile = mobileNumber
        save()
    }

    fun updateFcmToken(token: String) {
        fcmToken = token
        save()
    }

    fun clear() {
        accessToken = ""
        refreshToken = ""
        userName = ""
        mobile = ""
        appContext
            ?.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            ?.edit()
            ?.clear()
            ?.apply()
    }

    private fun save() {
        appContext
            ?.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            ?.edit()
            ?.putString(KEY_ACCESS, accessToken)
            ?.putString(KEY_REFRESH, refreshToken)
            ?.putString(KEY_NAME, userName)
            ?.putString(KEY_MOBILE, mobile)
            ?.putString(KEY_PENDING_SIGNUP_MOBILE, pendingSignupMobile)
            ?.putString(KEY_FCM_TOKEN, fcmToken)
            ?.apply()
    }
}
