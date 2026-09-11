import SwiftUI

// MARK: - Concentric Dot Button (Toggles History Tab)

public struct ConcentricDotButton: View {
    let isActive: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered: Bool = false

    public init(isActive: Bool = false, action: @escaping () -> Void) {
        self.isActive = isActive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                // Outer Ring
                Circle()
                    .strokeBorder(
                        isActive || isHovered
                            ? (colorScheme == .dark ? Color.white : Color.black)
                            : Color.gray.opacity(0.55),
                        lineWidth: 1.4
                    )
                    .frame(width: 16, height: 16)

                // Center Dot
                Circle()
                    .fill(
                        isActive || isHovered
                            ? (colorScheme == .dark ? Color.white : Color.black)
                            : Color.gray.opacity(0.55)
                    )
                    .frame(width: 5, height: 5)
            }
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(isActive ? "Back to timer" : "History")
    }
}

// MARK: - Theme Button (● Dark, ○ Light, – Auto)

public struct ThemeButton: View {
    let theme: String
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered: Bool = false

    public init(theme: String, action: @escaping () -> Void) {
        self.theme = theme
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                switch theme {
                case "dark":
                    // ● (içi dolu) -> koyu tema
                    Circle()
                        .fill(isHovered ? Color.primary : Color.primary.opacity(0.85))
                        .frame(width: 11, height: 11)

                case "light":
                    // ○ (içi boş) -> açık tema
                    Circle()
                        .strokeBorder(isHovered ? Color.primary : Color.primary.opacity(0.85), lineWidth: 1.6)
                        .frame(width: 11, height: 11)

                default:
                    // – -> otomatik
                    Capsule()
                        .fill(isHovered ? Color.primary : Color.primary.opacity(0.85))
                        .frame(width: 11, height: 2.2)
                }
            }
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help("Theme: \(themeDescription)")
    }

    private var themeDescription: String {
        switch theme {
        case "dark": return "Dark (●)"
        case "light": return "Light (○)"
        default: return "System (–)"
        }
    }
}
