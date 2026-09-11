import SwiftUI

@MainActor
public struct PomoPopoverView: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var sessionManager: SessionManager
    let onClose: () -> Void

    @State private var showHistory: Bool = false
    @AppStorage("appTheme") private var appTheme: String = "system"
    @Environment(\.colorScheme) var colorScheme

    public init(
        timerEngine: TimerEngine,
        sessionManager: SessionManager,
        onClose: @escaping () -> Void = {}
    ) {
        self.timerEngine = timerEngine
        self.sessionManager = sessionManager
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
        VStack(spacing: 14) {
            topBarView

            if showHistory {
                HistoryView(sessionManager: sessionManager)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                timerContentView
                    .transition(.opacity)
            }

            // Bottom session dots bar (Prominent hollow dots that fill up)
            SessionDotsView(
                completedCount: sessionManager.todayCompletedFocusCount,
                isCurrentActive: timerEngine.mode == .focus && timerEngine.isRunning,
                totalDurationString: sessionManager.formattedTodayDuration
            )
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
        .frame(width: 350)
        .liquidGlassWindow(cornerRadius: 14)
        .preferredColorScheme(preferredScheme)
    }

    // MARK: - Top Bar (Zero Text Clutter, Pixel-Aligned)

    private var topBarView: some View {
        HStack(alignment: .center) {
            // Top-left: History Toggle (Concentric Ring & Dot)
            ConcentricDotButton(isActive: showHistory) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    showHistory.toggle()
                }
            }

            Spacer()

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
                                .offset(x: 1.5) // Optical centering for triangle
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
}
