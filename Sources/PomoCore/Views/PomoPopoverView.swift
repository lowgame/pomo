import SwiftUI

@MainActor
public struct PomoPopoverView: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var sessionManager: SessionManager
    let isDetached: Bool
    let onToggleDetach: () -> Void
    let onClose: () -> Void

    @AppStorage("appTheme") private var appTheme: String = "system"
    @Environment(\.colorScheme) var colorScheme

    public init(
        timerEngine: TimerEngine,
        sessionManager: SessionManager,
        isDetached: Bool = false,
        onToggleDetach: @escaping () -> Void = {},
        onClose: @escaping () -> Void = {}
    ) {
        self.timerEngine = timerEngine
        self.sessionManager = sessionManager
        self.isDetached = isDetached
        self.onToggleDetach = onToggleDetach
        self.onClose = onClose
    }

    private var preferredScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    public var body: some View {
        VStack(spacing: 16) {
            topBarView

            centerTimerDisplay

            ModeSwitchView(currentMode: timerEngine.mode) { newMode in
                timerEngine.switchMode(to: newMode)
            }

            SessionDotsView(
                completedCount: sessionManager.todayCompletedFocusCount,
                isCurrentActive: timerEngine.mode == .focus && timerEngine.isRunning,
                totalDurationString: sessionManager.formattedTodayDuration,
                onPurge: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        sessionManager.purgeTodaySessions()
                    }
                }
            )
        }
        .padding(.top, 14)
        .padding(.bottom, 6)
        .frame(width: 350)
        .liquidGlassWindow(cornerRadius: 14)
        .preferredColorScheme(preferredScheme)
    }

    // MARK: - Top Bar

    private var topBarView: some View {
        HStack(spacing: 8) {
            // App Branding dot
            Circle()
                .fill(Color.primary)
                .frame(width: 8, height: 8)
                .padding(.leading, 16)

            Text("pomo")
                .font(.premium(12, weight: .semibold))
                .foregroundColor(Color.primary)

            Text(timerEngine.mode.title)
                .font(.premium(12, weight: .medium))
                .foregroundColor(Color.gray)

            Spacer()

            // Theme toggle (⌘D)
            Button(action: cycleTheme) {
                Text(themeIcon)
                    .font(.premium(11, weight: .regular))
                    .foregroundColor(Color.gray)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Toggle theme (⌘D)")

            // Detach / Dock toggle
            Button(action: onToggleDetach) {
                Text(isDetached ? "⇲" : "⎘")
                    .font(.premium(12, weight: .regular))
                    .foregroundColor(isDetached ? Color.primary : Color.gray)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(isDetached ? "Dock to menu bar" : "Detach as floating window")

            // Close (Esc)
            Button(action: onClose) {
                Text("×")
                    .font(.premium(14, weight: .regular))
                    .foregroundColor(Color.gray)
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Close (esc)")
            .padding(.trailing, 12)
        }
    }

    // MARK: - Center Timer Display

    private var centerTimerDisplay: some View {
        VStack(spacing: 12) {
            // Typographic Countdown
            Text(timerEngine.displayTime)
                .font(.premium(54, weight: .bold))
                .foregroundColor(Color.primary)
                .monospacedDigit()
                .contentTransition(.numericText())

            // Controls: Start/Pause & Reset
            HStack(spacing: 12) {
                // Primary Start / Pause Button
                Button(action: {
                    timerEngine.togglePlayPause()
                }) {
                    HStack(spacing: 6) {
                        Text(timerEngine.isRunning ? "pause" : (timerEngine.isPaused ? "resume" : "start"))
                            .font(.premium(12, weight: .semibold))
                        Text("⌘⌥P")
                            .font(.premium(9, weight: .light))
                            .foregroundColor(Color.gray)
                    }
                    .foregroundColor(Color.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)

                // Reset Button
                if !timerEngine.isIdle {
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            timerEngine.reset()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("reset")
                                .font(.premium(12, weight: .regular))
                            Text("⌘R")
                                .font(.premium(9, weight: .light))
                                .foregroundColor(Color.gray.opacity(0.8))
                        }
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Theme Helpers

    private var themeIcon: String {
        switch appTheme {
        case "light": return "☼"
        case "dark": return "☾"
        default: return "◐"
        }
    }

    public func cycleTheme() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch appTheme {
            case "system": appTheme = "dark"
            case "dark": appTheme = "light"
            default: appTheme = "system"
            }
        }
    }
}
