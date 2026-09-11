import SwiftUI

public struct SessionDotsView: View {
    let completedCount: Int
    let isCurrentActive: Bool
    let totalDurationString: String
    let onPurge: () -> Void

    @State private var isArmedForPurge: Bool = false
    @State private var disarmWorkItem: DispatchWorkItem? = nil

    public init(
        completedCount: Int,
        isCurrentActive: Bool,
        totalDurationString: String,
        onPurge: @escaping () -> Void
    ) {
        self.completedCount = completedCount
        self.isCurrentActive = isCurrentActive
        self.totalDurationString = totalDurationString
        self.onPurge = onPurge
    }

    public var body: some View {
        HStack(spacing: 10) {
            // Dots Sequence (4-block groups)
            dotsCluster

            Spacer()

            // Total Time Stat
            if completedCount > 0 {
                Text(totalDurationString)
                    .font(.premium(11, weight: .medium))
                    .foregroundColor(Color.gray)
                    .monospacedDigit()
            }

            // Armored Purge (× -> ◎)
            purgeButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var dotsCluster: some View {
        HStack(spacing: 5) {
            // Render at least 4 dots (one full Pomodoro cycle) or up to completedCount + 1
            let totalSlots = max(4, ((completedCount / 4) + 1) * 4)
            ForEach(0..<totalSlots, id: \.self) { index in
                if index < completedCount {
                    // Completed focus session
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 6, height: 6)
                } else if index == completedCount && isCurrentActive {
                    // Currently active focus session
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: 1.2)
                        .frame(width: 6, height: 6)
                } else {
                    // Upcoming placeholder in the 4-set
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
        }
    }

    private var purgeButton: some View {
        Button(action: {
            if isArmedForPurge {
                // Second click: Purge permanently
                disarmWorkItem?.cancel()
                isArmedForPurge = false
                onPurge()
            } else {
                // First click: Arm button
                isArmedForPurge = true
                let work = DispatchWorkItem { [self] in
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.isArmedForPurge = false
                    }
                }
                disarmWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: work)
            }
        }) {
            Text(isArmedForPurge ? "◎" : "×")
                .font(.premium(12, weight: .medium))
                .foregroundColor(isArmedForPurge ? Color.primary : Color.gray.opacity(0.6))
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isArmedForPurge ? "Click again to purge today's sessions" : "Purge sessions")
    }
}
