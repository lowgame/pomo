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
        HStack(spacing: 8) {
            focusButton
            restButton
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.12))
        )
    }

    // Focus Button (Concentric Focus Ring / Target - 0 Text)
    private var focusButton: some View {
        let isSelected = (currentMode == .focus)
        return Button(action: {
            onSelect(.focus)
        }) {
            ZStack {
                // Outer focus ring
                Circle()
                    .strokeBorder(
                        isSelected ? Color.primary : Color.gray.opacity(0.6),
                        lineWidth: isSelected ? 1.8 : 1.4
                    )
                    .frame(width: 18, height: 18)

                // Inner focus dot
                Circle()
                    .fill(isSelected ? Color.primary : Color.gray.opacity(0.6))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 46, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.primary.opacity(0.14) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Focus (25m)")
    }

    // Rest Button (Minimalist Cup / Pause - 0 Text)
    private var restButton: some View {
        let isSelected = (currentMode == .rest)
        return Button(action: {
            onSelect(.rest)
        }) {
            Image(systemName: isSelected ? "cup.and.saucer.fill" : "cup.and.saucer")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isSelected ? Color.primary : Color.gray.opacity(0.6))
                .frame(width: 46, height: 32)
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
