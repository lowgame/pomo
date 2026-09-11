import AppKit

@MainActor
public final class GlobalHotkeyManager {
    public static let shared = GlobalHotkeyManager()

    private var globalMonitor: Any?
    private var localMonitor: Any?

    private init() {}

    public func setup(
        onToggleTimer: @escaping () -> Void,
        onResetTimer: @escaping () -> Void,
        onSelectFocus: @escaping () -> Void,
        onSelectRest: @escaping () -> Void,
        onClosePanel: @escaping () -> Void
    ) {
        stop()

        // Global monitor: Active when other apps have focus
        // Requires Accessibility permissions for keystrokes in background; silently ignores if not granted
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // Cmd + Option + P (keyCode 35 is P)
            if flags == [.command, .option] && event.keyCode == 35 {
                Task { @MainActor in
                    onToggleTimer()
                }
            }
        }

        // Local monitor: Active when pomo's panel is focused
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            // Cmd + Option + P: Toggle play/pause
            if flags == [.command, .option] && event.keyCode == 35 {
                onToggleTimer()
                return nil
            }

            // Cmd + R: Reset
            if flags == .command && event.keyCode == 15 { // keyCode 15 is R
                onResetTimer()
                return nil
            }

            // Key "1": switch to focus (when no modifiers)
            if flags.isEmpty && event.keyCode == 18 { // keyCode 18 is 1
                onSelectFocus()
                return nil
            }

            // Key "2": switch to rest (when no modifiers)
            if flags.isEmpty && event.keyCode == 19 { // keyCode 19 is 2
                onSelectRest()
                return nil
            }

            // Escape key
            if flags.isEmpty && event.keyCode == 53 { // keyCode 53 is Esc
                onClosePanel()
                return nil
            }

            return event
        }
    }

    public func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
