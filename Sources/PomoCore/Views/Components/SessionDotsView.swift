import SwiftUI

public struct SessionDotsView: View {
    let completedCount: Int
    let isCurrentActive: Bool
    let totalDurationString: String

    public init(
        completedCount: Int,
        isCurrentActive: Bool,
        totalDurationString: String
    ) {
        self.completedCount = completedCount
        self.isCurrentActive = isCurrentActive
        self.totalDurationString = totalDurationString
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Left: Current Pomodoro Cycle Dots (Never overflows)
            cycleDotsView

            Spacer()

            // Right: Clean Total Count & Duration
            statsView
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .frame(width: 350)
    }

    // MARK: - Cycle Dots (Pomodoro 4-interval cycle discipline)

    private var cycleDotsView: some View {
        HStack(spacing: 7) {
            if completedCount <= 8 {
                // If 0-8 sessions: show up to 2 sets of 4 dots
                let totalSlots = max(4, ((completedCount / 4) + 1) * 4)
                ForEach(0..<min(8, totalSlots), id: \.self) { index in
                    if index == 4 {
                        // Subtle visual pause between set 1 and set 2
                        Spacer().frame(width: 4)
                    }
                    dotView(for: index, isFilled: index < completedCount, isActive: index == completedCount && isCurrentActive)
                }
            } else {
                // If > 8 sessions (e.g. 12, 16, 48):
                // Show the active 4-cycle state (never overflows)
                let activeCycleIndex = completedCount % 4
                let isCycleComplete = (activeCycleIndex == 0 && !isCurrentActive)

                ForEach(0..<4, id: \.self) { slot in
                    let isFilled = isCycleComplete || (slot < activeCycleIndex)
                    let isActive = !isCycleComplete && (slot == activeCycleIndex && isCurrentActive)
                    dotView(for: slot, isFilled: isFilled, isActive: isActive)
                }
            }
        }
    }

    private func dotView(for index: Int, isFilled: Bool, isActive: Bool) -> some View {
        let size: CGFloat = 11.0
        let strokeWidth: CGFloat = 1.4

        return ZStack(alignment: .center) {
            if isFilled {
                // Completed -> Solid filled circle
                Circle()
                    .fill(Color.primary)
                    .frame(width: size, height: size)
            } else if isActive {
                // Ticking session -> Outlined ring with active 3.5pt inner dot
                Circle()
                    .strokeBorder(Color.primary, lineWidth: strokeWidth)
                    .frame(width: size, height: size)

                Circle()
                    .fill(Color.primary)
                    .frame(width: 3.5, height: 3.5)
            } else {
                // Hollow upcoming slot
                Circle()
                    .strokeBorder(Color.gray.opacity(0.4), lineWidth: strokeWidth)
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Stats View (Count + Duration)

    private var statsView: some View {
        HStack(spacing: 6) {
            if completedCount > 0 {
                HStack(spacing: 3) {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 5, height: 5)

                    Text("\(completedCount)")
                        .font(.premium(12, weight: .semibold))
                        .foregroundColor(Color.primary)
                }

                Text("·")
                    .foregroundColor(Color.gray.opacity(0.4))
            }

            Text(totalDurationString)
                .font(.premium(12, weight: .regular))
                .foregroundColor(Color.gray)
                .monospacedDigit()
        }
    }
}
