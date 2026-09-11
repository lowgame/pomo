import XCTest
@testable import PomoCore

@MainActor
final class SessionManagerTests: XCTestCase {
    var sessionManager: SessionManager!

    override func setUp() {
        super.setUp()
        sessionManager = SessionManager()
        sessionManager.purgeTodaySessions()
    }

    override func tearDown() {
        sessionManager.purgeTodaySessions()
        sessionManager = nil
        super.tearDown()
    }

    func testRecordAndPurgeSessions() {
        XCTAssertEqual(sessionManager.todayCompletedFocusCount, 0)
        XCTAssertEqual(sessionManager.formattedTodayDuration, "0m")

        sessionManager.recordSession(mode: .focus, duration: 25 * 60)
        XCTAssertEqual(sessionManager.todayCompletedFocusCount, 1)
        XCTAssertEqual(sessionManager.formattedTodayDuration, "25m")

        sessionManager.recordSession(mode: .rest, duration: 5 * 60)
        // Rest sessions shouldn't increase focus count
        XCTAssertEqual(sessionManager.todayCompletedFocusCount, 1)

        sessionManager.recordSession(mode: .focus, duration: 50 * 60)
        XCTAssertEqual(sessionManager.todayCompletedFocusCount, 2)
        XCTAssertEqual(sessionManager.formattedTodayDuration, "1h 15m")

        sessionManager.purgeTodaySessions()
        XCTAssertEqual(sessionManager.todayCompletedFocusCount, 0)
        XCTAssertEqual(sessionManager.todaySessions.count, 0)
    }
}
