import XCTest

@MainActor final class InterfaceTests: XCTestCase {
    func testEditingPersistenceAndLongPressDoesNotPlay() {
        let app = XCUIApplication(); app.launch()
        let paw = app.buttons["paw-6"]
        XCTAssertTrue(paw.waitForExistence(timeout: 5))
        paw.press(forDuration: 0.7)
        XCTAssertTrue(app.buttons["save-label"].waitForExistence(timeout: 3))
        XCTAssertEqual(paw.value as? String, "已停止")
        app.buttons["cancel-label"].tap()
        XCTAssertEqual(paw.value as? String, "已停止")
        let original = paw.label
        paw.press(forDuration: 0.7)
        let field = app.textViews["label-input"].exists ? app.textViews["label-input"] : app.textFields["label-input"]
        field.tap()
        app.buttons["clear-label"].tap()
        XCTAssertFalse(app.buttons["save-label"].isEnabled)
        field.typeText(String(repeating: "a", count: 60))
        app.buttons["save-label"].tap()
        XCTAssertEqual(paw.label, String(repeating: "a", count: 60))
        app.terminate(); app.launch()
        XCTAssertEqual(app.buttons["paw-6"].label, String(repeating: "a", count: 60))
        paw.tap(); XCTAssertEqual(paw.value as? String, "正在播放")
        paw.tap(); XCTAssertEqual(paw.value as? String, "已停止")
        paw.press(forDuration: 0.7)
        let restore = app.textViews["label-input"].exists ? app.textViews["label-input"] : app.textFields["label-input"]
        restore.tap(); app.buttons["clear-label"].tap()
        restore.typeText(original)
        app.buttons["save-label"].tap()
    }
    func testLongLabelLayoutEvidence() {
        let app = XCUIApplication(); app.launch()
        let paw = app.buttons["paw-0"]
        XCTAssertTrue(paw.waitForExistence(timeout: 5))
        let original = paw.label
        paw.press(forDuration: 0.7)
        app.buttons["clear-label"].tap()
        let input = app.textViews["label-input"].exists ? app.textViews["label-input"] : app.textFields["label-input"]
        input.tap(); input.typeText(String(repeating: "喜欢和你一起玩", count: 10))
        app.buttons["save-label"].tap()
        XCTAssertEqual(paw.label.count, 60)
        for id in 0..<12 { XCTAssertTrue(app.frame.contains(app.buttons["paw-\(id)"].frame)) }
        let normal = XCTAttachment(screenshot: app.screenshot()); normal.name = "60 Chinese characters default screen"; normal.lifetime = .keepAlways; add(normal)
        app.terminate()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["paw-0"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.frame.contains(app.buttons["paw-0"].frame))
        XCTAssertEqual(app.buttons["paw-0"].label.count, 60)
        let large = XCTAttachment(screenshot: app.screenshot()); large.name = "60 Chinese characters largest text"; large.lifetime = .keepAlways; add(large)
        app.terminate(); app.launchArguments = []; app.launch()
        app.buttons["paw-0"].press(forDuration: 0.7)
        app.buttons["clear-label"].tap()
        let restore = app.textViews["label-input"].exists ? app.textViews["label-input"] : app.textFields["label-input"]
        restore.tap(); restore.typeText(original)
        app.buttons["save-label"].tap()
        XCTAssertEqual(app.buttons["paw-0"].label, original)
    }
    func testTwelvePawsAndAbout() {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.buttons["paw-0"].waitForExistence(timeout: 5))
        for id in 0..<12 {
            let paw = app.buttons["paw-\(id)"]
            XCTAssertTrue(paw.isHittable)
            XCTAssertGreaterThanOrEqual(paw.frame.width, 44)
            XCTAssertGreaterThanOrEqual(paw.frame.height, 44)
            XCTAssertTrue(app.frame.contains(paw.frame), "The entire paw must fit on screen")
        }
        XCTAssertTrue(app.staticTexts["playback-status"].isHittable, "The footer must fit on one screen at default type")
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = "Home actual simulator"; attachment.lifetime = .keepAlways; add(attachment)
        for id in [0,0,1,2,3,4,5,6,7,8,9,10,11] { app.buttons["paw-\(id)"].tap() }
        XCTAssertFalse(app.staticTexts["playback-status"].label.contains("未找到"))
        app.buttons["about"].tap()
        XCTAssertTrue(app.buttons["close-about"].waitForExistence(timeout: 3))
        app.buttons["close-about"].tap(); XCTAssertTrue(app.buttons["paw-11"].isHittable)
    }
    func testRealCatPlaybackStopSwitchAndBackground() {
        let app = XCUIApplication(); app.launch()
        let first = app.buttons["paw-6"], second = app.buttons["paw-7"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        first.tap(); XCTAssertEqual(first.value as? String, "正在播放")
        let playing = XCTAttachment(screenshot: app.screenshot()); playing.name = "Actual cat playback selected"; playing.lifetime = .keepAlways; add(playing)
        first.tap(); XCTAssertEqual(first.value as? String, "已停止")
        first.tap(); second.tap()
        XCTAssertEqual(first.value as? String, "已停止")
        XCTAssertEqual(second.value as? String, "正在播放")
        second.tap(); XCTAssertEqual(second.value as? String, "已停止")
        first.tap()
        XCUIApplication(bundleIdentifier: "com.apple.springboard").activate()
        let background = NSPredicate { _, _ in
            app.state == .runningBackground || app.state == .runningBackgroundSuspended
        }
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: background, object: nil)], timeout: 2), .completed, "The app must actually enter background before reactivation (state \(app.state.rawValue))")
        app.activate()
        XCTAssertEqual(first.value as? String, "已停止")
    }
    func testLargeTextAllPawsReachable() {
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(app.buttons["paw-0"].waitForExistence(timeout: 5))
        let first = XCTAttachment(screenshot: app.screenshot()); first.name = "Largest text initial screen"; first.lifetime = .keepAlways; add(first)
        for id in 0..<12 {
            let paw = app.buttons["paw-\(id)"]
            for _ in 0..<10 {
                if paw.isHittable && app.frame.contains(paw.frame) { break }
                let above = paw.exists && paw.frame.maxY > 0 && paw.frame.minY < app.frame.minY
                let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: above ? 0.4 : 0.65))
                let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: above ? 0.65 : 0.4))
                start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
            }
            XCTAssertTrue(paw.isHittable, "Paw \(id) must remain reachable at largest type")
            XCTAssertTrue(app.frame.contains(paw.frame), "Entire paw \(id) must be visible after scrolling")
            XCTAssertFalse(paw.label.isEmpty)
        }
        let attachment = XCTAttachment(screenshot: app.screenshot()); attachment.name = "Largest text actual simulator"; attachment.lifetime = .keepAlways; add(attachment)
    }
}
