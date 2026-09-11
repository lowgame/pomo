import AppKit
import PomoCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent app from showing in Dock (menu bar accessory mode)
        NSApp.setActivationPolicy(.accessory)

        // Initialize status bar item, floating panel and hotkeys
        PomoPanelController.shared.setup()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
