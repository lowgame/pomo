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
            // Prominent session dots on bottom-left
            dotsCluster

            Spacer()

            // Total session duration (minimal text)
            if completedCount > 0 {
                Text(totalDurationString)
                    .font(.premium(12, weight: .regular))
                    .foregroundColor(Color.gray)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }

    private var dotsCluster: some View {
        HStack(spacing: 7) {
            // Display minimum 4 slots (1 cycle) or dynamically expand in groups of 4
            let totalSlots = max(4, ((completedCount / 4) + 1) * 4)
            ForEach(0..<totalSlots, id: \.self) { index in
                if index < completedCount {
                    // Completed session -> içi dolu (solid)
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 10, height: 10)
                } else if index == completedCount && isCurrentActive {
                    // Currently active session -> içi boş çember içinde aktif mikro nokta
                    ZStack {
                        Circle()
                            .strokeBorder(Color.primary, lineWidth: 1.8)
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 3.5, height: 3.5)
                    }
                } else {
                    // Incomplete / upcoming session -> içi boş (hollow)
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.4), lineWidth: 1.4)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
}
