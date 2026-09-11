import SwiftUI

public struct ModeSwitchView: View {
    let currentMode: TimerMode
    let onSelect: (TimerMode) -> Void

    @Environment(\.colorScheme) var colorScheme

    public init(currentMode: TimerMode, onSelect: @escaping (TimerMode) -> Void) {
        self.currentMode = currentMode
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 6) {
            focusButton
            restButton
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.12))
        )
    }

    // MARK: - Focus Button (Mathematically Concentric 20x20 with 6x6 Inner Dot)

    private var focusButton: some View {
        let isSelected = (currentMode == .focus)
        let strokeWidth: CGFloat = 1.5
        let outerSize: CGFloat = 20.0
        let innerSize: CGFloat = 6.0

        return Button(action: {
            onSelect(.focus)
        }) {
            ZStack(alignment: .center) {
                // Outer circle: 20x20
                Circle()
                    .strokeBorder(
                        isSelected ? Color.primary : Color.gray.opacity(0.6),
                        lineWidth: strokeWidth
                    )
                    .frame(width: outerSize, height: outerSize)

                // Inner dot: 6x6, exact integer offset ((20 - 6) / 2 = 7.0pt)
                Circle()
                    .fill(isSelected ? Color.primary : Color.gray.opacity(0.6))
                    .frame(width: innerSize, height: innerSize)
            }
            .frame(width: 48, height: 32, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.primary.opacity(0.14) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Focus (25m)")
    }

    // MARK: - Rest Button (Minimalist Cup with Pixel-Aligned Centering)

    private var restButton: some View {
        let isSelected = (currentMode == .rest)
        return Button(action: {
            onSelect(.rest)
        }) {
            Image(systemName: isSelected ? "cup.and.saucer.fill" : "cup.and.saucer")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isSelected ? Color.primary : Color.gray.opacity(0.6))
                .frame(width: 48, height: 32, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primary.opacity(0.14) : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Rest (5m)")
    }
}
