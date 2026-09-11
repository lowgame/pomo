import SwiftUI

public struct ModeSwitchView: View {
    let currentMode: TimerMode
    let onSelect: (TimerMode) -> Void

    public init(currentMode: TimerMode, onSelect: @escaping (TimerMode) -> Void) {
        self.currentMode = currentMode
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 6) {
            modeButton(mode: .focus, label: "focus  25m", shortcutKey: "1")
            modeButton(mode: .rest, label: "rest  5m", shortcutKey: "2")
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.12))
        )
    }

    private func modeButton(mode: TimerMode, label: String, shortcutKey: String) -> some View {
        let isSelected = (currentMode == mode)
        return Button(action: {
            onSelect(mode)
        }) {
            HStack(spacing: 6) {
                Text(label)
                    .font(.premium(12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : Color.gray)

                Text(shortcutKey)
                    .font(.premium(9, weight: .light))
                    .foregroundColor(isSelected ? Color.gray : Color.gray.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? (Color.primary.opacity(0.14)) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
