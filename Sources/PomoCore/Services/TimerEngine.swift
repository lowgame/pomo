import Foundation
import SwiftUI
import Combine

@MainActor
public final class TimerEngine: ObservableObject {
    @Published public private(set) var mode: TimerMode = .focus
    @Published public private(set) var state: TimerState = .idle
    @Published public private(set) var remainingSeconds: TimeInterval
    @Published public private(set) var targetEndDate: Date? = nil

    private var timerCancellable: AnyCancellable?
    private let sessionManager: SessionManager
    private let notificationManager: NotificationManager
    private let flashManager: FlashEffectManager

    public init(
        sessionManager: SessionManager,
        notificationManager: NotificationManager? = nil,
        flashManager: FlashEffectManager? = nil
    ) {
        self.sessionManager = sessionManager
        self.notificationManager = notificationManager ?? .shared
        self.flashManager = flashManager ?? .shared
        self.remainingSeconds = TimerMode.focus.defaultDuration
    }

    // MARK: - Computed Properties

    public var isRunning: Bool {
        state == .running
    }

    public var isPaused: Bool {
        state == .paused
    }

    public var isIdle: Bool {
        state == .idle
    }

    public var progress: Double {
        let total = mode.defaultDuration
        guard total > 0 else { return 0.0 }
        let elapsed = total - remainingSeconds
        return min(max(elapsed / total, 0.0), 1.0)
    }

    public var displayMinutes: Int {
        Int(ceil(remainingSeconds)) / 60
    }

    public var displaySeconds: Int {
        Int(ceil(remainingSeconds)) % 60
    }

    public var displayTime: String {
        String(format: "%02d:%02d", displayMinutes, displaySeconds)
    }

    /// Fixed-width string for menu bar (avoids layout shift)
    public var menuBarTitle: String {
        switch state {
        case .idle:
            return mode.shortLabel
        case .running, .paused, .completed:
            return displayTime
        }
    }

    // MARK: - Controls

    public func togglePlayPause() {
        if state == .running {
            pause()
        } else {
            start()
        }
    }

    public func start() {
        if state == .idle || state == .completed {
            remainingSeconds = mode.defaultDuration
        }

        let end = Date().addingTimeInterval(remainingSeconds)
        targetEndDate = end
        state = .running

        startTimerSubscription()
    }

    public func pause() {
        guard state == .running else { return }

        if let end = targetEndDate {
            remainingSeconds = max(0, end.timeIntervalSinceNow)
        }
        targetEndDate = nil
        state = .paused
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    public func reset() {
        timerCancellable?.cancel()
        timerCancellable = nil
        targetEndDate = nil
        remainingSeconds = mode.defaultDuration
        state = .idle
    }

    public func switchMode(to newMode: TimerMode) {
        guard mode != newMode else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        targetEndDate = nil
        mode = newMode
        remainingSeconds = newMode.defaultDuration
        state = .idle
    }

    // MARK: - Internal Engine

    private func startTimerSubscription() {
        timerCancellable?.cancel()

        // 0.25s cadence to ensure sub-second UI precision without drift
        timerCancellable = Timer.publish(every: 0.25, tolerance: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard state == .running, let target = targetEndDate else { return }

        let diff = target.timeIntervalSinceNow
        if diff <= 0 {
            remainingSeconds = 0
            finishSession()
        } else {
            remainingSeconds = diff
        }
    }

    private func finishSession() {
        timerCancellable?.cancel()
        timerCancellable = nil
        targetEndDate = nil
        state = .completed

        let completedMode = mode
        sessionManager.recordSession(mode: completedMode, duration: completedMode.defaultDuration)

        // Visual flash & silent notification
        flashManager.triggerFlash()
        notificationManager.notifyCompletion(for: completedMode)

        // Semi-automatic progression: automatically arm next phase, remain idle until triggered
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            switch completedMode {
            case .focus:
                self.mode = .rest
                self.remainingSeconds = TimerMode.rest.defaultDuration
                self.state = .idle
            case .rest:
                self.mode = .focus
                self.remainingSeconds = TimerMode.focus.defaultDuration
                self.state = .idle
            }
        }
    }
}
