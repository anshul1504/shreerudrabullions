# Shree Rudra Bullion — iOS app

Native SwiftUI app with the same features as `android-app/`, built on the same Django API (`/api/v1/`).

- iOS 17+, iPhone, portrait
- Xcode 16 or newer (the project uses synchronized folders: a new `.swift` file added under `ShreeRudraBullion/` is picked up automatically)
- One dependency: Firebase Messaging (Swift Package Manager, resolves on first open)

## Run it

1. Open `ios-app/ShreeRudraBullion.xcodeproj` in Xcode.
2. Pick an iPhone simulator and press Run. It talks to `https://shreerudrabullion.com/api/v1/` by default.

To use a local Django server, change the `API_BASE_URL` build setting (target → Build Settings → User-Defined), for example to `http://127.0.0.1:8000/api/v1/`. Local-network HTTP is allowed via `NSAllowsLocalNetworking`; production stays HTTPS-only.

## Layout

```
ShreeRudraBullion/
  App/            entry point, root routing (splash → auth / signed out / dashboard), AppDelegate (Firebase, APNs)
  Core/           API client + endpoints, models, session (Keychain), notifications, formatting helpers
  DesignSystem/   colours, Poppins fonts, shared components
  Features/       Splash, Auth, Dashboard, LiveRates, Home, Products, About, Profile
  Resources/      assets, fonts, PrivacyInfo.xcprivacy (+ GoogleService-Info.plist once added)
Supporting/       Info.plist, entitlements
ShreeRudraBullionTests/  unit tests (Swift Testing)
```

## Before the first TestFlight build

1. **Apple Developer account**: in Xcode, target → Signing & Capabilities → select the team. The bundle ID is `com.shreerudra.bullion`.
2. **Push notifications**:
   - developer.apple.com → Keys → create an APNs key (.p8).
   - Firebase console → project `shree-rudra-bullion` → add an iOS app with bundle ID `com.shreerudra.bullion` → download `GoogleService-Info.plist` and drop it into `ShreeRudraBullion/Resources/`.
   - Firebase → Project settings → Cloud Messaging → Apple app configuration → upload the .p8 key with its Key ID and Team ID.
   - Without the plist the app still runs; only push is switched off.
3. **Release entitlement**: `Supporting/ShreeRudraBullion.entitlements` has `aps-environment = development`. Xcode sets it to production automatically when archiving with automatic signing.
4. Product → Archive → Distribute App → App Store Connect.

The backend needs no change: `send_account_approved_notification()` already sends through FCM, which reaches iOS via APNs.

## App Store review notes

- Give the reviewer an **approved demo account** (mobile + password). Signup needs admin approval, so a reviewer cannot create one.
- Account deletion is in Profile → Delete Account.
- Privacy policy: Profile → Privacy Policy (also add the website URL in App Store Connect).
- App Privacy answers: Name, Phone number, User ID, Device ID (push token), Customer support. All linked to the user, none used for tracking.

## Tests

Product → Test in Xcode, or:

```
xcodebuild test -project ShreeRudraBullion.xcodeproj -scheme ShreeRudraBullion \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```
