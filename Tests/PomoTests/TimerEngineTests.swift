import XCTest
@testable import PomoCore

@MainActor
final class TimerEngineTests: XCTestCase {
    var sessionManager: SessionManager!
    var timerEngine: TimerEngine!

    override func setUp() {
        super.setUp()
        sessionManager = SessionManager()
        timerEngine = TimerEngine(sessionManager: sessionManager)
    }

    override func tearDown() {
        timerEngine = nil
        sessionManager = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(timerEngine.mode, .focus)
        XCTAssertEqual(timerEngine.state, .idle)
        XCTAssertEqual(timerEngine.remainingSeconds, 25 * 60)
        XCTAssertEqual(timerEngine.displayTime, "25:00")
        XCTAssertEqual(timerEngine.menuBarTitle, "25m")
        XCTAssertEqual(timerEngine.progress, 0.0)
    }

    func testStartAndPause() {
        timerEngine.start()
        XCTAssertEqual(timerEngine.state, .running)
        XCTAssertTrue(timerEngine.isRunning)
        XCTAssertNotNil(timerEngine.targetEndDate)

        timerEngine.pause()
        XCTAssertEqual(timerEngine.state, .paused)
        XCTAssertTrue(timerEngine.isPaused)
        XCTAssertNil(timerEngine.targetEndDate)
    }

    func testTogglePlayPause() {
        timerEngine.togglePlayPause()
        XCTAssertTrue(timerEngine.isRunning)

        timerEngine.togglePlayPause()
        XCTAssertTrue(timerEngine.isPaused)

        timerEngine.togglePlayPause()
        XCTAssertTrue(timerEngine.isRunning)
    }

    func testReset() {
        timerEngine.start()
        timerEngine.reset()
        XCTAssertEqual(timerEngine.state, .idle)
        XCTAssertEqual(timerEngine.remainingSeconds, 25 * 60)
        XCTAssertEqual(timerEngine.displayTime, "25:00")
    }

    func testSwitchMode() {
        timerEngine.switchMode(to: .rest)
        XCTAssertEqual(timerEngine.mode, .rest)
        XCTAssertEqual(timerEngine.remainingSeconds, 5 * 60)
        XCTAssertEqual(timerEngine.displayTime, "05:00")
        XCTAssertEqual(timerEngine.menuBarTitle, "5m")

        timerEngine.switchMode(to: .focus)
        XCTAssertEqual(timerEngine.mode, .focus)
        XCTAssertEqual(timerEngine.remainingSeconds, 25 * 60)
        XCTAssertEqual(timerEngine.displayTime, "25:00")
    }
}
