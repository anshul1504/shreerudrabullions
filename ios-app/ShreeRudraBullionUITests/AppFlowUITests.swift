import XCTest

/// End-to-end smoke test through every screen.
///
/// The signed-in part needs an approved account. Pass it through the environment, e.g.
///   TEST_RUNNER_SR_MOBILE=98xxxxxxxx TEST_RUNNER_SR_PASSWORD=... xcodebuild test ...
/// Set TEST_RUNNER_SR_SCREENSHOT_DIR to also write each screen as a PNG.
final class AppFlowUITests: XCTestCase {
    private var app: XCUIApplication!
    private let env = ProcessInfo.processInfo.environment

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--reset-session"]
        addUIInterruptionMonitor(withDescription: "Notifications") { alert in
            let allow = alert.buttons["Allow"]
            if allow.exists {
                allow.tap()
                return true
            }
            return false
        }
        app.launch()
    }

    func testAuthScreens() {
        let signIn = app.buttons["SIGN IN"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 10))
        dismissSystemAlert()
        capture("01-welcome")

        app.buttons["SIGN UP"].tap()
        XCTAssertTrue(app.buttons["Send Request"].waitForExistence(timeout: 3))
        capture("02-signup")
        app.buttons["Send Request"].tap()
        XCTAssertTrue(app.staticTexts["Enter your full name."].waitForExistence(timeout: 2))
        capture("03-signup-validation")

        app.buttons["Back"].firstMatch.tap()
        signIn.tap()
        XCTAssertTrue(app.buttons["Forgot password?"].waitForExistence(timeout: 3))
        capture("04-login")
        app.buttons["Forgot password?"].tap()
        XCTAssertTrue(app.buttons["Reset Password"].waitForExistence(timeout: 3))
        capture("05-forgot-password")
    }

    func testSignedInFlow() throws {
        guard let mobile = env["SR_MOBILE"], let password = env["SR_PASSWORD"] else {
            throw XCTSkip("Set TEST_RUNNER_SR_MOBILE and TEST_RUNNER_SR_PASSWORD to run the signed-in flow.")
        }
        let signIn = app.buttons["SIGN IN"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 10))
        dismissSystemAlert()
        signIn.tap()

        let mobileField = app.textFields.firstMatch
        XCTAssertTrue(mobileField.waitForExistence(timeout: 3))
        mobileField.tap()
        mobileField.typeText(mobile)
        let passwordField = app.secureTextFields.firstMatch
        passwordField.tap()
        passwordField.typeText(password)
        app.buttons["Sign in"].tap()

        XCTAssertTrue(app.staticTexts["Live Rates"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Buy"].waitForExistence(timeout: 10))
        // The simulator offers to save the password a few seconds after sign-in. That sheet is
        // drawn by a system process the query API can't reach, so tap where "Not Now" sits.
        sleep(8)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.32, dy: 0.625)).tap()
        sleep(2)
        capture("10-live-rates")

        tab("Home")
        XCTAssertTrue(app.staticTexts["WHY CHOOSE US"].waitForExistence(timeout: 10))
        sleep(2)
        capture("11-home")
        app.swipeUp()
        app.swipeUp()
        capture("12-home-products")
        app.swipeUp()
        app.swipeUp()
        capture("13-home-footer")

        tab("Products")
        XCTAssertTrue(app.staticTexts["Product Inventory"].waitForExistence(timeout: 10))
        sleep(2)
        capture("20-products")
        app.buttons["Filter"].tap()
        XCTAssertTrue(app.staticTexts["Filters"].waitForExistence(timeout: 3))
        capture("21-products-filters")
        app.buttons["Apply"].tap()

        let productCard = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Rs.'")).firstMatch
        if productCard.waitForExistence(timeout: 5) {
            productCard.tap()
            XCTAssertTrue(app.buttons["Back to Products"].waitForExistence(timeout: 5))
            sleep(2)
            capture("22-product-detail")
            app.swipeUp()
            capture("23-product-detail-bottom")
        }

        tab("About")
        XCTAssertTrue(app.staticTexts["ABOUT US"].waitForExistence(timeout: 10))
        sleep(2)
        capture("30-about")

        tab("Profile")
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
        capture("40-profile")
        for (row, name) in [("Edit Profile", "41-edit-profile"), ("Help & Support", "42-support"), ("Delete Account", "43-delete-account")] {
            app.buttons[row].tap()
            sleep(1)
            capture(name)
            app.buttons["Back"].firstMatch.tap()
        }

        app.buttons["Logout"].tap()
        XCTAssertTrue(app.alerts["Logout?"].waitForExistence(timeout: 3))
        capture("44-logout-dialog")
        app.alerts["Logout?"].buttons["Yes"].tap()
        XCTAssertTrue(app.staticTexts["Sign in required"].waitForExistence(timeout: 5))
        capture("45-signed-out")
    }

    private func tab(_ label: String) {
        let button = app.buttons[label].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing tab \(label)")
        button.tap()
    }

    private func dismissSystemAlert() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons["Allow"]
        if allow.waitForExistence(timeout: 2) {
            allow.tap()
        }
    }

    private func capture(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let directory = env["SR_SCREENSHOT_DIR"] {
            try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: directory).appendingPathComponent("\(name).png"))
        }
    }
}
