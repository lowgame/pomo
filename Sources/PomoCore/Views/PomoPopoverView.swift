import SwiftUI

@MainActor
public struct PomoPopoverView: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var sessionManager: SessionManager
    let onClose: () -> Void

    @State private var showHistory: Bool = false
    @State private var showSettingsMenu: Bool = false
    @State private var isSavedToCloudOverlayVisible: Bool = false
    @ObservedObject private var launchManager = LaunchAtLoginManager.shared
    @AppStorage("appTheme") private var appTheme: String = "system"
    @Environment(\.colorScheme) var colorScheme

    public init(
        timerEngine: TimerEngine,
        sessionManager: SessionManager,
        showHistory: Bool = false,
        onClose: @escaping () -> Void = {}
    ) {
        self.timerEngine = timerEngine
        self.sessionManager = sessionManager
        self._showHistory = State(initialValue: showHistory)
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
        ZStack {
            VStack(spacing: 12) {
                topBarView

                if showHistory {
                    HistoryView(sessionManager: sessionManager)
                        .transition(.opacity)
                } else {
                    timerContentView
                        .transition(.opacity)

                    // Bottom session dots bar (Active only in Timer Mode)
                    SessionDotsView(
                        completedCount: sessionManager.todayCompletedFocusCount,
                        isCurrentActive: timerEngine.mode == .focus && timerEngine.isRunning,
                        totalDurationString: sessionManager.formattedTodayDuration
                    )
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 8)
            .frame(width: 350)
            .liquidGlassWindow(cornerRadius: 14)

            // Full-Window "saved to icloud" Feedback Overlay
            if isSavedToCloudOverlayVisible {
                ZStack {
                    (colorScheme == .dark ? Color.black : Color.white).opacity(0.88)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 8) {
                        Image(systemName: "icloud.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                        Text("saved to icloud")
                            .font(.premium(14, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.6 : 0.2), radius: 20, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .preferredColorScheme(preferredScheme)
        .onReceive(NotificationCenter.default.publisher(for: .pomoTriggerSave)) { _ in
            triggerCloudSaveHUD()
        }
    }

    // MARK: - Top Bar (Zero Text Clutter, Pixel-Aligned)

    private var topBarView: some View {
        HStack(alignment: .center, spacing: 10) {
            // Top-left: History Toggle (Concentric Ring & Dot)
            ConcentricDotButton(isActive: showHistory) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    showHistory.toggle()
                }
            }

            Spacer()

            // Settings Menu Button (Launch at Login, Save to iCloud, Quit)
            Button(action: {
                showSettingsMenu.toggle()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.gray)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Settings & Launch at Login")
            .popover(isPresented: $showSettingsMenu, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        launchManager.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: launchManager.isEnabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11.5))
                                .foregroundColor(launchManager.isEnabled ? (colorScheme == .dark ? Color.white : Color.black) : Color.gray)
                            Text("Launch at Login")
                                .font(.premium(12, weight: .regular))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .background(Color.gray.opacity(0.2))

                    Button(action: {
                        showSettingsMenu = false
                        triggerCloudSaveHUD()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "icloud")
                                .font(.system(size: 11.5))
                                .foregroundColor(Color.gray)
                            Text("Save to iCloud")
                                .font(.premium(12, weight: .regular))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Spacer()
                            Text("⌘S")
                                .font(.premium(10.5, weight: .regular))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .background(Color.gray.opacity(0.2))

                    Button(action: {
                        showSettingsMenu = false
                        sessionManager.purgeTodaySessions()
                    }) {
                        Text("Reset Today's Sessions")
                            .font(.premium(12, weight: .regular))
                            .foregroundColor(Color.gray)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .background(Color.gray.opacity(0.2))

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "power")
                                .font(.system(size: 11.5))
                                .foregroundColor(Color.gray)
                            Text("Quit pomo")
                                .font(.premium(12, weight: .regular))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Spacer()
                            Text("⌘Q")
                                .font(.premium(10.5, weight: .regular))
                                .foregroundColor(Color.gray)
                        }
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .frame(width: 210)
                .liquidGlassWindow(cornerRadius: 10)
            }

            // Top-right: Theme Button (● Dark, ○ Light, – Auto)
            ThemeButton(theme: appTheme) {
                cycleTheme()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 28)
    }

    // MARK: - Timer Content View

    private var timerContentView: some View {
        VStack(spacing: 16) {
            // Mode Selector: Focus vs Rest (0 Text, Pure Geometric Icons)
            ModeSwitchView(currentMode: timerEngine.mode) { newMode in
                timerEngine.switchMode(to: newMode)
            }

            // Typographic Countdown
            Text(timerEngine.displayTime)
                .font(.premium(58, weight: .bold))
                .foregroundColor(Color.primary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .frame(height: 64, alignment: .center)

            // Playback Controls (Play/Pause & Reset - 0 Text, Pixel-Perfect Centering)
            HStack(spacing: 14) {
                // Reset Button (Only visible when timer has started/paused)
                if !timerEngine.isIdle {
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            timerEngine.reset()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.gray)
                            .frame(width: 40, height: 40, alignment: .center)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.12))
                            )
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Reset")
                    .transition(.scale.combined(with: .opacity))
                }

                // Play / Pause Button (Optically centered 48x48 circle)
                Button(action: {
                    timerEngine.togglePlayPause()
                }) {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color.primary.opacity(0.14))
                            .frame(width: 48, height: 48)

                        if timerEngine.isRunning {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.primary)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.primary)
                                .offset(x: 1.5)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .help(timerEngine.isRunning ? "Pause" : "Start")
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Theme Helpers

    public func cycleTheme() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch appTheme {
            case "dark":
                appTheme = "light"
            case "light":
                appTheme = "system"
            default:
                appTheme = "dark"
            }
        }
    }

    public func triggerCloudSaveHUD() {
        sessionManager.saveAllToCloud()
        withAnimation(.easeOut(duration: 0.15)) {
            isSavedToCloudOverlayVisible = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 850_000_000)
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.2)) {
                    isSavedToCloudOverlayVisible = false
                }
            }
        }
    }
}
