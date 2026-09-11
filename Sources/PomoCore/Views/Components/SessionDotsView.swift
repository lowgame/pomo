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
        HStack(spacing: 8) {
            let totalSlots = max(4, ((completedCount / 4) + 1) * 4)
            ForEach(0..<totalSlots, id: \.self) { index in
                sessionDot(for: index)
            }
        }
    }

    @ViewBuilder
    private func sessionDot(for index: Int) -> some View {
        let size: CGFloat = 12.0
        let strokeWidth: CGFloat = 1.5

        if index < completedCount {
            // Completed session -> İçi Dolu (Solid Circle)
            Circle()
                .fill(Color.primary)
                .frame(width: size, height: size)
        } else if index == completedCount && isCurrentActive {
            // Active ticking session -> Concentric Ring with 4pt inner dot (Pixel Perfect)
            ZStack(alignment: .center) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: strokeWidth)
                    .frame(width: size, height: size)

                Circle()
                    .fill(Color.primary)
                    .frame(width: 4.0, height: 4.0)
            }
            .frame(width: size, height: size)
        } else {
            // Incomplete session -> İçi Boş (Clean Hollow Circle)
            Circle()
                .strokeBorder(Color.gray.opacity(0.4), lineWidth: strokeWidth)
                .frame(width: size, height: size)
        }
    }
}
