import Foundation
import UserNotifications

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()

    /// Only attempt UserNotifications if running inside a true .app bundle and not inside XCTest
    private var isSupported: Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return false
        }
        guard let id = Bundle.main.bundleIdentifier, !id.isEmpty else { return false }
        return Bundle.main.bundleURL.pathExtension == "app"
    }

    private var center: UNUserNotificationCenter? {
        guard isSupported else { return nil }
        return UNUserNotificationCenter.current()
    }

    private override init() {
        super.init()
        if isSupported {
            UNUserNotificationCenter.current().delegate = self
        }
    }

    public func requestAuthorization() {
        guard let center = center else { return }
        center.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if let error = error {
                print("[pomo] Notification auth error: \(error)")
            }
        }
    }

    public func notifyCompletion(for mode: TimerMode) {
        guard let center = center else { return }

        let content = UNMutableNotificationContent()
        content.title = "pomo"
        switch mode {
        case .focus:
            content.body = "focus session complete. ●"
        case .rest:
            content.body = "rest period complete. ○"
        }
        content.sound = nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("[pomo] Failed to deliver notification: \(error)")
            }
        }
    }

    // Deliver even if app is frontmost
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }
}
