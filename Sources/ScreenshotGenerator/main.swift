import AppKit
import SwiftUI
import PomoCore

@main
struct ScreenshotGenerator {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let sessionManager = SessionManager()
        let timerEngine = TimerEngine(sessionManager: sessionManager)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: Date())!
        let dayBefore = cal.date(byAdding: .day, value: -2, to: Date())!
        let day3 = cal.date(byAdding: .day, value: -3, to: Date())!

        let mockHistory = [
            DayRecord(dateString: dateFormatter.string(from: yesterday), completedFocusCount: 16, totalFocusSeconds: 16 * 1500),
            DayRecord(dateString: dateFormatter.string(from: dayBefore), completedFocusCount: 8, totalFocusSeconds: 8 * 1500),
            DayRecord(dateString: dateFormatter.string(from: day3), completedFocusCount: 12, totalFocusSeconds: 12 * 1500)
        ]

        let mockToday = [
            SessionItem(mode: .focus, startedAt: Date().addingTimeInterval(-3600), completedAt: Date().addingTimeInterval(-2100), duration: 1500, isCompleted: true),
            SessionItem(mode: .focus, startedAt: Date().addingTimeInterval(-1800), completedAt: Date().addingTimeInterval(-300), duration: 1500, isCompleted: true)
        ]

        sessionManager.setForPreview(todaySessions: mockToday, history: mockHistory)

        final class PreviewPanel: NSPanel {
            override var canBecomeKey: Bool { true }
            override var canBecomeMain: Bool { true }
        }

        let panel = PreviewPanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 260),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true

        let retinaScreen = NSScreen.screens.first(where: { $0.backingScaleFactor >= 2.0 }) ?? NSScreen.main!
        let screenFrame = retinaScreen.frame
        let x = screenFrame.origin.x + (screenFrame.width - 350) / 2
        let y = screenFrame.origin.y + (screenFrame.height - 350) / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))

        func capture(to path: String) {
            let wid = CGWindowID(panel.windowNumber)
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            proc.arguments = ["-l\(wid)", path]
            try? proc.run()
            proc.waitUntilExit()
        }

        let cwd = FileManager.default.currentDirectoryPath
        let assetsDir = "\(cwd)/assets"
        try? FileManager.default.createDirectory(atPath: assetsDir, withIntermediateDirectories: true)

        // 1. Capture Focus Mode (Dark Theme, running timer, completed dots)
        UserDefaults.standard.set("dark", forKey: "appTheme")
        timerEngine.setForPreview(mode: .focus, state: .running, remainingSeconds: 21 * 60 + 42)
        let focusView = PomoPopoverView(timerEngine: timerEngine, sessionManager: sessionManager, showHistory: false)
        panel.contentView = NSHostingView(rootView: focusView)
        panel.orderFrontRegardless()
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
        capture(to: "\(assetsDir)/pomo_focus_dark.png")
        print("[+] Captured pomo_focus_dark.png")

        // 2. Capture History Mode (Dark Theme, multiplier notation)
        let historyView = PomoPopoverView(timerEngine: timerEngine, sessionManager: sessionManager, showHistory: true)
        panel.contentView = NSHostingView(rootView: historyView)
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
        capture(to: "\(assetsDir)/pomo_history_dark.png")
        print("[+] Captured pomo_history_dark.png")

        // 3. Capture Light Mode (Light Theme, Rest Mode)
        UserDefaults.standard.set("light", forKey: "appTheme")
        timerEngine.setForPreview(mode: .rest, state: .idle, remainingSeconds: 5 * 60)
        let lightView = PomoPopoverView(timerEngine: timerEngine, sessionManager: sessionManager, showHistory: false)
        panel.contentView = NSHostingView(rootView: lightView)
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
        capture(to: "\(assetsDir)/pomo_light.png")
        print("[+] Captured pomo_light.png")

        panel.close()
    }
}
