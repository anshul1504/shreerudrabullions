package com.shreerudra.bullion.ui

import android.content.Intent
import android.net.Uri
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.rememberTransformableState
import androidx.compose.foundation.gestures.transformable
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.border
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.Typography
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Chat
import androidx.compose.material.icons.automirrored.outlined.ShowChart
import androidx.compose.material.icons.automirrored.outlined.TrendingUp
import androidx.compose.material.icons.outlined.Call
import androidx.compose.material.icons.outlined.ChevronRight
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Close
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Inventory2
import androidx.compose.material.icons.outlined.LocationOn
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Refresh
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Tune
import androidx.compose.material.icons.outlined.Security
import androidx.compose.material.icons.outlined.SupportAgent
import androidx.compose.material.icons.outlined.VerifiedUser
import androidx.compose.material.icons.outlined.WorkspacePremium
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.shreerudra.bullion.R
import com.shreerudra.bullion.data.ApiClient
import com.shreerudra.bullion.data.AboutInfo
import com.shreerudra.bullion.data.AboutTestimonial
import com.shreerudra.bullion.data.AppNotifier
import com.shreerudra.bullion.data.ApprovalStatusWorker
import com.shreerudra.bullion.data.ContactInfo
import com.shreerudra.bullion.data.ContactRequest
import com.shreerudra.bullion.data.ForgotPasswordRequest
import com.shreerudra.bullion.data.HomeInfo
import com.shreerudra.bullion.data.HomeCategoryItem
import com.shreerudra.bullion.data.HomeProductItem
import com.shreerudra.bullion.data.LiveRatesResponse
import com.shreerudra.bullion.data.LoginRequest
import com.shreerudra.bullion.data.ProductItem
import com.shreerudra.bullion.data.ProductDetail
import com.shreerudra.bullion.data.ProfileUpdateRequest
import com.shreerudra.bullion.data.SessionStore
import com.shreerudra.bullion.data.SignupRequest
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import retrofit2.HttpException
import android.text.Html
import java.net.SocketTimeoutException
import java.net.UnknownHostException

private val Gold = Color(0xFFB27A13)
private val Dark = Color(0xFF111318)
private val Surface = Color(0xFFFFFCF5)
private val SoftSurface = Color(0xFFF6F4EF)
private val Line = Color(0xFFE8D8B5)
private val Muted = Color(0xFF6F6B62)
private val TextDark = Color(0xFF181A20)
private val BuyGreen = Color(0xFF006A3A)
private val SellRed = Color(0xFF9E1111)
private val Poppins = FontFamily(
    Font(R.font.poppins_regular, FontWeight.Normal),
    Font(R.font.poppins_bold, FontWeight.Bold),
    Font(R.font.poppins_extrabold, FontWeight.ExtraBold),
)
private val DefaultTypography = Typography()
private val AppTypography = Typography(
    displayLarge = DefaultTypography.displayLarge.copy(fontFamily = Poppins),
    displayMedium = DefaultTypography.displayMedium.copy(fontFamily = Poppins),
    displaySmall = DefaultTypography.displaySmall.copy(fontFamily = Poppins),
    headlineLarge = DefaultTypography.headlineLarge.copy(fontFamily = Poppins),
    headlineMedium = DefaultTypography.headlineMedium.copy(fontFamily = Poppins),
    headlineSmall = DefaultTypography.headlineSmall.copy(fontFamily = Poppins),
    titleLarge = DefaultTypography.titleLarge.copy(fontFamily = Poppins),
    titleMedium = DefaultTypography.titleMedium.copy(fontFamily = Poppins),
    titleSmall = DefaultTypography.titleSmall.copy(fontFamily = Poppins),
    bodyLarge = DefaultTypography.bodyLarge.copy(fontFamily = Poppins, fontSize = 17.sp, lineHeight = 25.sp),
    bodyMedium = DefaultTypography.bodyMedium.copy(fontFamily = Poppins, fontSize = 15.sp, lineHeight = 22.sp),
    bodySmall = DefaultTypography.bodySmall.copy(fontFamily = Poppins, fontSize = 13.sp, lineHeight = 19.sp),
    labelLarge = DefaultTypography.labelLarge.copy(fontFamily = Poppins, fontSize = 15.sp),
    labelMedium = DefaultTypography.labelMedium.copy(fontFamily = Poppins, fontSize = 13.sp),
    labelSmall = DefaultTypography.labelSmall.copy(fontFamily = Poppins, fontSize = 12.sp),
)

private enum class AuthMode {
    Welcome,
    Login,
    Signup,
    ForgotPassword,
}

@Composable
fun ShreeRudraApp() {
    MaterialTheme(typography = AppTypography) {
        var showSplash by remember { mutableStateOf(true) }
        LaunchedEffect(Unit) {
            delay(1500)
            showSplash = false
        }
        if (showSplash) {
            SplashScreen()
        } else {
            var loggedIn by remember { mutableStateOf(SessionStore.isLoggedIn) }
            var signedOutMessage by remember { mutableStateOf("") }
            if (loggedIn) {
                DashboardScreen(onLogout = {
                    SessionStore.clear()
                    signedOutMessage = "You have been signed out. Please sign in again to continue."
                    loggedIn = false
                })
            } else if (signedOutMessage.isNotBlank()) {
                SignedOutScreen(
                    message = signedOutMessage,
                    onSignInAgain = {
                        signedOutMessage = ""
                    },
                )
            } else {
                AuthScreen(onLoggedIn = {
                    signedOutMessage = ""
                    loggedIn = true
                })
            }
        }
    }
}

@Composable
private fun SplashScreen() {
    var animate by remember { mutableStateOf(false) }
    val logoScale by animateFloatAsState(
        targetValue = if (animate) 1f else 0.82f,
        animationSpec = tween(durationMillis = 850, easing = FastOutSlowInEasing),
        label = "logoScale",
    )
    val logoAlpha by animateFloatAsState(
        targetValue = if (animate) 1f else 0f,
        animationSpec = tween(durationMillis = 650, easing = FastOutSlowInEasing),
        label = "logoAlpha",
    )

    LaunchedEffect(Unit) {
        animate = true
    }

    Box(Modifier.fillMaxSize()) {
        BullionBackground()
        Box(
            Modifier
                .fillMaxSize()
                .background(Color(0x99111318)),
        )
        Image(
            painter = painterResource(R.drawable.app_logo),
            contentDescription = "Shree Rudra Bullion",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .align(Alignment.Center)
                .size(190.dp)
                .scale(logoScale)
                .graphicsLayer { alpha = logoAlpha }
                .clip(CircleShape)
                .background(Color.White, CircleShape),
        )
    }
}

@Composable
private fun AuthScreen(onLoggedIn: () -> Unit) {
    var mode by remember { mutableStateOf(AuthMode.Welcome) }
    var approvalMessage by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        while (true) {
            val mobile = SessionStore.pendingSignupMobile
            if (mobile.isNotBlank()) {
                runCatching { ApiClient.service.signupStatus(mobile) }
                    .onSuccess {
                        if (it.status == "approved") {
                            SessionStore.setPendingSignup("")
                            approvalMessage = it.message
                            AppNotifier.showApproved()
                        } else if (it.status == "rejected") {
                            approvalMessage = it.message
                        }
                    }
            }
            delay(15000)
        }
    }

    Box(Modifier.fillMaxSize()) {
        BullionBackground()
        Box(
            Modifier
                .fillMaxSize()
                .background(Color(0xB0111318)),
        )
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (approvalMessage.isNotBlank()) MessageText(approvalMessage)
            when (mode) {
                AuthMode.Welcome -> WelcomeScreen(
                    onLogin = { mode = AuthMode.Login },
                    onSignup = { mode = AuthMode.Signup },
                )
                AuthMode.Login -> LoginForm(
                    onLoggedIn = onLoggedIn,
                    onSignup = { mode = AuthMode.Signup },
                    onForgotPassword = { mode = AuthMode.ForgotPassword },
                    onBack = { mode = AuthMode.Welcome },
                )
                AuthMode.Signup -> SignupForm(
                    onBack = { mode = AuthMode.Welcome },
                    onLogin = { mode = AuthMode.Login },
                )
                AuthMode.ForgotPassword -> ForgotPasswordForm(
                    onBack = { mode = AuthMode.Login },
                    onLogin = { mode = AuthMode.Login },
                )
            }
        }
    }
}

@Composable
private fun SignedOutScreen(message: String, onSignInAgain: () -> Unit) {
    Box(Modifier.fillMaxSize()) {
        BullionBackground()
        Box(
            Modifier
                .fillMaxSize()
                .background(Color(0xB0111318)),
        )
        Card(
            modifier = Modifier
                .align(Alignment.Center)
                .padding(24.dp)
                .fillMaxWidth(),
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Image(
                    painter = painterResource(R.drawable.app_logo),
                    contentDescription = "Shree Rudra Bullion",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(92.dp)
                        .clip(CircleShape)
                        .background(Surface, CircleShape),
                )
                Spacer(Modifier.height(16.dp))
                Text("Sign in required", color = Dark, fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, textAlign = TextAlign.Center)
                Spacer(Modifier.height(8.dp))
                Text(message, color = Muted, fontSize = 15.sp, lineHeight = 22.sp, textAlign = TextAlign.Center)
                Spacer(Modifier.height(20.dp))
                PrimaryButton("Sign in again", loading = false, onClick = onSignInAgain)
            }
        }
    }
}

@Composable
private fun WelcomeScreen(onLogin: () -> Unit, onSignup: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Image(
            painter = painterResource(R.drawable.app_logo),
            contentDescription = "Shree Rudra Bullion",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(158.dp)
                .clip(CircleShape)
                .background(Color.White, CircleShape),
        )
        Spacer(Modifier.height(28.dp))
        Text(
            "Welcome Back",
            color = Color.White,
            fontSize = 32.sp,
            fontWeight = FontWeight.ExtraBold,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
        Text(
            "Access live bullion rates and products",
            color = Color.White.copy(alpha = 0.82f),
            fontSize = 14.sp,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
        Spacer(Modifier.height(34.dp))
        OutlinedButton(
            onClick = onLogin,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(28.dp),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White),
        ) {
            Text("SIGN IN", fontWeight = FontWeight.ExtraBold)
        }
        Spacer(Modifier.height(14.dp))
        Button(
            onClick = onSignup,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(28.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Color.White),
        ) {
            Text("SIGN UP", color = Dark, fontWeight = FontWeight.ExtraBold)
        }
        Spacer(Modifier.height(32.dp))
        Text(
            "Developed by The Webfix",
            color = Color.White.copy(alpha = 0.72f),
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

@Composable
private fun LoginForm(onLoggedIn: () -> Unit, onSignup: () -> Unit, onForgotPassword: () -> Unit, onBack: () -> Unit) {
    val scope = rememberCoroutineScope()
    var mobile by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    var mobileError by remember { mutableStateOf("") }
    var passwordError by remember { mutableStateOf("") }

    AuthPanel {
        AuthFormHeader(
            title = "Sign in",
            subtitle = "Access live bullion rates, products, and account tools.",
            onBack = onBack,
        )
        Spacer(Modifier.height(20.dp))
        MobileField(value = mobile, onValueChange = { mobile = it; mobileError = "" }, error = mobileError)
        Field(value = password, onValueChange = { password = it; passwordError = "" }, label = "Password", password = true, error = passwordError)
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            TextButton(onClick = onForgotPassword) {
                Text("Forgot password?", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            }
        }
        Spacer(Modifier.height(18.dp))
        PrimaryButton("Sign in", loading = loading) {
            val cleanMobile = mobile.toIndianMobileDigits()
            mobileError = if (!cleanMobile.isValidIndianMobile()) "Enter a valid 10 digit mobile number." else ""
            passwordError = if (password.length < 6) "Password must be at least 6 characters." else ""
            if (mobileError.isNotBlank() || passwordError.isNotBlank()) return@PrimaryButton
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.login(LoginRequest(cleanMobile, password))
                }.onSuccess {
                    SessionStore.setSession(it)
                    onLoggedIn()
                }.onFailure {
                    message = apiMessage(it, "Invalid mobile number or password.")
                }
                loading = false
            }
        }
        Spacer(Modifier.height(18.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) {
            Text("Don't have an account?", color = Muted, fontSize = 13.sp)
            TextButton(onClick = onSignup) {
                Text("Sign up", color = Dark, fontWeight = FontWeight.ExtraBold)
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun SignupForm(onBack: () -> Unit, onLogin: () -> Unit) {
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    var name by remember { mutableStateOf("") }
    var mobile by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var successMessage by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    var nameError by remember { mutableStateOf("") }
    var mobileError by remember { mutableStateOf("") }
    var passwordError by remember { mutableStateOf("") }
    var confirmPasswordError by remember { mutableStateOf("") }

    if (successMessage.isNotBlank()) {
        LaunchedEffect(successMessage) {
            delay(5000)
            successMessage = ""
            onLogin()
        }
        AlertDialog(
            onDismissRequest = {},
            confirmButton = {},
            title = {
                Text("Request Submitted", color = Dark, fontWeight = FontWeight.ExtraBold)
            },
            text = {
                Text(successMessage, color = Dark)
            },
            containerColor = Color.White,
            shape = RoundedCornerShape(24.dp),
        )
    }

    AuthPanel {
        AuthFormHeader(
            title = "Create account",
            subtitle = "Submit your request. Access is enabled after admin approval.",
            onBack = onBack,
        )
        Spacer(Modifier.height(20.dp))
        Field(value = name, onValueChange = { name = it; nameError = "" }, label = "Full name", error = nameError)
        MobileField(value = mobile, onValueChange = { mobile = it; mobileError = "" }, error = mobileError)
        Field(value = password, onValueChange = { password = it; passwordError = "" }, label = "Password", password = true, error = passwordError)
        Field(value = confirmPassword, onValueChange = { confirmPassword = it; confirmPasswordError = "" }, label = "Confirm password", password = true, error = confirmPasswordError)
        PrimaryButton("Send Request", loading = loading) {
            val cleanMobile = mobile.toIndianMobileDigits()
            nameError = if (name.trim().length < 3) "Enter your full name." else ""
            mobileError = if (!cleanMobile.isValidIndianMobile()) "Enter a valid 10 digit mobile number." else ""
            passwordError = if (password.length < 6) "Password must be at least 6 characters." else ""
            confirmPasswordError = if (confirmPassword != password) "Password and confirm password must match." else ""
            if (listOf(nameError, mobileError, passwordError, confirmPasswordError).any { it.isNotBlank() }) return@PrimaryButton
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.signupRequest(
                        SignupRequest(
                            name = name.trim(),
                            mobile = cleanMobile,
                            password = password,
                            confirm_password = confirmPassword,
                            fcm_token = SessionStore.fcmToken,
                        ),
                    )
                }.onSuccess {
                    SessionStore.setPendingSignup(cleanMobile)
                    ApprovalStatusWorker.schedule(context.applicationContext)
                    successMessage = it.message
                }.onFailure {
                    message = apiMessage(it, "Unable to submit request. Please check details and try again.")
                }
                loading = false
            }
        }
        Spacer(Modifier.height(18.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center, verticalAlignment = Alignment.CenterVertically) {
            Text("Already have an account?", color = Muted, fontSize = 13.sp)
            TextButton(onClick = onLogin) {
                Text("Sign in", color = Dark, fontWeight = FontWeight.ExtraBold)
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun ForgotPasswordForm(onBack: () -> Unit, onLogin: () -> Unit) {
    val scope = rememberCoroutineScope()
    var mobile by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var successMessage by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    var mobileError by remember { mutableStateOf("") }
    var passwordError by remember { mutableStateOf("") }
    var confirmPasswordError by remember { mutableStateOf("") }

    if (successMessage.isNotBlank()) {
        LaunchedEffect(successMessage) {
            delay(5000)
            successMessage = ""
            onLogin()
        }
        AlertDialog(
            onDismissRequest = {},
            confirmButton = {},
            title = {
                Text("Password Reset Successful", color = Dark, fontWeight = FontWeight.ExtraBold)
            },
            text = {
                Text(successMessage, color = Dark)
            },
            containerColor = Color.White,
            shape = RoundedCornerShape(24.dp),
        )
    }

    AuthPanel {
        AuthFormHeader(
            title = "Reset password",
            subtitle = "Enter your approved mobile number and choose a new password.",
            onBack = onBack,
        )
        Spacer(Modifier.height(20.dp))
        MobileField(value = mobile, onValueChange = { mobile = it; mobileError = "" }, error = mobileError)
        Field(value = password, onValueChange = { password = it; passwordError = "" }, label = "New password", password = true, error = passwordError)
        Field(value = confirmPassword, onValueChange = { confirmPassword = it; confirmPasswordError = "" }, label = "Confirm password", password = true, error = confirmPasswordError)
        PrimaryButton("Reset Password", loading = loading) {
            val cleanMobile = mobile.toIndianMobileDigits()
            mobileError = if (!cleanMobile.isValidIndianMobile()) "Enter a valid 10 digit mobile number." else ""
            passwordError = if (password.length < 6) "Password must be at least 6 characters." else ""
            confirmPasswordError = if (confirmPassword != password) "Password and confirm password must match." else ""
            if (listOf(mobileError, passwordError, confirmPasswordError).any { it.isNotBlank() }) return@PrimaryButton
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.forgotPassword(ForgotPasswordRequest(cleanMobile, password, confirmPassword))
                }.onSuccess {
                    successMessage = "Your password has been reset successfully. Please sign in with your new password."
                }.onFailure {
                    message = apiMessage(it, "Unable to reset password. Please check details and try again.")
                }
                loading = false
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun AuthFormHeader(title: String, subtitle: String, onBack: () -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
        Box(
            modifier = Modifier
                .size(42.dp)
                .background(SoftSurface, CircleShape)
                .clickable(onClick = onBack),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                Icons.Outlined.ChevronRight,
                contentDescription = "Back",
                tint = TextDark,
                modifier = Modifier
                    .size(22.dp)
                    .scale(scaleX = -1f, scaleY = 1f),
            )
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, color = Dark, fontSize = 26.sp, fontWeight = FontWeight.ExtraBold)
            Text(subtitle, color = Muted, fontSize = 14.sp, lineHeight = 20.sp)
        }
    }
}

@Composable
private fun DashboardScreen(onLogout: () -> Unit) {
    val context = LocalContext.current
    var tab by remember { mutableStateOf("rates") }
    var profileResetSignal by remember { mutableStateOf(0) }
    var selectedProductSlug by remember { mutableStateOf<String?>(null) }
    var contact by remember { mutableStateOf<ContactInfo?>(null) }
    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.contact(SessionStore.authorization) }
            .onSuccess { contact = it }
    }
    val quickPhone = contact?.let { (it.footer_phone_numbers.firstOrNull() ?: it.phone).ifBlank { SessionStore.mobile } } ?: SessionStore.mobile
    val tabs = listOf(
        DashboardTab("home", "Home", Icons.Outlined.Home),
        DashboardTab("products", "Products", Icons.Outlined.Inventory2),
        DashboardTab("rates", "Live", Icons.AutoMirrored.Outlined.ShowChart),
        DashboardTab("about", "About", Icons.Outlined.WorkspacePremium),
        DashboardTab("profile", "Profile", Icons.Outlined.Person),
    )
    Scaffold(
        containerColor = SoftSurface,
        bottomBar = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.Transparent)
                    .padding(horizontal = 16.dp, vertical = 10.dp),
            ) {
                Row(
                    Modifier
                        .fillMaxWidth()
                    .height(86.dp)
                    .shadow(16.dp, RoundedCornerShape(28.dp))
                    .background(Color.White, RoundedCornerShape(28.dp))
                    .border(1.dp, Line.copy(alpha = 0.5f), RoundedCornerShape(28.dp))
                    .padding(horizontal = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    tabs.forEach { item ->
                        NavButton(item, tab == item.key, Modifier.weight(1f)) {
                            if (item.key == "profile") {
                                profileResetSignal += 1
                            }
                            if (item.key == "products") {
                                selectedProductSlug = null
                            }
                            tab = item.key
                        }
                    }
                }
            }
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(SoftSurface)
                .padding(padding),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 14.dp, vertical = 10.dp),
            ) {
                if (tab == "rates") {
                    DashboardHeader(tab)
                    Spacer(Modifier.height(12.dp))
                }
                when (tab) {
                    "home" -> HomeScreen(
                        onViewProducts = {
                            selectedProductSlug = null
                            tab = "products"
                        },
                        onProductClick = {
                            selectedProductSlug = it
                            tab = "products"
                        },
                    )
                    "products" -> ProductsScreen(
                        selectedSlug = selectedProductSlug,
                        onSelectedSlugChange = { selectedProductSlug = it },
                        onAuthExpired = onLogout,
                    )
                    "about" -> AboutScreen()
                    "profile" -> ProfileScreen(profileResetSignal, onLogout)
                    else -> LiveRatesScreen(onAuthExpired = onLogout)
                }
                Spacer(Modifier.height(12.dp))
            }
            QuickContactActions(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = 18.dp, bottom = 12.dp),
                onCall = { openDialer(context, quickPhone) },
                onWhatsApp = { openWhatsApp(context, quickPhone) },
            )
        }
    }
}

private data class DashboardTab(val key: String, val label: String, val icon: ImageVector)

@Composable
private fun QuickContactActions(modifier: Modifier = Modifier, onCall: () -> Unit, onWhatsApp: () -> Unit) {
    Row(
        modifier = modifier
            .shadow(12.dp, RoundedCornerShape(18.dp))
            .background(Color.White, RoundedCornerShape(18.dp))
            .border(1.dp, Line.copy(alpha = 0.55f), RoundedCornerShape(18.dp))
            .padding(6.dp),
        horizontalArrangement = Arrangement.spacedBy(7.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .background(Gold, CircleShape)
                .clickable(onClick = onCall),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Outlined.Call, contentDescription = "Call", tint = Color.White, modifier = Modifier.size(22.dp))
        }
        Box(
            modifier = Modifier
                .size(44.dp)
                .background(Color.White, CircleShape)
                .clickable(onClick = onWhatsApp),
            contentAlignment = Alignment.Center,
        ) {
            Image(
                painter = painterResource(R.drawable.whatsapp_logo),
                contentDescription = "WhatsApp",
                modifier = Modifier.size(34.dp),
                contentScale = ContentScale.Fit,
            )
        }
    }
}

@Composable
private fun DashboardHeader(activeTab: String) {
    val title = when (activeTab) {
        "home" -> "Welcome"
        "products" -> "Bullion & Jewellery"
        "about" -> "About Us"
        "profile" -> "My Account"
        else -> "Live Rates"
    }
    val subtitle = when (activeTab) {
        "home" -> "Hello, ${SessionStore.userName.ifBlank { "Customer" }}"
        "products" -> "Explore our active website catalogue"
        "about" -> "Trusted bullion service and support"
        "profile" -> "Manage your account and enquiries"
        else -> "Current bullion buy and sell rates"
    }
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White, RoundedCornerShape(24.dp))
            .border(1.dp, Line.copy(alpha = 0.5f), RoundedCornerShape(24.dp))
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Image(
            painter = painterResource(R.drawable.app_logo),
            contentDescription = "Shree Rudra Bullion",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(52.dp)
                .clip(CircleShape)
                .background(Surface, CircleShape),
        )
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(title, color = TextDark, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold)
            Text(subtitle, color = Muted, fontSize = 14.sp, lineHeight = 20.sp)
        }
        Box(
            modifier = Modifier
                .background(Gold.copy(alpha = 0.12f), RoundedCornerShape(18.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp),
        ) {
            Text("Member", color = Gold, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun HomeScreen(onViewProducts: () -> Unit, onProductClick: (String) -> Unit) {
    var home by remember { mutableStateOf<HomeInfo?>(null) }
    var productSearch by remember { mutableStateOf("") }
    var error by remember { mutableStateOf("") }
    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.home(SessionStore.authorization) }
            .onSuccess { home = it }
            .onFailure { error = networkMessage(it, "Home details are currently unavailable.") }
    }
    val data = home
    if (data == null) {
        if (error.isNotBlank()) ErrorCard(error) else LoadingBox()
        return
    }
    ProductSearchBar(
        value = productSearch,
        onValueChange = { productSearch = it },
        placeholder = "Search products",
    )
    Spacer(Modifier.height(12.dp))
    HomeSliderSection(data)
    Spacer(Modifier.height(12.dp))
    ServiceStrip()
    Spacer(Modifier.height(16.dp))
    SectionTitle("Why Choose Us", "India's Trusted Bullion Partner")
    Text("Premium bullion and jewellery solutions with verified purity, transparent pricing, and dedicated dealer support.", color = Muted, fontSize = 15.sp, lineHeight = 22.sp)
    Spacer(Modifier.height(12.dp))
    HomeWhyGrid()
    Spacer(Modifier.height(16.dp))
    if (data.categories.isNotEmpty()) {
        SectionTitle("Featured Category", "Explore Our Featured Categories")
        HorizontalCards(step = 96, intervalMillis = 900, durationMillis = 850) {
            data.categories.forEach { category ->
                HomeCategoryCard(category)
                Spacer(Modifier.width(12.dp))
            }
        }
        Spacer(Modifier.height(16.dp))
    }
    if (data.products.isNotEmpty()) {
        val searchedProducts = data.products.filter {
            val query = productSearch.trim()
            query.isBlank() ||
                it.title.contains(query, ignoreCase = true) ||
                it.category.contains(query, ignoreCase = true) ||
                it.price.contains(query, ignoreCase = true)
        }
        SectionTitle("Featured Collection", "Our Products")
        Text("Browse gold, silver, and hallmark jewellery collections.", color = Muted, fontSize = 15.sp, lineHeight = 22.sp)
        Spacer(Modifier.height(12.dp))
        searchedProducts.take(8).forEach { product ->
            HomeProductCard(product, onClick = { onProductClick(product.slug) })
            Spacer(Modifier.height(12.dp))
        }
        if (searchedProducts.isEmpty()) {
            EmptyCard("No products found for this search.")
        }
        Spacer(Modifier.height(12.dp))
        PrimaryButton("View Products", loading = false, onClick = onViewProducts)
        Spacer(Modifier.height(16.dp))
    }
    CommitmentSection()
    Spacer(Modifier.height(16.dp))
    if (data.testimonials.isNotEmpty()) {
        SectionTitle("Testimonials", "What Clients Say")
        HorizontalCards {
            data.testimonials.forEach {
                TestimonialCard(it, Modifier.width(300.dp))
                Spacer(Modifier.width(12.dp))
            }
        }
        Spacer(Modifier.height(16.dp))
    }
    TrustStrip()
    Spacer(Modifier.height(16.dp))
    Panel {
        Text("Ready to Trade with Confidence?", color = Dark, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold)
        Text("Connect with our team for live rates, bulk quotes, and quick support.", color = Muted, fontSize = 15.sp, lineHeight = 22.sp)
        Spacer(Modifier.height(12.dp))
        InfoLine("Phone", data.phone.ifBlank { "-" }, Icons.Outlined.Call)
        InfoLine("Address", data.address.ifBlank { "-" }, Icons.Outlined.LocationOn)
        InfoLine(data.weekday_label.ifBlank { "Business hours" }, data.weekday_time.ifBlank { "-" }, Icons.Outlined.WorkspacePremium)
    }
}

@Composable
private fun BullionBackground() {
    Image(
        painter = painterResource(R.drawable.auth_bullion_bg),
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = Modifier.fillMaxSize(),
    )
}

@Composable
private fun HomeSliderSection(data: HomeInfo) {
    var active by remember { mutableStateOf(0) }
    LaunchedEffect(data.sliders.size) {
        while (data.sliders.size > 1) {
            delay(2600)
            active = (active + 1) % data.sliders.size
        }
    }
    val firstSlide = data.sliders.getOrNull(active)
    Card(
        modifier = Modifier.fillMaxWidth().height(230.dp),
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = Dark),
    ) {
        Box(Modifier.fillMaxSize()) {
            if (firstSlide?.image?.isNotBlank() == true) {
                AsyncImage(firstSlide.image, contentDescription = firstSlide.title, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.28f)))
            }
            Column(Modifier.fillMaxSize().padding(20.dp), verticalArrangement = Arrangement.Bottom) {
                Text(data.site_name, color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 29.sp)
                Text(data.tagline.ifBlank { "Trusted bullion rates, products, and customer support." }, color = Color.White.copy(alpha = 0.86f), fontSize = 15.sp, lineHeight = 22.sp)
            }
        }
    }
}

@Composable
private fun ServiceStrip() {
    val services = listOf("Gold Coins & Bars", "Silver Coins, Bars & Utensils", "BIS Hallmarked Jewellery", "Certified Purity Assurance", "Live Gold & Silver Rates", "Bulk Dealer Pricing Support", "Quick WhatsApp Rate Assistance")
    val scrollState = rememberScrollState()
    LaunchedEffect(Unit) {
        while (true) {
            delay(120)
            val target = if (scrollState.value >= scrollState.maxValue - 4) 0 else (scrollState.value + 48).coerceAtMost(scrollState.maxValue)
            scrollState.animateScrollTo(target, animationSpec = tween(durationMillis = 420, easing = LinearEasing))
        }
    }
    Row(Modifier.fillMaxWidth().horizontalScroll(scrollState), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        services.forEach {
            Box(Modifier.background(Color.White, RoundedCornerShape(18.dp)).border(1.dp, Line.copy(alpha = 0.45f), RoundedCornerShape(18.dp)).padding(horizontal = 12.dp, vertical = 8.dp)) {
                Text(it, color = TextDark, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun HomeWhyGrid() {
    val items = listOf(
        Triple("BIS Certified", "Hallmarked products with purity standards trusted by buyers.", Icons.Outlined.VerifiedUser),
        Triple("Live Market Rates", "Real-time gold and silver rates updated regularly.", Icons.AutoMirrored.Outlined.ShowChart),
        Triple("Secure Deals", "Transparent billing and documented transactions.", Icons.Outlined.Security),
        Triple("Dealer Support", "Dedicated assistance for bulk orders and rate checks.", Icons.Outlined.SupportAgent),
        Triple("Fast Fulfilment", "Prompt order processing and delivery coordination.", Icons.Outlined.Inventory2),
        Triple("Quick Response", "Rapid quote and support via call or WhatsApp.", Icons.Outlined.Call),
    )
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        items.chunked(2).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                row.forEach { item ->
                    HomeFeatureCard(item.first, item.second, item.third, Modifier.weight(1f))
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun HorizontalCards(
    autoRotate: Boolean = true,
    step: Int = 280,
    intervalMillis: Long = 2400,
    durationMillis: Int = 650,
    content: @Composable RowScope.() -> Unit,
) {
    val scrollState = rememberScrollState()
    if (autoRotate) {
        LaunchedEffect(Unit) {
            while (true) {
                delay(intervalMillis)
                val target = if (scrollState.value >= scrollState.maxValue - 8) 0 else (scrollState.value + step).coerceAtMost(scrollState.maxValue)
                scrollState.animateScrollTo(target, animationSpec = tween(durationMillis = durationMillis, easing = LinearEasing))
            }
        }
    }
    Row(Modifier.fillMaxWidth().horizontalScroll(scrollState), content = content)
}

@Composable
private fun HomeCategoryCard(category: HomeCategoryItem) {
    Card(Modifier.width(260.dp).height(170.dp), shape = RoundedCornerShape(24.dp), colors = CardDefaults.cardColors(containerColor = Dark)) {
        Box(Modifier.fillMaxSize()) {
            if (category.image.isNotBlank()) {
                AsyncImage(category.image, contentDescription = category.title, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.42f)))
            }
            Column(Modifier.fillMaxSize().padding(16.dp), verticalArrangement = Arrangement.Bottom) {
                if (category.subtitle.isNotBlank()) Text(category.subtitle, color = Gold, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                Text(category.title, color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 24.sp)
            }
        }
    }
}

@Composable
private fun HomeProductCard(product: HomeProductItem, onClick: () -> Unit) {
    Card(
        Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.55f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier
                    .width(108.dp)
                    .height(122.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(SoftSurface),
            ) {
                if (product.image.isNotBlank()) {
                    AsyncImage(product.image, contentDescription = product.title, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                } else {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.Inventory2, contentDescription = null, tint = Gold, modifier = Modifier.size(32.dp))
                    }
                }
            }
            Column(Modifier.weight(1f)) {
                Text(product.category, color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 2, textAlign = TextAlign.Start)
                Spacer(Modifier.height(4.dp))
                Text(product.title, color = Dark, fontSize = 17.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 21.sp, maxLines = 2, textAlign = TextAlign.Start)
                Spacer(Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Rs. ${product.price}", color = Gold, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
                    if (product.old_price.isNotBlank()) {
                        Spacer(Modifier.width(6.dp))
                        Text("Rs. ${product.old_price}", color = Muted, fontSize = 12.sp, textDecoration = TextDecoration.LineThrough)
                    }
                }
                Spacer(Modifier.height(10.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(Modifier.background(Gold.copy(alpha = 0.12f), RoundedCornerShape(10.dp)).padding(horizontal = 9.dp, vertical = 5.dp)) {
                        Text("View Detail", color = Gold, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    Spacer(Modifier.weight(1f))
                    Box(Modifier.size(30.dp).background(Gold.copy(alpha = 0.16f), CircleShape), contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.ChevronRight, contentDescription = null, tint = Gold, modifier = Modifier.size(18.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun CommitmentSection() {
    Panel {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            CounterStat("40+", "Years", Modifier.weight(1f))
            CounterStat("999", "Purity", Modifier.weight(1f))
            CounterStat("100%", "BIS Focused", Modifier.weight(1f))
        }
        Spacer(Modifier.height(16.dp))
        Text("Our Commitment", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
        Text("Why Investors Choose Us", color = Dark, fontSize = 21.sp, fontWeight = FontWeight.ExtraBold)
        Spacer(Modifier.height(12.dp))
        InfoLine("Real-Time Pricing", "Rates linked to market movement with timely updates.", Icons.AutoMirrored.Outlined.TrendingUp)
        InfoLine("Transparency First", "Clear pricing visibility before every transaction.", Icons.Outlined.VerifiedUser)
        InfoLine("Certified Products", "Bullion and hallmark details shared for confidence.", Icons.Outlined.WorkspacePremium)
        InfoLine("Expert Guidance", "Dedicated support for fast and reliable decisions.", Icons.Outlined.Call)
    }
}

@Composable
private fun CounterStat(value: String, label: String, modifier: Modifier) {
    Box(
        modifier = modifier
            .background(Gold.copy(alpha = 0.12f), RoundedCornerShape(18.dp))
            .padding(12.dp),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(value, color = Gold, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
            Text(label, color = TextDark, fontSize = 12.sp, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center, lineHeight = 15.sp)
        }
    }
}

@Composable
private fun TrustStrip() {
    val badges = listOf("BIS Hallmarked", "GST Registered", "Transparent Pricing", "Secure Billing", "Verified Purity", "Dealer Support")
    Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        badges.forEach {
            Box(Modifier.background(Gold.copy(alpha = 0.12f), RoundedCornerShape(18.dp)).padding(horizontal = 12.dp, vertical = 8.dp)) {
                Text(it, color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
            }
        }
    }
}

@Composable
private fun AboutScreen() {
    var data by remember { mutableStateOf<AboutInfo?>(null) }
    var error by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.about(SessionStore.authorization) }
            .onSuccess {
                data = it
                error = ""
            }
            .onFailure {
                error = networkMessage(it, "About content is currently unavailable.")
            }
    }

    if (data == null) {
        if (error.isNotBlank()) ErrorCard(error) else LoadingBox()
        return
    }

    val about = data ?: return
    AboutHero(about)
    Spacer(Modifier.height(14.dp))
    AboutValueCard("Our Direction", about.vision_title, about.vision_text, Icons.Outlined.VerifiedUser, Modifier.fillMaxWidth())
    Spacer(Modifier.height(12.dp))
    AboutValueCard("Our Promise", about.mission_title, about.mission_text, Icons.Outlined.WorkspacePremium, Modifier.fillMaxWidth())
    Spacer(Modifier.height(14.dp))
    AboutStoryCard(about)
    if (about.testimonials.isNotEmpty()) {
        Spacer(Modifier.height(16.dp))
        SectionTitle("Client Feedback", "What Our Clients Say")
        HorizontalCards {
            about.testimonials.forEach { testimonial ->
                TestimonialCard(testimonial, Modifier.width(300.dp))
                Spacer(Modifier.width(12.dp))
            }
        }
    }
}

@Composable
private fun AboutHero(about: AboutInfo) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(220.dp),
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = Dark),
    ) {
        Box(Modifier.fillMaxSize()) {
            if (about.header_background.isNotBlank()) {
                AsyncImage(
                    model = about.header_background,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize(),
                )
                Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.46f)))
            }
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(22.dp),
                verticalArrangement = Arrangement.Bottom,
            ) {
                Text("ABOUT US", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
                Spacer(Modifier.height(8.dp))
                Text(
                    about.header_title.ifBlank { "Shree Rudra Bullion & Jewels" },
                    color = Color.White,
                    fontSize = 25.sp,
                    fontWeight = FontWeight.ExtraBold,
                    lineHeight = 30.sp,
                )
                if (about.header_subtitle.isNotBlank()) {
                    Text(about.header_subtitle, color = Color.White.copy(alpha = 0.86f), fontSize = 15.sp, lineHeight = 22.sp)
                }
            }
        }
    }
}

@Composable
private fun AboutValueCard(eyebrow: String, title: String, body: String, icon: ImageVector, modifier: Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.5f)),
    ) {
        Column(Modifier.padding(16.dp)) {
            Box(
                modifier = Modifier
                    .size(38.dp)
                    .background(Gold.copy(alpha = 0.12f), CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, contentDescription = null, tint = Gold, modifier = Modifier.size(20.dp))
            }
            Spacer(Modifier.height(12.dp))
            Text(eyebrow.uppercase(), color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
            Text(title.ifBlank { "-" }, color = Dark, fontSize = 19.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 24.sp)
            Spacer(Modifier.height(6.dp))
            Text(body.ifBlank { "-" }, color = Muted, fontSize = 15.sp, lineHeight = 22.sp)
        }
    }
}

@Composable
private fun AboutStoryCard(about: AboutInfo) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(26.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.5f)),
    ) {
        Column(Modifier.padding(18.dp)) {
            if (about.who_image.isNotBlank()) {
                AsyncImage(
                    model = about.who_image,
                    contentDescription = about.who_title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(190.dp)
                        .clip(RoundedCornerShape(20.dp)),
                )
                Spacer(Modifier.height(16.dp))
            }
            Text("WHO WE ARE", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
            Text(about.who_title.ifBlank { "Who We Are" }, color = Dark, fontSize = 21.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 26.sp)
            if (about.who_subtitle.isNotBlank()) {
                Spacer(Modifier.height(6.dp))
                Text(about.who_subtitle, color = Gold, fontSize = 14.sp, fontWeight = FontWeight.Bold, lineHeight = 20.sp)
            }
            Spacer(Modifier.height(8.dp))
            Text(about.who_description.ifBlank { "-" }, color = Muted, fontSize = 15.sp, lineHeight = 23.sp)
        }
    }
}

@Composable
private fun TestimonialCard(testimonial: AboutTestimonial, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.5f)),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            if (testimonial.photo.isNotBlank()) {
                AsyncImage(
                    model = testimonial.photo,
                    contentDescription = testimonial.name,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(54.dp)
                        .clip(CircleShape),
                )
            } else {
                Box(Modifier.size(54.dp).background(Gold, CircleShape), contentAlignment = Alignment.Center) {
                    Text(testimonial.name.firstOrNull()?.uppercase() ?: "C", color = Color.White, fontWeight = FontWeight.ExtraBold)
                }
            }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text(testimonial.message, color = Dark, fontSize = 15.sp, lineHeight = 22.sp)
                Spacer(Modifier.height(8.dp))
                Text(testimonial.name, color = Dark, fontSize = 16.sp, fontWeight = FontWeight.ExtraBold)
                if (testimonial.role.isNotBlank()) {
                    Text(testimonial.role, color = Muted, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
private fun HomeFeatureCard(title: String, text: String, icon: ImageVector, modifier: Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
    ) {
        Column(Modifier.padding(16.dp)) {
            Icon(icon, contentDescription = null, tint = Gold, modifier = Modifier.size(26.dp))
            Spacer(Modifier.height(12.dp))
            Text(title, color = Dark, fontSize = 16.sp, fontWeight = FontWeight.Bold, lineHeight = 20.sp)
            Text(text, color = Muted, fontSize = 14.sp, lineHeight = 20.sp)
        }
    }
}

@Composable
private fun LiveRatesScreen(onAuthExpired: () -> Unit) {
    var data by remember { mutableStateOf<LiveRatesResponse?>(null) }
    var error by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(true) }
    val scope = rememberCoroutineScope()

    suspend fun refreshRates(showLoader: Boolean = false) {
        if (showLoader || data == null) loading = true
        runCatching { ApiClient.service.liveRates(SessionStore.authorization) }
            .onSuccess {
                data = it
                error = ""
                loading = false
            }
            .onFailure {
                loading = false
                if (it.isUnauthorized()) {
                    SessionStore.clear()
                    onAuthExpired()
                    return
                }
                error = networkMessage(it, "Live rates are currently unavailable.")
            }
    }

    LaunchedEffect(Unit) {
        while (true) {
            refreshRates()
            delay(3000)
        }
    }

    if (error.isNotBlank() && data == null) {
        ErrorCard(error)
        return
    }
    if (loading && data == null) {
        LoadingBox()
        return
    }
    data?.let { rates ->
        LiveStatusBar(
            updated = rates.rate_updated,
            loading = loading,
            onRefresh = { scope.launch { refreshRates(showLoader = true) } },
        )
        if (error.isNotBlank()) {
            MessageText(error)
        }
        Spacer(Modifier.height(12.dp))
        SectionTitle("Market Board", "Live Rates")
        RateTableHeader()
        rates.rows.forEach { row ->
            RateRowCard(row.label, row.unit, row.buy, if (row.key == "silver_kacchi_50_90") "" else row.sell)
        }
        if (rates.rows.isEmpty()) {
            EmptyCard("Live rates are currently unavailable. Please check back shortly.")
        }
        Spacer(Modifier.height(12.dp))
        LiveMarketRatesBox(rates)
        Spacer(Modifier.height(8.dp))
        Text(
            "Rates are indicative and may change without notice. Please confirm final dealing rates with the bullion desk before placing an order.",
            color = Muted,
            fontSize = 11.sp,
            lineHeight = 16.sp,
        )
    }
}

@Composable
private fun LiveMarketRatesBox(rates: LiveRatesResponse) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Dark),
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .background(Gold.copy(alpha = 0.16f), CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.AutoMirrored.Outlined.ShowChart, contentDescription = null, tint = Gold, modifier = Modifier.size(22.dp))
                }
                Spacer(Modifier.width(10.dp))
                Column(Modifier.weight(1f)) {
                    Text("Live Market Rates", color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.ExtraBold)
                    Text("Base market indicators", color = Color.White.copy(alpha = 0.62f), fontSize = 11.sp)
                }
                Box(
                    modifier = Modifier
                        .background(BuyGreen.copy(alpha = 0.16f), RoundedCornerShape(14.dp))
                        .border(1.dp, BuyGreen.copy(alpha = 0.36f), RoundedCornerShape(14.dp))
                        .padding(horizontal = 9.dp, vertical = 5.dp),
                ) {
                    Text(if (rates.market_open) "OPEN" else "CLOSED", color = BuyGreen, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
            Spacer(Modifier.height(14.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                MiniMetric("Gold Future", rates.market_base_rates.gold_rtgs, "Per 10 GM", Modifier.weight(1f), "Rs ")
                MiniMetric("Silver Future", rates.market_base_rates.silver_rtgs, "Per 1 KG", Modifier.weight(1f), "Rs ")
            }
            Spacer(Modifier.height(10.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                MiniMetric("USD/INR", rates.market_summary.usd_inr, "Spot", Modifier.weight(1f))
                MiniMetric("Gold USD", rates.market_summary.gold_usd, "International", Modifier.weight(1f), "$ ")
                MiniMetric("Silver USD", rates.market_summary.silver_usd, "International", Modifier.weight(1f), "$ ")
            }
        }
    }
}

@Composable
private fun MiniMetric(title: String, value: String, subtitle: String, modifier: Modifier, prefix: String = "") {
    Column(
        modifier = modifier
            .background(Color.White.copy(alpha = 0.09f), RoundedCornerShape(18.dp))
            .border(1.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(18.dp))
            .padding(13.dp),
    ) {
        Text(title, color = Color.White.copy(alpha = 0.64f), fontSize = 11.sp)
        Text(if (value.isBlank()) "-" else "$prefix$value", color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.Bold)
        Text(subtitle, color = Gold, fontSize = 10.sp)
    }
}

@Composable
private fun ProductsScreen(
    selectedSlug: String?,
    onSelectedSlugChange: (String?) -> Unit,
    onAuthExpired: () -> Unit,
) {
    var products by remember { mutableStateOf<List<ProductItem>?>(null) }
    var filter by remember { mutableStateOf("All") }
    var metalFilter by remember { mutableStateOf("All") }
    var purityFilter by remember { mutableStateOf("All") }
    var stockOnly by remember { mutableStateOf(false) }
    var showFilters by remember { mutableStateOf(false) }
    var search by remember { mutableStateOf("") }
    var page by remember { mutableStateOf(0) }
    var error by remember { mutableStateOf("") }
    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.products(SessionStore.authorization).products }
            .onSuccess { products = it }
            .onFailure {
                if (it.isUnauthorized()) {
                    SessionStore.clear()
                    onAuthExpired()
                } else {
                    error = networkMessage(it, "Products are currently unavailable.")
                }
            }
    }
    if (selectedSlug != null) {
        ProductDetailScreen(slug = selectedSlug, onBack = { onSelectedSlugChange(null) }, onAuthExpired = onAuthExpired)
        return
    }
    SectionTitle("PRODUCTS", "Bullion & Jewellery Inventory")
    if (error.isNotBlank()) ErrorCard(error)
    products?.let { list ->
        val categories = listOf("All") + list.map { it.category }.filter { it.isNotBlank() }.distinct()
        val metals = listOf("All") + list.map { it.metal_type.replaceFirstChar { char -> char.uppercase() } }.filter { it.isNotBlank() }.distinct()
        val purities = listOf("All") + list.map { it.purity }.filter { it.isNotBlank() }.distinct()
        val filtered = list
            .filter {
                val query = search.trim()
                query.isBlank() ||
                    it.title.contains(query, ignoreCase = true) ||
                    it.category.contains(query, ignoreCase = true) ||
                    it.subcategory.contains(query, ignoreCase = true) ||
                    it.metal_type.contains(query, ignoreCase = true) ||
                    it.purity.contains(query, ignoreCase = true) ||
                    it.price.contains(query, ignoreCase = true)
            }
            .filter { filter == "All" || it.category == filter }
            .filter { metalFilter == "All" || it.metal_type.equals(metalFilter, ignoreCase = true) }
            .filter { purityFilter == "All" || it.purity == purityFilter }
            .filter { !stockOnly || it.is_in_stock }
        val pageSize = 6
        val pageCount = ((filtered.size + pageSize - 1) / pageSize).coerceAtLeast(1)
        if (page >= pageCount) page = 0
        ProductSearchBar(
            value = search,
            onValueChange = {
                search = it
                page = 0
            },
            placeholder = "Search products, metal, purity",
        )
        Spacer(Modifier.height(12.dp))
        ProductToolbar(
            showFilters = showFilters,
            onToggleFilters = { showFilters = !showFilters },
            total = list.size,
            visible = filtered.size,
            activeCategory = filter,
        )
        if (showFilters) {
            Spacer(Modifier.height(12.dp))
            ProductFilterPanel(
                categories = categories,
                categoryCounts = list.groupingBy { it.category.ifBlank { "All" } }.eachCount(),
                activeCategory = filter,
                onCategory = {
                    filter = it
                    page = 0
                },
                metals = metals,
                activeMetal = metalFilter,
                onMetal = {
                    metalFilter = it
                    page = 0
                },
                purities = purities,
                activePurity = purityFilter,
                onPurity = {
                    purityFilter = it
                    page = 0
                },
                stockOnly = stockOnly,
                onStockOnly = {
                    stockOnly = it
                    page = 0
                },
                onClear = {
                    filter = "All"
                    metalFilter = "All"
                    purityFilter = "All"
                    stockOnly = false
                    page = 0
                },
                onApply = { showFilters = false },
                onClose = { showFilters = false },
            )
        }
        Spacer(Modifier.height(14.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Showing ${filtered.size} Products", color = Dark, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.weight(1f))
            Text("Page ${page + 1} / $pageCount", color = Muted, fontSize = 13.sp, fontWeight = FontWeight.Bold)
        }
        Spacer(Modifier.height(12.dp))
        if (filtered.isEmpty()) {
            EmptyCard("No products found for the selected filters.")
        } else {
            filtered.drop(page * pageSize).take(pageSize).forEach {
                ProductListCard(it) { onSelectedSlugChange(it.slug) }
                Spacer(Modifier.height(12.dp))
            }
        }
        ProductPagination(page = page, pageCount = pageCount, onPage = { page = it })
    } ?: if (error.isBlank()) LoadingBox() else Unit
}

@Composable
private fun ProductToolbar(
    showFilters: Boolean,
    onToggleFilters: () -> Unit,
    total: Int,
    visible: Int,
    activeCategory: String,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Dark, RoundedCornerShape(20.dp))
            .border(1.dp, Gold.copy(alpha = 0.35f), RoundedCornerShape(20.dp))
            .padding(horizontal = 14.dp, vertical = 12.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Box(Modifier.size(40.dp).background(Gold.copy(alpha = 0.16f), CircleShape), contentAlignment = Alignment.Center) {
                Icon(Icons.Outlined.Search, contentDescription = null, tint = Gold, modifier = Modifier.size(20.dp))
            }
            Column(Modifier.weight(1f)) {
                Text("Browse Products", color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.ExtraBold)
                Text(
                    "${if (activeCategory == "All") "All" else activeCategory} | $visible matching | $total total",
                    color = Color.White.copy(alpha = 0.68f),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                )
            }
            Button(
                onClick = onToggleFilters,
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Gold),
                contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 12.dp, vertical = 8.dp),
            ) {
                Text(if (showFilters) "Hide" else "Filter", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
                Spacer(Modifier.width(5.dp))
                Icon(Icons.Outlined.Tune, contentDescription = null, tint = Color.White, modifier = Modifier.size(15.dp))
            }
        }
    }
}

@Composable
private fun ProductSearchBar(value: String, onValueChange: (String) -> Unit, placeholder: String, dark: Boolean = false) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(if (dark) Color.White.copy(alpha = 0.1f) else Color.White, RoundedCornerShape(16.dp))
            .border(1.dp, if (dark) Color.White.copy(alpha = 0.18f) else Line.copy(alpha = 0.6f), RoundedCornerShape(16.dp))
            .padding(horizontal = 12.dp, vertical = 2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(Icons.Outlined.Search, contentDescription = null, tint = if (dark) Gold else Muted, modifier = Modifier.size(20.dp))
        Spacer(Modifier.width(8.dp))
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            placeholder = { Text(placeholder, color = if (dark) Color.White.copy(alpha = 0.62f) else Muted) },
            singleLine = true,
            modifier = Modifier.weight(1f),
            colors = androidx.compose.material3.OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.Transparent,
                unfocusedBorderColor = Color.Transparent,
                focusedTextColor = if (dark) Color.White else Dark,
                unfocusedTextColor = if (dark) Color.White else Dark,
                cursorColor = Gold,
            ),
        )
        if (value.isNotBlank()) {
            Icon(
                Icons.Outlined.Close,
                contentDescription = "Clear search",
                tint = if (dark) Color.White.copy(alpha = 0.75f) else Muted,
                modifier = Modifier
                    .size(20.dp)
                    .clickable { onValueChange("") },
            )
        }
    }
}

@Composable
private fun ProductFilterPanel(
    categories: List<String>,
    categoryCounts: Map<String, Int>,
    activeCategory: String,
    onCategory: (String) -> Unit,
    metals: List<String>,
    activeMetal: String,
    onMetal: (String) -> Unit,
    purities: List<String>,
    activePurity: String,
    onPurity: (String) -> Unit,
    stockOnly: Boolean,
    onStockOnly: (Boolean) -> Unit,
    onClear: () -> Unit,
    onApply: () -> Unit,
    onClose: () -> Unit,
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.6f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
    ) {
        Column {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(SoftSurface)
                    .padding(horizontal = 16.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("Filters", color = Dark, fontSize = 19.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.weight(1f), textAlign = TextAlign.Center)
                Icon(Icons.Outlined.Close, contentDescription = null, tint = Muted, modifier = Modifier.size(20.dp).clickable(onClick = onClose))
            }
            FilterSection("Category") {
                Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    categories.forEach { category ->
                        val count = if (category == "All") categoryCounts.values.sum() else categoryCounts[category].orZero()
                        FilterChip(label = "$category ($count)", active = activeCategory == category) { onCategory(category) }
                    }
                }
            }
            FilterSection("Metal Type") {
                Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    metals.forEach { metal -> FilterChip(label = metal, active = activeMetal == metal) { onMetal(metal) } }
                }
            }
            FilterSection("Purity") {
                Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    purities.forEach { purity -> FilterChip(label = purity, active = activePurity == purity) { onPurity(purity) } }
                }
            }
            FilterSection("Availability") {
                Row(
                    Modifier
                        .fillMaxWidth()
                        .background(if (stockOnly) Gold.copy(alpha = 0.12f) else SoftSurface, RoundedCornerShape(14.dp))
                        .border(1.dp, if (stockOnly) Gold else Line, RoundedCornerShape(14.dp))
                        .clickable { onStockOnly(!stockOnly) }
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text("In Stock Only", color = if (stockOnly) Gold else Dark, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.weight(1f))
                    Box(
                        Modifier
                            .size(22.dp)
                            .background(if (stockOnly) Gold else Color.White, RoundedCornerShape(6.dp))
                            .border(1.dp, if (stockOnly) Gold else Line, RoundedCornerShape(6.dp)),
                        contentAlignment = Alignment.Center,
                    ) {
                        if (stockOnly) Text("ON", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.ExtraBold)
                    }
                }
            }
            Row(
                Modifier
                    .fillMaxWidth()
                    .background(SoftSurface)
                    .padding(14.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                OutlinedButton(onClick = onClear, modifier = Modifier.weight(1f).height(46.dp), shape = RoundedCornerShape(18.dp)) {
                    Text("Discard", color = Dark, fontWeight = FontWeight.Bold)
                }
                Button(onClick = onApply, modifier = Modifier.weight(1f).height(46.dp), shape = RoundedCornerShape(18.dp), colors = ButtonDefaults.buttonColors(containerColor = Gold)) {
                    Text("Apply", color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
private fun FilterSection(title: String, content: @Composable ColumnScope.() -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 14.dp),
    ) {
        Text(title, color = Dark, fontSize = 15.sp, fontWeight = FontWeight.ExtraBold)
        Spacer(Modifier.height(10.dp))
        content()
    }
    Box(Modifier.fillMaxWidth().height(1.dp).background(Line.copy(alpha = 0.5f)))
}

@Composable
private fun ProductPagination(page: Int, pageCount: Int, onPage: (Int) -> Unit) {
    if (pageCount <= 1) return
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
        OutlinedButton(onClick = { onPage((page - 1).coerceAtLeast(0)) }, enabled = page > 0, modifier = Modifier.weight(1f), shape = RoundedCornerShape(14.dp)) {
            Text("Prev", color = Dark, fontWeight = FontWeight.Bold)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(5.dp), verticalAlignment = Alignment.CenterVertically) {
            repeat(pageCount) { index ->
                Box(
                    Modifier
                        .size(if (index == page) 32.dp else 28.dp)
                        .background(if (index == page) Gold else Color.White, CircleShape)
                        .border(1.dp, if (index == page) Gold else Line, CircleShape)
                        .clickable { onPage(index) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text("${index + 1}", color = if (index == page) Color.White else Dark, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
        }
        OutlinedButton(onClick = { onPage((page + 1).coerceAtMost(pageCount - 1)) }, enabled = page < pageCount - 1, modifier = Modifier.weight(1f), shape = RoundedCornerShape(14.dp)) {
            Text("Next", color = Dark, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun FilterChip(label: String, active: Boolean, onClick: () -> Unit) {
    Box(
        Modifier
            .background(if (active) Gold.copy(alpha = 0.14f) else Color.White, RoundedCornerShape(18.dp))
            .border(1.dp, if (active) Gold else Line, RoundedCornerShape(18.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp),
    ) {
        Text(label, color = if (active) Gold else TextDark, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
    }
}

@Composable
private fun ProductListCard(product: ProductItem, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Card(
        modifier = modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.55f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier
                    .width(112.dp)
                    .height(128.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(SoftSurface),
            ) {
                if (product.image.isNotBlank()) {
                    AsyncImage(
                        model = product.image,
                        contentDescription = product.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize(),
                    )
                } else {
                    Box(Modifier.fillMaxSize().background(SoftSurface), contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.Inventory2, contentDescription = null, tint = Gold, modifier = Modifier.size(34.dp))
                    }
                }
                if (!product.is_in_stock) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(8.dp)
                            .background(SellRed, RoundedCornerShape(3.dp))
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                    ) {
                        Text("Out of Stock", color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                    }
                }
            }
            Column(Modifier.weight(1f)) {
                Text(
                    listOf(product.category, product.subcategory).filter { it.isNotBlank() }.joinToString(" / "),
                    color = Muted,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Start,
                    maxLines = 2,
                )
                Spacer(Modifier.height(4.dp))
                Text(product.title, color = Dark, fontSize = 17.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 21.sp, textAlign = TextAlign.Start, maxLines = 2)
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.Start, verticalAlignment = Alignment.CenterVertically) {
                    Text("Rs. ${product.price}", color = Gold, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
                    if (product.old_price.isNotBlank()) {
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "Rs. ${product.old_price}",
                            color = Muted,
                            fontSize = 12.sp,
                            textDecoration = TextDecoration.LineThrough,
                        )
                    }
                }
                Spacer(Modifier.height(8.dp))
                val meta = listOf(
                    product.weight.takeIf { it.isNotBlank() }?.let { "Weight: $it KG" },
                    listOf(product.metal_type, product.purity).filter { it.isNotBlank() }.joinToString(" | ").uppercase().ifBlank { null },
                ).filterNotNull()
                meta.forEach {
                    Text(it, color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold, textAlign = TextAlign.Start, lineHeight = 16.sp)
                }
                Spacer(Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    StockBadge(product.is_in_stock)
                    Spacer(Modifier.weight(1f))
                    Box(Modifier.size(30.dp).background(Gold.copy(alpha = 0.16f), CircleShape), contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.ChevronRight, contentDescription = null, tint = Gold, modifier = Modifier.size(18.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun ProductDetailScreen(slug: String, onBack: () -> Unit, onAuthExpired: () -> Unit) {
    val context = LocalContext.current
    var detail by remember(slug) { mutableStateOf<ProductDetail?>(null) }
    var contact by remember(slug) { mutableStateOf<ContactInfo?>(null) }
    var error by remember(slug) { mutableStateOf("") }
    LaunchedEffect(slug) {
        runCatching { ApiClient.service.contact(SessionStore.authorization) }
            .onSuccess { contact = it }
        runCatching { ApiClient.service.productDetail(SessionStore.authorization, slug) }
            .onSuccess { detail = it }
            .onFailure {
                if (it.isUnauthorized()) {
                    SessionStore.clear()
                    onAuthExpired()
                } else {
                    error = networkMessage(it, "Product detail is currently unavailable.")
                }
            }
    }
    TextButton(onClick = onBack) { Text("Back to Products", color = Gold, fontSize = 14.sp, fontWeight = FontWeight.Bold) }
    if (error.isNotBlank()) ErrorCard(error)
    detail?.let { item ->
        var activeImage by remember(item.slug) { mutableStateOf(0) }
        val displayImage = item.images.getOrNull(activeImage)
        val businessPhone = contact?.let { (it.footer_phone_numbers.firstOrNull() ?: it.phone).ifBlank { it.phone } }.orEmpty()

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.55f)),
        ) {
            Column(Modifier.padding(14.dp)) {
                if (displayImage != null) {
                    ZoomableProductImage(image = displayImage, title = item.title)
                    if (item.images.size > 1) {
                        Spacer(Modifier.height(10.dp))
                        Row(Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            item.images.forEachIndexed { index, image ->
                                AsyncImage(
                                    model = image,
                                    contentDescription = item.title,
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier
                                        .size(64.dp)
                                        .clip(RoundedCornerShape(8.dp))
                                        .border(2.dp, if (index == activeImage) Gold else Line, RoundedCornerShape(8.dp))
                                        .clickable { activeImage = index },
                                )
                            }
                        }
                    }
                }
                Spacer(Modifier.height(16.dp))
                Text(listOf(item.category, item.subcategory).filter { it.isNotBlank() }.joinToString(" / "), color = Gold, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                Text(item.title, color = Dark, fontSize = 25.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 30.sp)
                Spacer(Modifier.height(10.dp))
                SummaryBox(item)
                Spacer(Modifier.height(12.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Rs. ${item.price}", color = Gold, fontSize = 25.sp, fontWeight = FontWeight.ExtraBold)
                    if (item.old_price.isNotBlank()) {
                        Spacer(Modifier.width(8.dp))
                        Text("Rs. ${item.old_price}", color = Muted, fontSize = 16.sp, textDecoration = TextDecoration.LineThrough)
                    }
                }
                Text("Indicative pricing. Final bullion/jewellery rate may vary with live market movement.", color = Muted, fontSize = 13.sp, lineHeight = 19.sp)
                Spacer(Modifier.height(10.dp))
                StockBadge(item.is_in_stock)
                Spacer(Modifier.height(10.dp))
                TrustNote("Live rate linked pricing support available.", Icons.AutoMirrored.Outlined.TrendingUp)
                TrustNote("BIS/purity details shared transparently.", Icons.Outlined.VerifiedUser)
                TrustNote("Payment and billing support available.", Icons.Outlined.Payments)
                TrustNote("Bulk quote available for dealer requirements.", Icons.AutoMirrored.Outlined.Chat)
                if (item.description.isNotBlank()) {
                    Spacer(Modifier.height(12.dp))
                    Text("Description", color = Dark, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
                    Text(htmlToText(item.description), color = Muted, fontSize = 15.sp, lineHeight = 23.sp)
                }
                if (item.shipping_details.isNotBlank()) {
                    Spacer(Modifier.height(12.dp))
                    Box(Modifier.fillMaxWidth().background(SoftSurface, RoundedCornerShape(10.dp)).padding(12.dp)) {
                        Column {
                            Text("Shipping", color = Dark, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
                            Text(htmlToText(item.shipping_details), color = Muted, fontSize = 15.sp, lineHeight = 23.sp)
                        }
                    }
                }
                Spacer(Modifier.height(14.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Button(
                        onClick = { openDialer(context, businessPhone) },
                        modifier = Modifier.weight(1f).height(52.dp),
                        shape = RoundedCornerShape(8.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Gold),
                    ) {
                        Icon(Icons.Outlined.Call, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(6.dp))
                        Text("Make a Call", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }
                    Button(
                        onClick = { openWhatsApp(context, businessPhone) },
                        modifier = Modifier.weight(1f).height(52.dp),
                        shape = RoundedCornerShape(8.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = BuyGreen),
                    ) {
                        Icon(Icons.AutoMirrored.Outlined.Chat, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(6.dp))
                        Text("WhatsApp", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    } ?: if (error.isBlank()) LoadingBox() else Unit
}

@Composable
private fun ZoomableProductImage(image: String, title: String) {
    var scale by remember(image) { mutableStateOf(1f) }
    var offsetX by remember(image) { mutableStateOf(0f) }
    var offsetY by remember(image) { mutableStateOf(0f) }
    val transformState = rememberTransformableState { zoomChange, panChange, _ ->
        val nextScale = (scale * zoomChange).coerceIn(1f, 4f)
        scale = nextScale
        if (nextScale == 1f) {
            offsetX = 0f
            offsetY = 0f
        } else {
            offsetX = (offsetX + panChange.x).coerceIn(-280f, 280f)
            offsetY = (offsetY + panChange.y).coerceIn(-280f, 280f)
        }
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1f)
            .clip(RoundedCornerShape(8.dp))
            .background(SoftSurface)
            .transformable(transformState),
    ) {
        AsyncImage(
            model = image,
            contentDescription = title,
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer(
                    scaleX = scale,
                    scaleY = scale,
                    translationX = offsetX,
                    translationY = offsetY,
                ),
        )
    }
}

@Composable
private fun SummaryBox(item: ProductDetail) {
    Column(Modifier.fillMaxWidth().background(SoftSurface, RoundedCornerShape(10.dp)).padding(12.dp)) {
        SummaryRow("Category", listOf(item.category, item.subcategory).filter { it.isNotBlank() }.joinToString(" / "))
        SummaryRow("Metal", item.metal_type.ifBlank { "-" }.replaceFirstChar { it.uppercase() })
        if (item.weight.isNotBlank()) SummaryRow("Weight", "${item.weight} KG")
        if (item.purity.isNotBlank()) SummaryRow("Purity", item.purity)
        if (item.hallmark.isNotBlank()) SummaryRow("Hallmark", item.hallmark)
        if (item.making_charges.isNotBlank()) SummaryRow("Making Charges", "Rs. ${item.making_charges}")
    }
}

@Composable
private fun SummaryRow(label: String, value: String) {
    Row(Modifier.fillMaxWidth().padding(vertical = 5.dp), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(label, color = Muted, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(0.8f))
        Text(value.ifBlank { "-" }, color = Dark, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.weight(1.2f))
    }
}

@Composable
private fun TrustNote(text: String, icon: ImageVector) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 2.dp)) {
        Box(Modifier.size(24.dp).background(Gold.copy(alpha = 0.12f), CircleShape), contentAlignment = Alignment.Center) {
            Icon(icon, contentDescription = null, tint = Gold, modifier = Modifier.size(14.dp))
        }
        Spacer(Modifier.width(8.dp))
        Text(text, color = Muted, fontSize = 14.sp, lineHeight = 20.sp)
    }
}

@Composable
private fun ProfileScreen(resetSignal: Int, onLogout: () -> Unit) {
    var section by remember { mutableStateOf("menu") }
    var showLogoutDialog by remember { mutableStateOf(false) }

    LaunchedEffect(resetSignal) {
        section = "menu"
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = { Text("Logout?", color = Dark, fontWeight = FontWeight.ExtraBold) },
            text = { Text("Do you really want to logout?", color = Muted) },
            confirmButton = {
                Button(
                    onClick = {
                        showLogoutDialog = false
                        onLogout()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = SellRed),
                    shape = RoundedCornerShape(16.dp),
                ) {
                    Text("Yes", color = Color.White, fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                OutlinedButton(onClick = { showLogoutDialog = false }, shape = RoundedCornerShape(16.dp)) {
                    Text("No", color = Dark, fontWeight = FontWeight.Bold)
                }
            },
            containerColor = Color.White,
            shape = RoundedCornerShape(24.dp),
        )
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 14.dp, vertical = 16.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ProfileTopBar(
                title = when (section) {
                "edit" -> "Edit Profile"
                    "password" -> "Reset Password"
                    "support" -> "Help & Support"
                    "privacy" -> "Privacy Policy"
                    else -> "Profile"
                },
                showBack = section != "menu",
                onBack = { section = "menu" },
            )
            Spacer(Modifier.height(20.dp))
            ProfilePhoto(
                name = SessionStore.userName.ifBlank { "Customer" },
            )
            Spacer(Modifier.height(10.dp))
            Text(SessionStore.userName.ifBlank { "Customer" }.toTitleCase(), color = TextDark, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold, textAlign = TextAlign.Center)
            Text("+91 ${SessionStore.mobile}", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(24.dp))
            when (section) {
                "edit" -> ProfileDetailsSection()
                "password" -> PasswordResetProfileSection()
                "support" -> ContactProfileSection()
                "privacy" -> PrivacyPolicySection()
                else -> ProfileMenuCard {
                    ProfileMenuRow("Edit Profile", Icons.Outlined.Edit) { section = "edit" }
                    ProfileMenuRow("Reset Password", Icons.Outlined.Security) { section = "password" }
                    ProfileMenuRow("Help & Support", Icons.Outlined.SupportAgent) { section = "support" }
                    ProfileMenuRow("Privacy Policy", Icons.Outlined.Lock) { section = "privacy" }
                    ProfileMenuRow("Logout", Icons.Outlined.Delete, SellRed, showDivider = false) { showLogoutDialog = true }
                }
            }
        }
    }
}

@Composable
private fun ProfileTopBar(title: String, showBack: Boolean, onBack: () -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .background(if (showBack) SoftSurface else Color.Transparent, CircleShape)
                .clickable(enabled = showBack, onClick = onBack),
            contentAlignment = Alignment.Center,
        ) {
            if (showBack) {
                Icon(
                    Icons.Outlined.ChevronRight,
                    contentDescription = "Back",
                    tint = TextDark,
                    modifier = Modifier
                        .size(22.dp)
                        .scale(scaleX = -1f, scaleY = 1f),
                )
            }
        }
        Text(
            title,
            color = TextDark,
            fontSize = 18.sp,
            fontWeight = FontWeight.ExtraBold,
            textAlign = TextAlign.Center,
            modifier = Modifier.weight(1f),
        )
        Box(modifier = Modifier.size(40.dp))
    }
}

@Composable
private fun ProfilePhoto(name: String) {
    Box(contentAlignment = Alignment.Center) {
        Box(
            modifier = Modifier
                .size(86.dp)
                .background(Gold.copy(alpha = 0.95f), CircleShape)
                .border(3.dp, Color.White, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Text(name.firstOrNull()?.uppercase() ?: "C", color = Color.White, fontSize = 32.sp, fontWeight = FontWeight.ExtraBold)
        }
    }
}

@Composable
private fun ProfileMenuCard(content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.55f)),
    ) {
        Column(Modifier.padding(horizontal = 16.dp, vertical = 8.dp), content = content)
    }
}

@Composable
private fun ProfileMenuRow(label: String, icon: ImageVector, color: Color = TextDark, showDivider: Boolean = true, onClick: () -> Unit = {}) {
    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(58.dp)
                .clip(RoundedCornerShape(12.dp))
                .clickable(onClick = onClick),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(icon, contentDescription = null, tint = color, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(14.dp))
            Text(label, color = color, fontSize = 14.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            if (color != SellRed) {
                Icon(Icons.Outlined.ChevronRight, contentDescription = null, tint = Muted, modifier = Modifier.size(20.dp))
            }
        }
        if (showDivider) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(Line.copy(alpha = 0.42f)),
            )
        }
    }
}

@Composable
private fun ProfileAction(label: String, icon: ImageVector, active: Boolean, modifier: Modifier, onClick: () -> Unit) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(48.dp),
        shape = RoundedCornerShape(16.dp),
        colors = ButtonDefaults.outlinedButtonColors(containerColor = if (active) Dark else Color.White),
    ) {
        Icon(icon, contentDescription = null, tint = if (active) Color.White else Gold, modifier = Modifier.size(16.dp))
        Spacer(Modifier.width(6.dp))
        Text(label, color = if (active) Color.White else Dark, fontSize = 13.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun ProfileDetailsSection() {
    val scope = rememberCoroutineScope()
    var name by remember { mutableStateOf(SessionStore.userName.ifBlank { "Customer" }.toTitleCase()) }
    var mobile by remember { mutableStateOf(SessionStore.mobile) }
    var city by remember { mutableStateOf("") }
    var requestNote by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }
    Panel {
        Text("Edit Profile", color = Dark, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
        Text(
            "Changes will be sent for admin approval before they appear on your account.",
            color = Muted,
            fontSize = 14.sp,
            lineHeight = 21.sp,
        )
        Spacer(Modifier.height(14.dp))
        Field(value = name, onValueChange = { name = it.toTitleCase(); message = "" }, label = "Name")
        MobileField(value = mobile, onValueChange = { mobile = it; message = "" })
        Field(value = city, onValueChange = { city = it.toTitleCase(); message = "" }, label = "City")
        Field(value = requestNote, onValueChange = { requestNote = it; message = "" }, label = "Requested changes")
        PrimaryButton("Submit For Approval", loading = loading) {
            if (name.trim().length < 3) {
                message = "Please enter your full name."
                return@PrimaryButton
            }
            if (mobile.toIndianMobileDigits().length != 10) {
                message = "Please enter a valid 10 digit mobile number."
                return@PrimaryButton
            }
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.profileUpdateRequest(
                        SessionStore.authorization,
                        ProfileUpdateRequest(
                            name = name.trim().toTitleCase(),
                            mobile = mobile.toIndianMobileDigits(),
                            city = city.trim().toTitleCase(),
                            message = requestNote.trim(),
                        ),
                    )
                }.onSuccess {
                    message = "Your profile changes have been submitted for admin approval."
                }.onFailure {
                    message = apiMessage(it, "Unable to submit profile changes right now.")
                }
                loading = false
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun PrivacyPolicySection() {
    Panel {
        Text("Overview", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold)
        Text("Privacy Policy", color = Dark, fontSize = 21.sp, fontWeight = FontWeight.ExtraBold)
        Spacer(Modifier.height(8.dp))
        Text(
            "Shree Rudra Bullion & Jewels is committed to protecting your privacy and handling personal information responsibly. This Privacy Policy explains what information may be collected through our app and website, how that information may be used, and the choices available to you.\n\nBy using this app, contacting us, or sharing your information with us, you agree to the practices described in this Privacy Policy.\n\nEffective date: May 5, 2026",
            color = Muted,
            fontSize = 15.sp,
            lineHeight = 23.sp,
        )
        PrivacyBlock("Information You Provide Directly", "We may collect information you provide when you sign up, log in, update your profile, upload a profile image, submit a support form, call us, message us on WhatsApp, request live rates, or otherwise communicate with us. This may include name, phone number, address or location details, inquiry details, product interest, bullion rate requirements, profile image, and message content.")
        PrivacyBlock("Information Collected Automatically", "When you use the app or website, some technical information may be collected automatically to help operate, secure, and improve the service. This may include IP address, device information, operating system, pages or screens viewed, links clicked, date, time, duration of visits, and standard server log information.")
        PrivacyBlock("Information From Other Sources", "We may receive limited information from publicly available sources, business partners, website analytics providers, bullion rate data providers, or communication platforms where you contact us, as permitted by applicable law.")
        PrivacyBlock("How We Use Information", "We may use collected information to respond to inquiries and support requests, provide rate-related, product-related, jewellery-related, or service-related information, improve app and website performance, maintain internal records, send important updates where legally permitted, and protect against misuse, fraud, unauthorized activity, or security risks.")
        PrivacyBlock("Sharing of Information", "We do not sell your personal information. We may share information only when reasonably necessary with service providers who help operate the app or website, manage hosting, process enquiries, or respond to customer requests; to comply with legal obligations or valid government requests; or to protect our rights, customers, business operations, security, or lawful interests.")
        PrivacyBlock("Marketing and Communication Choices", "If you receive promotional or service-related communications from us, you may request that we stop sending non-essential communications. You may also contact us directly to update or correct the information you have shared with us.")
        PrivacyBlock("Data Security", "We use reasonable administrative, technical, and physical safeguards to protect information from unauthorized access, misuse, loss, or disclosure. However, no internet-based system or method of electronic storage can be guaranteed to be completely secure.")
        PrivacyBlock("Links to Other Services", "The app or website may contain links to third-party services including WhatsApp, payment, map, social media, analytics, or rate-related services. We are not responsible for the privacy practices, security, or content of those third-party services.")
        PrivacyBlock("Children's Privacy", "Our app and website are not intended for children, and we do not knowingly collect personal information from children.")
        PrivacyBlock("Changes to This Policy", "We may update this Privacy Policy from time to time to reflect changes in our practices, app or website functionality, or legal requirements. Updated versions will be posted with the revised effective date.")
        PrivacyBlock("Contact Us", "For privacy-related questions or requests, please contact Shree Rudra Bullion & Jewels through the contact details available in the app.")
    }
}

@Composable
private fun PrivacyBlock(title: String, body: String) {
    Spacer(Modifier.height(16.dp))
    Text(title, color = Dark, fontSize = 16.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 21.sp)
    Spacer(Modifier.height(6.dp))
    Text(body, color = Muted, fontSize = 15.sp, lineHeight = 23.sp)
}

@Composable
private fun ContactProfileSection() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var contact by remember { mutableStateOf<ContactInfo?>(null) }
    var subject by remember { mutableStateOf("Bullion enquiry") }
    var enquiry by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.contact(SessionStore.authorization) }
            .onSuccess { contact = it }
    }

    val primaryPhone = contact?.let { (it.footer_phone_numbers.firstOrNull() ?: it.phone).ifBlank { SessionStore.mobile } } ?: SessionStore.mobile
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = Dark),
    ) {
        Column(Modifier.padding(20.dp)) {
            Text("SUPPORT DESK", color = Gold, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
            Text("How can we help?", color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.ExtraBold)
            Text("Reach our team for live rates, product enquiries, profile help, or account support.", color = Color.White.copy(alpha = 0.72f), fontSize = 13.sp, lineHeight = 19.sp)
            Spacer(Modifier.height(16.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Button(
                    onClick = { openDialer(context, primaryPhone) },
                    modifier = Modifier.weight(1f).height(50.dp),
                    shape = RoundedCornerShape(18.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Gold),
                ) {
                    Icon(Icons.Outlined.Call, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("Call", color = Color.White, fontWeight = FontWeight.Bold)
                }
                Button(
                    onClick = { openWhatsApp(context, primaryPhone) },
                    modifier = Modifier.weight(1f).height(50.dp),
                    shape = RoundedCornerShape(18.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = BuyGreen),
                ) {
                    Icon(Icons.AutoMirrored.Outlined.Chat, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("WhatsApp", color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
    Spacer(Modifier.height(14.dp))
    Panel {
        InfoLine("Phone", primaryPhone.ifBlank { "-" }, Icons.Outlined.Call)
        contact?.address?.takeIf { it.isNotBlank() }?.let {
            InfoLine("Address", it, Icons.Outlined.LocationOn)
        }
    }
    Spacer(Modifier.height(14.dp))
    Panel {
        Text("Send an enquiry", color = Dark, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
        Text("Your message will be visible in admin with your account details.", color = Muted, fontSize = 14.sp, lineHeight = 21.sp)
        Spacer(Modifier.height(10.dp))
        Field(value = subject, onValueChange = { subject = it }, label = "Subject")
        Field(value = enquiry, onValueChange = { enquiry = it }, label = "Message")
        PrimaryButton("Submit Enquiry", loading = loading) {
            if (enquiry.trim().isBlank()) {
                message = "Please enter your enquiry message."
                return@PrimaryButton
            }
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.submitContact(
                        SessionStore.authorization,
                        ContactRequest(
                            name = SessionStore.userName.ifBlank { "App Customer" },
                            email = "",
                            phone = SessionStore.mobile,
                            subject = subject.trim().ifBlank { "App enquiry" },
                            message = enquiry.trim(),
                        ),
                    )
                }.onSuccess {
                    enquiry = ""
                    message = "Your enquiry has been submitted successfully."
                }.onFailure {
                    message = networkMessage(it, "Unable to submit your enquiry right now.")
                }
                loading = false
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun PasswordResetProfileSection() {
    val scope = rememberCoroutineScope()
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var message by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }

    SectionTitle("Security", "Reset Password")
    Panel {
        Text("Set a new password for your approved mobile account.", color = Muted, fontSize = 13.sp, lineHeight = 19.sp)
        Spacer(Modifier.height(12.dp))
        Field(value = password, onValueChange = { password = it }, label = "New password", password = true)
        Field(value = confirmPassword, onValueChange = { confirmPassword = it }, label = "Confirm password", password = true)
        PrimaryButton("Reset Password", loading = loading) {
            if (password != confirmPassword) {
                message = "Password and confirm password must match."
                return@PrimaryButton
            }
            scope.launch {
                loading = true
                message = ""
                runCatching {
                    ApiClient.service.forgotPassword(
                        ForgotPasswordRequest(
                            mobile = SessionStore.mobile,
                            password = password,
                            confirm_password = confirmPassword,
                        ),
                    )
                }.onSuccess {
                    message = "Your password has been reset successfully."
                }.onFailure {
                    message = apiMessage(it, "Unable to reset password. Please check the details and try again.")
                }
                loading = false
            }
        }
        if (message.isNotBlank()) MessageText(message)
    }
}

@Composable
private fun SectionTitle(eyebrow: String, title: String) {
    Text(eyebrow.uppercase(), color = Gold, fontWeight = FontWeight.Bold, fontSize = 13.sp)
    Text(title, color = Dark, fontWeight = FontWeight.Bold, fontSize = 24.sp)
    Spacer(Modifier.height(14.dp))
}

@Composable
private fun Panel(modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
    ) {
        Column(Modifier.padding(22.dp), content = content)
    }
}

@Composable
private fun AuthPanel(content: @Composable ColumnScope.() -> Unit) {
    BoxWithConstraints(Modifier.fillMaxWidth().imePadding()) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = maxHeight - 24.dp),
            shape = RoundedCornerShape(28.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            border = androidx.compose.foundation.BorderStroke(1.dp, Line.copy(alpha = 0.55f)),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
        ) {
            Column(
                Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(22.dp),
                content = content,
            )
        }
    }
}

@Composable
private fun Field(value: String, onValueChange: (String) -> Unit, label: String, password: Boolean = false, error: String = "") {
    var passwordVisible by remember { mutableStateOf(false) }
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        isError = error.isNotBlank(),
        trailingIcon = if (password) {
            {
                TextButton(onClick = { passwordVisible = !passwordVisible }) {
                    Text(if (passwordVisible) "Hide" else "Show", color = Gold, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                }
            }
        } else {
            null
        },
        supportingText = if (error.isNotBlank()) {
            { Text(error, color = SellRed) }
        } else {
            null
        },
        visualTransformation = if (password && !passwordVisible) PasswordVisualTransformation() else VisualTransformation.None,
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 12.dp),
    )
}

@Composable
private fun MobileField(value: String, onValueChange: (String) -> Unit, error: String = "") {
    OutlinedTextField(
        value = value,
        onValueChange = { onValueChange(it.toIndianMobileDigits()) },
        label = { Text("Mobile number") },
        leadingIcon = {
            Text("+91", color = Dark, fontWeight = FontWeight.Bold, modifier = Modifier.padding(start = 4.dp))
        },
        isError = error.isNotBlank(),
        supportingText = if (error.isNotBlank()) {
            { Text(error, color = SellRed) }
        } else {
            null
        },
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 12.dp),
    )
}

@Composable
private fun PrimaryButton(text: String, loading: Boolean, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        enabled = !loading,
        modifier = Modifier
            .fillMaxWidth()
            .height(52.dp),
        colors = ButtonDefaults.buttonColors(containerColor = Gold),
        shape = RoundedCornerShape(24.dp),
    ) {
        if (loading) {
            CircularProgressIndicator(color = Color.White, strokeWidth = 2.dp)
        } else {
            Text(text, color = Color.White, fontSize = 15.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun NavButton(item: DashboardTab, active: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .then(modifier)
            .height(68.dp)
            .clip(RoundedCornerShape(22.dp))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            Box(
                modifier = Modifier
                .size(36.dp)
                    .background(
                        if (active) Gold.copy(alpha = 0.16f) else SoftSurface,
                        CircleShape,
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    item.icon,
                    contentDescription = item.label,
                    tint = if (active) Gold else TextDark,
                    modifier = Modifier.size(19.dp),
                )
            }
            Spacer(Modifier.height(3.dp))
            Text(
                item.label,
                color = if (active) Gold else TextDark,
                fontSize = 11.sp,
                fontWeight = FontWeight.ExtraBold,
                maxLines = 1,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun LiveStatusBar(updated: String, loading: Boolean, onRefresh: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White, RoundedCornerShape(18.dp))
            .border(1.dp, Line, RoundedCornerShape(18.dp))
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .background(BuyGreen.copy(alpha = 0.12f), RoundedCornerShape(14.dp))
                .padding(horizontal = 10.dp, vertical = 5.dp),
        ) {
            Text("LIVE", color = BuyGreen, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text("Live update time", color = Dark, fontSize = 12.sp, fontWeight = FontWeight.ExtraBold)
            Text(updated.ifBlank { "-" }, color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
        Button(
            onClick = onRefresh,
            enabled = !loading,
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Dark, disabledContainerColor = Line),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 12.dp, vertical = 8.dp),
        ) {
            if (loading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(16.dp),
                    strokeWidth = 2.dp,
                    color = Dark,
                )
            } else {
                Icon(Icons.Outlined.Refresh, contentDescription = "Refresh live rates", tint = Color.White, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(5.dp))
                Text("Refresh", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
            }
        }
    }
}

@Composable
private fun RateTableHeader() {
    Row(
        Modifier
            .fillMaxWidth()
            .background(Dark, RoundedCornerShape(16.dp))
            .padding(horizontal = 14.dp, vertical = 11.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("Product", color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.weight(1.05f))
        Text("Buy", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold, textAlign = TextAlign.Center, modifier = Modifier.weight(1f))
        Text("Sell", color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold, textAlign = TextAlign.Center, modifier = Modifier.weight(1f))
    }
    Spacer(Modifier.height(8.dp))
}

@Composable
private fun RateRowCard(label: String, unit: String, buy: String, sell: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Column(Modifier.weight(1.05f)) {
                Text(label, color = Dark, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold, lineHeight = 18.sp)
                Spacer(Modifier.height(3.dp))
                Box(
                    modifier = Modifier
                        .background(SoftSurface, RoundedCornerShape(10.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp),
                ) {
                    Text(unit, color = Muted, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
            RateBox("BUY", buy, BuyGreen, Modifier.weight(1f))
            RateBox("SELL", sell, SellRed, Modifier.weight(1f))
        }
    }
    Spacer(Modifier.height(9.dp))
}

@Composable
private fun RateBox(label: String, value: String, color: Color, modifier: Modifier) {
    Box(
        modifier = modifier
            .heightIn(min = 68.dp)
            .background(color.copy(alpha = 0.11f), RoundedCornerShape(14.dp))
            .border(1.dp, color.copy(alpha = 0.22f), RoundedCornerShape(14.dp))
            .padding(horizontal = 6.dp, vertical = 9.dp),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                modifier = Modifier
                    .background(Color.White.copy(alpha = 0.9f), RoundedCornerShape(8.dp))
                    .border(1.dp, color.copy(alpha = 0.18f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 7.dp, vertical = 2.dp),
            ) {
                Text(label, color = color.copy(alpha = 0.78f), fontSize = 9.sp, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.height(7.dp))
            Text(
                if (value.isBlank()) "-" else "Rs $value",
                color = color,
                fontSize = 16.sp,
                fontWeight = FontWeight.ExtraBold,
                textAlign = TextAlign.Center,
                lineHeight = 19.sp,
            )
        }
    }
}

@Composable
private fun StockBadge(inStock: Boolean) {
    val color = if (inStock) BuyGreen else SellRed
    Box(
        modifier = Modifier
            .background(color.copy(alpha = 0.1f), RoundedCornerShape(12.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp),
    ) {
        Text(if (inStock) "In stock" else "Sold out", color = color, fontSize = 12.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun InfoLine(label: String, value: String, icon: ImageVector) {
    Row(Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .background(Gold.copy(alpha = 0.12f), CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = Gold, modifier = Modifier.size(19.dp))
        }
        Spacer(Modifier.width(12.dp))
        Column {
            Text(label, color = Muted, fontSize = 13.sp, fontWeight = FontWeight.Bold)
            Text(value, color = Dark, fontSize = 15.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun EmptyCard(text: String) {
    Panel { Text(text, color = Dark) }
}

@Composable
private fun ErrorCard(text: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(SellRed.copy(alpha = 0.1f), CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Text("!", color = SellRed, fontWeight = FontWeight.ExtraBold)
            }
            Spacer(Modifier.width(12.dp))
            Text(text, color = Dark, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
        }
    }
}

@Composable
private fun MessageText(text: String) {
    Text(text, color = Gold, modifier = Modifier.padding(vertical = 10.dp), fontWeight = FontWeight.Bold)
}

@Composable
private fun LoadingBox() {
    Row(Modifier.fillMaxWidth().padding(24.dp), horizontalArrangement = Arrangement.Center) {
        CircularProgressIndicator(color = Gold)
    }
}

private fun String.onlyDigits(): String = filter { it.isDigit() }

private fun String.toIndianMobileDigits(): String {
    val digits = onlyDigits()
    return if (digits.length == 12 && digits.startsWith("91")) digits.drop(2) else digits.take(10)
}

private fun Int?.orZero(): Int = this ?: 0

private fun String.toTitleCase(): String =
    trim()
        .split(Regex("\\s+"))
        .filter { it.isNotBlank() }
        .joinToString(" ") { word ->
            word.lowercase().replaceFirstChar { it.uppercase() }
        }

private fun String.isValidIndianMobile(): Boolean = length == 10 && firstOrNull() in listOf('6', '7', '8', '9')

private fun apiMessage(error: Throwable, fallback: String): String {
    val body = (error as? HttpException)?.response()?.errorBody()?.string().orEmpty()
    if (body.isBlank()) return fallback
    val detailMatch = Regex("\"detail\"\\s*:\\s*\"([^\"]+)\"").find(body)
    if (detailMatch != null) return detailMatch.groupValues[1]
    val firstListMessage = Regex("\\[\\s*\"([^\"]+)\"\\s*]").find(body)
    if (firstListMessage != null) return firstListMessage.groupValues[1]
    val firstString = Regex("\"[^\"]+\"\\s*:\\s*\"([^\"]+)\"").find(body)
    return firstString?.groupValues?.getOrNull(1) ?: fallback
}

private fun Throwable.isUnauthorized(): Boolean = (this as? HttpException)?.code() == 401

private fun networkMessage(error: Throwable, fallback: String): String {
    return when (error) {
        is SocketTimeoutException -> "Connection timed out. Please make sure the server is running and your phone is on the same network."
        is UnknownHostException -> "Server is not reachable. Please check your network connection."
        is HttpException -> if (error.code() == 401) "Your session has expired. Please sign in again." else fallback
        else -> fallback
    }
}

private fun openDialer(context: android.content.Context, phone: String) {
    val number = phone.filter { it.isDigit() || it == '+' }
    if (number.isBlank()) return
    context.startActivity(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number")))
}

private fun openWhatsApp(context: android.content.Context, phone: String) {
    val digits = phone.filter { it.isDigit() }
    if (digits.isBlank()) return
    val whatsappNumber = if (digits.length == 10) "91$digits" else digits
    val uri = Uri.parse("https://wa.me/$whatsappNumber")
    context.startActivity(Intent(Intent.ACTION_VIEW, uri))
}

private fun htmlToText(value: String): String {
    return Html.fromHtml(value, Html.FROM_HTML_MODE_LEGACY).toString().trim()
}
