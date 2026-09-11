import SwiftUI

public struct HistoryView: View {
    @ObservedObject var sessionManager: SessionManager

    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    public var body: some View {
        VStack(spacing: 12) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(sessionManager.allDayRecords) { day in
                        dayRow(for: day)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 180)

            // Minimalist Bottom Summary
            if sessionManager.totalHistoryFocusCount > 0 {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 6, height: 6)
                        Text("\(sessionManager.totalHistoryFocusCount)")
                            .font(.premium(11, weight: .semibold))
                            .foregroundColor(Color.primary)
                    }

                    Text("·")
                        .foregroundColor(Color.gray.opacity(0.5))

                    Text(sessionManager.formattedTotalHistoryDuration)
                        .font(.premium(11, weight: .regular))
                        .foregroundColor(Color.gray)
                        .monospacedDigit()
                }
                .padding(.top, 4)
                .padding(.bottom, 6)
            }
        }
    }

    private func dayRow(for day: DayHistoryItem) -> some View {
        HStack(spacing: 12) {
            // Day Label (minimal text: "today", "yesterday", "10 sep")
            Text(day.displayDate)
                .font(.premium(12, weight: day.displayDate == "today" ? .semibold : .regular))
                .foregroundColor(day.displayDate == "today" ? Color.primary : Color.gray)
                .frame(width: 68, alignment: .leading)

            // Circles representing sessions on that day
            if day.completedCount > 0 {
                HStack(spacing: 5) {
                    ForEach(0..<day.completedCount, id: \.self) { _ in
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 8, height: 8)
                    }
                }
            } else {
                Circle()
                    .strokeBorder(Color.gray.opacity(0.35), lineWidth: 1.2)
                    .frame(width: 8, height: 8)
            }

            Spacer()

            // Total duration for that day
            if day.completedCount > 0 {
                Text(day.formattedDuration)
                    .font(.premium(11, weight: .regular))
                    .foregroundColor(Color.gray)
                    .monospacedDigit()
            }
        }
    }
}
