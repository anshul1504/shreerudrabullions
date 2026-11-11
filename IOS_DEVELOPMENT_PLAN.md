# Shree Rudra Bullion — iOS App Development Plan

Goal: build an iOS app with the same features and behaviour as the current Android app (`android-app/`, v1.0.3 / versionCode 5), using the same Django backend (`/api/v1/`). The backend needs no breaking changes.

---

## 1. Current system (what exists today)

### Backend (Django + DRF + SimpleJWT)
- Production API: `https://shreerudrabullion.com/api/v1/`
- Auth: JWT, access token 12 h, refresh token ~10 years, no rotation.
- Push: `firebase-admin`, Firebase project `shree-rudra-bullion`. A push goes out when an admin approves a signup request (`admin.py` → `send_account_approved_notification(fcm_token)`).

| Endpoint | Method | Auth | Used for |
|---|---|---|---|
| `auth/signup-request/` | POST | – | Signup request (name, mobile, password, confirm, message, fcm_token) |
| `auth/signup-status/?mobile=` | GET | – | Pending / approved / rejected polling |
| `auth/login/` | POST | – | Mobile + password → access, refresh, user |
| `auth/forgot-password/` | POST | – | Mobile + new password |
| `auth/refresh/` | POST | – | New access token |
| `profile/` | GET / POST multipart | JWT | Profile; image upload (not used in the Android UI) |
| `profile/update-request/` | POST | JWT | Profile change request for admin approval |
| `profile/delete-account/` | POST | JWT | Permanent account deletion |
| `home/` | GET | JWT | Sliders, categories, products, testimonials, tab-visibility flags |
| `about/` | GET | JWT | About page content, brands, testimonials |
| `live-rates/` | GET | JWT | Rates table (polled every 3 s) |
| `categories/` | GET | JWT | Not used in the Android UI |
| `products/`, `products/<slug>/` | GET | JWT | Product list and detail |
| `contact/` | GET / POST | JWT | Contact info, enquiry submit |
| `privacy-policy/` | GET | – | Privacy policy text |

### Android app (Kotlin + Jetpack Compose)
- `data/`: Retrofit `ApiService`, OkHttp `Authenticator` (refreshes the token automatically on a 401), `SessionStore` (SharedPreferences), FCM service, WorkManager approval check every 15 min, local notification.
- `ui/ShreeRudraApp.kt` (~2,950 lines): every screen is in this one file.
- Assets: Poppins fonts (Regular, Bold, ExtraBold), `app_logo.jpeg`, `splash_om_bg.jpg`, `auth_om_bg.jpg`, `auth_bullion_bg.jpg`, `whatsapp_logo.webp`.
- Theme colours: Gold `#B27A13`, Dark `#111318`, Surface `#FFFCF5`, SoftSurface `#F6F4EF`, Line `#E8D8B5`, Muted `#6F6B62`, TextDark `#181A20`, BuyGreen `#006A3A`, SellRed `#9E1111`.

---

## 2. Feature parity checklist (Android → iOS)

Every row must work on iOS before release.

| # | Feature | Android behaviour | iOS implementation |
|---|---|---|---|
| 1 | Splash | Om background, logo drops in, 3.4 s, spinner | SwiftUI view with spring/offset animation and the same timing; static LaunchScreen first |
| 2 | Welcome | Login / Signup choice on Om background | Same |
| 3 | Login | Mobile (10-digit, starts with 6–9) + password | Same validation, number pad keyboard |
| 4 | Signup request | Name, mobile, password, confirm, message, FCM token; success message for 5 s; saves the pending mobile number | Same; send the FCM token from Firebase iOS |
| 5 | Approval polling | Polls every 15 s on the auth screen; shows approved/rejected message and a local notification | Foreground `Task` loop every 15 s + `UNUserNotificationCenter` local notification |
| 6 | Background approval check | WorkManager every 15 min | iOS has no exact equivalent. Primary path is FCM/APNs push; fallback is `BGAppRefreshTask` (best effort only) |
| 7 | Approval push | FCM `type=account_approved` | FCM over APNs, same payload |
| 8 | Forgot password | Mobile + new password | Same (see security note in section 8) |
| 9 | Signed-out screen | Shown after logout or a 401 | Same |
| 10 | Dashboard tabs | Home, Products, Live, About, Profile. Default tab: Live. Home and Products can be hidden by flags from `home/` | Custom floating tab bar (rounded, shadow) to match Android; hide tabs based on the flags |
| 11 | Floating Call / WhatsApp | First footer phone number, otherwise site phone | `tel:` and `https://wa.me/91XXXXXXXXXX` via `openURL` |
| 12 | Home | Auto slider (2.6 s), service strip, "Why choose us" grid, auto-scrolling categories, featured products, commitment counters, testimonials, trust strip | Same sections; `TabView(.page)` slider with a timer; horizontal `ScrollView` with auto-scroll |
| 13 | Live rates | Poll every 3 s, buy/sell table, green/red flash when a value moves, Refresh button, disclaimer | `Task` loop tied to the view lifecycle (stops in background), same flash animation |
| 14 | Products list | Search, filters (category with counts, metal, purity, in-stock only), Discard/Apply, 6 per page | Same client-side filtering and paging |
| 15 | Product detail | Image gallery with pinch zoom, summary box, description (HTML → text), shipping, stock badge, trust notes | `TabView` gallery + `MagnifyGesture`; HTML via `NSAttributedString` or tag stripping |
| 16 | About | Hero, vision/mission cards, story card, brands, testimonials | Same |
| 17 | Profile menu | Edit, Reset Password, Delete Account, Help & Support, Privacy, Logout (with confirmation) | Same, using `NavigationStack` inside the tab; tapping the tab resets to the menu |
| 18 | Edit profile | Request sent for admin approval | Same |
| 19 | Reset password (logged in) | Calls forgot-password with the session mobile | Same |
| 20 | Delete account | Current password + reason → logout | Same (also required by App Store guideline 5.1.1(v)) |
| 21 | Help & Support | Contact info + enquiry form | Same; also `mailto:` |
| 22 | Privacy policy | From the API | Same; the same URL also goes in App Store Connect |
| 23 | Token refresh | OkHttp Authenticator, single-flight | Swift `actor TokenRefresher`: single-flight refresh, retries the request once |
| 24 | Session | SharedPreferences | Keychain for tokens; UserDefaults for name, mobile, pending signup |

Optional extras (not in Android, do not block release): profile photo upload (the API already supports it), dark mode, iPad layout.

---

## 3. Technical decisions

| Topic | Decision | Reason |
|---|---|---|
| Framework | **Native SwiftUI** | Android is native Compose, so SwiftUI maps almost screen for screen. Flutter or React Native would mean a rewrite of both apps. |
| Min iOS | **iOS 17.0** | `@Observable`, `NavigationStack`, `MagnifyGesture`; covers more than 90% of active iPhones |
| Xcode | 27.1 (already installed on this Mac) | – |
| Architecture | MVVM-lite: one `@Observable` ViewModel per screen + shared `APIClient` / `SessionStore` | Simple and matches the Android data layer |
| Networking | `URLSession` + `async/await` + `Codable` (`.convertFromSnakeCase`) | No Alamofire needed |
| Images | `AsyncImage` + `URLCache` (50 MB); switch to Nuke only if needed | Keeps dependencies low |
| Push | Firebase Messaging via Swift Package Manager | The backend already sends via FCM, so it needs no change |
| Storage | Keychain (tokens), UserDefaults (non-sensitive values) | Security |
| Bundle ID | `com.shreerudra.bullion` (same as Android) | Consistent branding; register it in Firebase |
| Fonts | Poppins TTFs copied from Android, registered under `UIAppFonts` | Same look |

### Third-party dependencies
- `firebase-ios-sdk` (FirebaseMessaging only)
- Nothing else is required.

---

## 4. Project structure

```
navinproducts/ios-app/
├── ShreeRudraBullion.xcodeproj
├── ShreeRudraBullion/
│   ├── App/
│   │   ├── ShreeRudraBullionApp.swift      // @main, root routing (splash/auth/dashboard)
│   │   ├── AppDelegate.swift               // Firebase, APNs, FCM token, notification delegate
│   │   └── AppConfig.swift                 // API base URL per build config
│   ├── Core/
│   │   ├── Network/
│   │   │   ├── APIClient.swift             // generic request, JSON decode, 401 handling
│   │   │   ├── Endpoint.swift              // all 16 endpoints
│   │   │   ├── APIError.swift              // DRF "detail" / field-error parsing (= apiMessage())
│   │   │   └── TokenRefresher.swift        // actor, single-flight refresh
│   │   ├── Storage/
│   │   │   ├── KeychainStore.swift
│   │   │   └── SessionStore.swift          // @Observable, mirrors SessionStore.kt
│   │   ├── Push/
│   │   │   ├── PushManager.swift           // permission, FCM token, local "Account approved"
│   │   │   └── ApprovalRefreshTask.swift   // BGAppRefreshTask fallback
│   │   └── Utils/
│   │       ├── Validators.swift            // onlyDigits, toIndianMobileDigits, isValidIndianMobile
│   │       ├── String+Format.swift         // toTitleCase, htmlToText
│   │       └── ExternalLinks.swift         // openDialer, openWhatsApp
│   ├── Models/                             // Codable copies of ApiModels.kt
│   ├── DesignSystem/
│   │   ├── Theme.swift                     // colours, fonts
│   │   └── Components/                     // Panel, AuthPanel, Field, MobileField, PrimaryButton,
│   │                                       // SectionTitle, ErrorCard, EmptyCard, LoadingBox, MessageText,
│   │                                       // StockBadge, InfoLine, FilterChip, QuickContactActions
│   ├── Features/
│   │   ├── Splash/
│   │   ├── Auth/            // Welcome, Login, Signup, ForgotPassword, SignedOut, AuthViewModel
│   │   ├── Dashboard/       // DashboardView, FloatingTabBar, DashboardHeader
│   │   ├── Home/
│   │   ├── LiveRates/       // LiveRatesView, RateRowCard, RateBox (flash), LiveRatesViewModel
│   │   ├── Products/        // List, Toolbar, FilterPanel, Pagination, Detail, ZoomableImage
│   │   ├── About/
│   │   └── Profile/         // Menu, EditProfile, ResetPassword, DeleteAccount, Support, Privacy
│   └── Resources/
│       ├── Assets.xcassets  // AppIcon, logo, backgrounds, whatsapp logo
│       ├── Fonts/
│       ├── GoogleService-Info.plist
│       ├── PrivacyInfo.xcprivacy
│       └── Info.plist
└── ShreeRudraBullionTests/  // validators, model decoding, token refresh, filters
```

Build configurations:
- **Debug**: `API_BASE_URL = http://127.0.0.1:8000/api/v1/` (the simulator can reach the Mac directly; Android used `10.0.2.2`). Add an ATS exception for localhost only.
- **Release**: `API_BASE_URL = https://shreerudrabullion.com/api/v1/`, no ATS exceptions.

---

## 5. Prerequisites (sort these out before development starts)

| # | Item | Owner | Notes |
|---|---|---|---|
| P1 | **Apple Developer Program account** ($99/year) | Client | Use an **Organization** account in the name of "Shree Rudra Bullion" so the store listing shows the company name. It needs a D-U-N-S number, which takes 1–2 weeks, so **start this first**. Add us as Admin/Developer. |
| P2 | Register App ID `com.shreerudra.bullion` with the Push Notifications capability | Us | developer.apple.com |
| P3 | **APNs Auth Key (.p8)** | Us | Upload it to Firebase Console → Project settings → Cloud Messaging → Apple app config |
| P4 | Add an iOS app to Firebase project `shree-rudra-bullion` | Us | Download `GoogleService-Info.plist` |
| P5 | **Demo reviewer account** (approved mobile + password) | Client/Us | Apple cannot sign up and wait for admin approval, so App Review must have working login details |
| P6 | App icon 1024×1024 PNG, no transparency | Client/Us | `app_logo.jpeg` can be used if its resolution is high enough |
| P7 | App Store listing content: name, subtitle, description, keywords, support URL, privacy policy URL, category (Finance / Business) | Client/Us | – |
| P8 | Physical iPhone for testing | Us | Push notifications do not work on the simulator in a production-like way |

---

## 6. Development phases and timeline (1 iOS developer)

| Phase | Work | Estimate |
|---|---|---|
| **0. Setup** | Xcode project, folders, build configs, Firebase SPM, fonts and assets, Theme, Info.plist, Git branch `ios-app` | 1 day |
| **1. Core layer** | Models (all API responses), APIClient, Endpoint, APIError parsing, TokenRefresher, Keychain, SessionStore, validators, unit tests | 2–3 days |
| **2. Design system** | All shared components (Panel, Field, MobileField, PrimaryButton, cards, chips, floating tab bar, quick contact buttons) | 2 days |
| **3. Auth flow** | Splash, Welcome, Login, Signup, Forgot Password, Signed Out, approval polling, root routing | 3 days |
| **4. Dashboard + Live Rates** | Tab shell, visibility flags, header, 3 s rate polling with flash animation, refresh, lifecycle pause/resume | 2–3 days |
| **5. Products** | List, search, filters, pagination, detail, zoomable gallery, HTML text | 3 days |
| **6. Home + About** | Slider, service strip, grids, auto-scrolling cards, counters, testimonials, brands | 3 days |
| **7. Profile** | Menu, edit request, reset password, delete account, support/enquiry, privacy, logout dialog | 2 days |
| **8. Push notifications** | APNs + FCM token, signup token sending, foreground/background handling, local notification, BGAppRefresh fallback, end-to-end test from Django admin approval | 2 days |
| **9. QA and polish** | Side-by-side check against Android on every screen, small screens (iPhone SE) and large screens (Pro Max), Dynamic Type, offline/error states, 401 expiry, memory and battery use during rate polling | 3–4 days |
| **10. Release** | Privacy manifest, App Privacy labels, screenshots (6.9" and 6.5"), TestFlight internal → client review → submit, handle review feedback | 2–3 days (plus Apple review time, usually 1–3 days) |

**Total: about 25–30 working days (5–6 weeks)**, plus the D-U-N-S/account wait, which runs in parallel.

### Milestones for client demos
1. **M1 (end of week 2)**: TestFlight build with login, signup and live rates working against production.
2. **M2 (end of week 4)**: all screens finished (feature-complete).
3. **M3 (end of week 5–6)**: push notifications verified, QA done, submitted to the App Store.

---

## 7. Implementation details to get right

1. **Rate polling**: run it in `.task {}` so it cancels automatically when the tab changes. Pause it when `scenePhase != .active`. Compare old and new values per `key:buy` / `key:sell` exactly like `compareRateValues()` (strip non-digits, compare as numbers).
2. **401 handling**: try refresh once. If refresh fails → `SessionStore.clear()` → Signed-out screen, same as Android's `onAuthExpired`.
3. **Error messages**: parse DRF errors the same way as `apiMessage()` (`detail`, or the first field error) so the iOS and Android messages match.
4. **Mobile normalisation**: strip `+91`/`91`, keep 10 digits, first digit 6–9.
5. **Keyboard**: use `.keyboardType(.numberPad)` for mobile and `.textContentType(.password / .newPassword)` for passwords, so iOS password autofill works.
6. **WhatsApp**: the `https://wa.me/` link works without the WhatsApp URL scheme, so no `LSApplicationQueriesSchemes` entry is needed.
7. **Push payload**: the backend sends `notification` + `data.type`. For a sound on iOS, optionally add `apns=messaging.APNSConfig(payload=messaging.APNSPayload(aps=messaging.Aps(sound="default")))` in `push_notifications.py`. This is an additive change and does not affect Android.
8. **Background check limitation**: tell the client that iOS does not allow an exact 15-minute background job. Approval alerts on iOS depend on push, and the in-app check runs when the app is opened.
9. **Screen size**: the Android layout is portrait only. Lock iOS to portrait on iPhone as well.

---

## 8. Risks and backend issues found during review

| Severity | Issue | Impact | Recommendation |
|---|---|---|---|
| 🔴 High | **`auth/forgot-password/` resets the password with only a mobile number, without OTP or any verification.** Anyone who knows an approved customer's mobile number can take over that account. This already affects the Android app. | Security / account takeover | Add OTP (SMS, e.g. MSG91 or Twilio) or an admin-approved reset before the iOS launch. The logged-in "Reset Password" should also require the current password. Both apps would need a small update. |
| 🟠 Medium | **App Store review: the whole app is behind login, and signup needs manual approval.** Apple reviewers need a working demo account (P5); without one the app gets rejected under guideline 2.1. | Rejection | Give demo credentials in the review notes, and explain in the notes that this is a B2B app for registered bullion customers. |
| 🟠 Medium | Apple guideline 4.2 (minimum functionality): if the app looks like "just the website", Apple can reject it. | Rejection | Live rates, push alerts, enquiries and the account features help. Keep the native UI polished. |
| 🟡 Low | The delete-account message on the backend says "from the Android app". | Wrong label in admin | Make the text generic, or pass a `platform` field. |
| 🟡 Low | `fcm_token` is only sent at signup. If the token rotates before approval, the push can be missed. | Missed push | Accept it for parity, since the polling fallback exists. Optionally add a `platform` field to `AppSignupRequest` for reporting. |
| 🟡 Low | The refresh token lasts about 10 years with no rotation or blacklist. | A stolen token stays valid | Optional: enable rotation and blacklisting later; both apps already handle refresh. |

---

## 9. App Store compliance checklist
- [ ] In-app account deletion (exists ✔)
- [ ] Privacy policy URL, reachable in the app and on the web
- [ ] `PrivacyInfo.xcprivacy` (UserDefaults required-reason API: `CA92.1`)
- [ ] App Privacy labels: Name, Phone number, User ID, Device ID (push token), Customer support messages. All "linked to user", none used for tracking.
- [ ] No App Tracking Transparency prompt needed (no tracking)
- [ ] Export compliance: uses only standard HTTPS → `ITSAppUsesNonExemptEncryption = NO`
- [ ] Notification permission asked with clear context (after signup/login, not on the first frame)
- [ ] Rates disclaimer shown (exists ✔)
- [ ] Demo account in the review notes

---

## 10. Testing plan
- **Unit tests**: validators, model decoding against real JSON captured from production, token-refresh single-flight, product filter/pagination logic, rate comparison.
- **Manual test matrix**: iPhone SE (small), iPhone 15/16 (standard), Pro Max (large); iOS 17 and the latest iOS.
- **Flow tests**: signup → admin approve in Django → push received → login → all tabs → logout; token expiry (shorten the lifetime on staging); airplane mode on every screen; account deletion.
- **Parity review**: run Android and iOS side by side and screenshot every screen for client sign-off.

---

## 11. Next steps
1. Client starts the Apple Developer Organization enrollment (D-U-N-S) now.
2. Decide on the forgot-password OTP fix (backend change, affects both apps).
3. Set up Firebase iOS and the APNs key once the developer account is active.
4. Start Phase 0–1 right away. The simulator does not need the paid account, so the account wait does not block development.
