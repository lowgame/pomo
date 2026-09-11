import Foundation
import SwiftUI
import AppKit
import Combine

@MainActor
public final class SessionManager: ObservableObject {
    @Published public private(set) var todaySessions: [SessionItem] = []
    @Published public private(set) var history: [DayRecord] = []
    @Published public private(set) var lastActiveDate: String = ""

    private let fileManager = FileManager.default
    private var dayChangeObserver: Any?
    private var wakeObserver: Any?

    public init() {
        self.lastActiveDate = currentDateKey()
        loadSessions()
        loadHistory()
        checkAndPerformDailyReset()
        setupObservers()
    }

    deinit {
        if let obs = dayChangeObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let obs = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(obs)
        }
    }

    // MARK: - Computed Properties

    public var todayCompletedFocusCount: Int {
        todaySessions.filter { $0.mode == .focus && $0.isCompleted }.count
    }

    public var todayCompletedFocusSeconds: TimeInterval {
        todaySessions.filter { $0.mode == .focus && $0.isCompleted }.reduce(0) { $0 + $1.duration }
    }

    public var formattedTodayDuration: String {
        let total = Int(todayCompletedFocusSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    // MARK: - Mutations

    public func recordSession(mode: TimerMode, duration: TimeInterval) {
        checkAndPerformDailyReset()

        let item = SessionItem(
            mode: mode,
            startedAt: Date().addingTimeInterval(-duration),
            completedAt: Date(),
            duration: duration,
            isCompleted: true
        )
        todaySessions.append(item)
        saveSessions()
    }

    public func purgeTodaySessions() {
        todaySessions.removeAll()
        saveSessions()
    }

    // MARK: - Daily Reset (00:00 Midnight)

    public func checkAndPerformDailyReset() {
        let currentKey = currentDateKey()
        if lastActiveDate != currentKey {
            // Archive previous day's completed focus sessions into history
            if todayCompletedFocusCount > 0 {
                let record = DayRecord(
                    dateString: lastActiveDate,
                    completedFocusCount: todayCompletedFocusCount,
                    totalFocusSeconds: todayCompletedFocusSeconds
                )
                if let idx = history.firstIndex(where: { $0.dateString == lastActiveDate }) {
                    history[idx] = record
                } else {
                    history.insert(record, at: 0)
                }
                saveHistory()
            }
            todaySessions.removeAll()
            lastActiveDate = currentKey
            saveSessions()
        }
    }

    private func setupObservers() {
        dayChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.checkAndPerformDailyReset()
            }
        }

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.checkAndPerformDailyReset()
            }
        }
    }

    private func currentDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    // MARK: - Storage & iCloud Mirroring

    private var localDataURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let pomoFolder = appSupport.appendingPathComponent("pomo", isDirectory: true)
        if !fileManager.fileExists(atPath: pomoFolder.path) {
            try? fileManager.createDirectory(at: pomoFolder, withIntermediateDirectories: true)
        }
        return pomoFolder.appendingPathComponent("sessions.json")
    }

    private var localHistoryURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let pomoFolder = appSupport.appendingPathComponent("pomo", isDirectory: true)
        if !fileManager.fileExists(atPath: pomoFolder.path) {
            try? fileManager.createDirectory(at: pomoFolder, withIntermediateDirectories: true)
        }
        return pomoFolder.appendingPathComponent("history.json")
    }

    private var iCloudFolderURL: URL? {
        fileManager.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents", isDirectory: true)
            .appendingPathComponent("pomo", isDirectory: true)
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(todaySessions)
            try data.write(to: localDataURL, options: .atomic)

            if let cloudFolder = iCloudFolderURL {
                try? fileManager.createDirectory(at: cloudFolder, withIntermediateDirectories: true)
                let cloudFile = cloudFolder.appendingPathComponent("sessions.json")
                try? data.write(to: cloudFile, options: .atomic)
            }
        } catch {
            print("[pomo] Failed to save sessions: \(error)")
        }
    }

    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: localHistoryURL, options: .atomic)

            if let cloudFolder = iCloudFolderURL {
                try? fileManager.createDirectory(at: cloudFolder, withIntermediateDirectories: true)
                let cloudFile = cloudFolder.appendingPathComponent("history.json")
                try? data.write(to: cloudFile, options: .atomic)
            }
        } catch {
            print("[pomo] Failed to save history: \(error)")
        }
    }

    private func loadSessions() {
        guard fileManager.fileExists(atPath: localDataURL.path) else { return }
        do {
            let data = try Data(contentsOf: localDataURL)
            todaySessions = try JSONDecoder().decode([SessionItem].self, from: data)
        } catch {
            print("[pomo] Failed to load sessions: \(error)")
            todaySessions = []
        }
    }

    private func loadHistory() {
        guard fileManager.fileExists(atPath: localHistoryURL.path) else { return }
        do {
            let data = try Data(contentsOf: localHistoryURL)
            history = try JSONDecoder().decode([DayRecord].self, from: data)
        } catch {
            print("[pomo] Failed to load history: \(error)")
            history = []
        }
    }
}
