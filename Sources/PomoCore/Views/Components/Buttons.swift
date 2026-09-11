import SwiftUI

// MARK: - Pixel-Perfect Concentric Dot Button (Toggles History Tab)

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
                // Outer Ring: 16x16 with 1.5pt border -> Inner clear diameter is 13pt
                Circle()
                    .strokeBorder(
                        isActive || isHovered
                            ? (colorScheme == .dark ? Color.white : Color.black)
                            : Color.gray.opacity(0.55),
                        lineWidth: 1.5
                    )
                    .frame(width: 16, height: 16)

                // Center Dot: 6x6 (exact integer center: (16 - 6) / 2 = 5.0pt)
                Circle()
                    .fill(
                        isActive || isHovered
                            ? (colorScheme == .dark ? Color.white : Color.black)
                            : Color.gray.opacity(0.55)
                    )
                    .frame(width: 6, height: 6)
            }
            .frame(width: 28, height: 28, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(isActive ? "Back to timer" : "History")
    }
}

// MARK: - Pixel-Perfect Theme Button (● Dark, ○ Light, – Auto)

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
                    // ● (içi dolu) -> 10x10 solid circle, perfectly centered
                    Circle()
                        .fill(isHovered ? Color.primary : Color.primary.opacity(0.9))
                        .frame(width: 10, height: 10)

                case "light":
                    // ○ (içi boş) -> 10x10 stroked circle, 1.5pt crisp border
                    Circle()
                        .strokeBorder(isHovered ? Color.primary : Color.primary.opacity(0.9), lineWidth: 1.5)
                        .frame(width: 10, height: 10)

                default:
                    // – -> 10x2 horizontal capsule, integer dimensions
                    Capsule()
                        .fill(isHovered ? Color.primary : Color.primary.opacity(0.9))
                        .frame(width: 10, height: 2)
                }
            }
            .frame(width: 28, height: 28, alignment: .center)
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
