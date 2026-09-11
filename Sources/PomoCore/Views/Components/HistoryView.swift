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
            .clipped()

            // Minimalist Bottom Summary (Total Focus & Sessions)
            if sessionManager.totalHistoryFocusCount > 0 {
                HStack(spacing: 6) {
                    Text("total")
                        .font(.premium(11, weight: .regular))
                        .foregroundColor(Color.gray)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 6, height: 6)

                        Text("× \(sessionManager.totalHistoryFocusCount)")
                            .font(.premium(11, weight: .semibold))
                            .foregroundColor(Color.primary)
                    }

                    Text("·")
                        .foregroundColor(Color.gray.opacity(0.4))

                    Text(sessionManager.formattedTotalHistoryDuration)
                        .font(.premium(11, weight: .regular))
                        .foregroundColor(Color.gray)
                        .monospacedDigit()
                }
                .padding(.top, 2)
                .padding(.bottom, 6)
            }
        }
        .frame(width: 350)
    }

    private func dayRow(for day: DayHistoryItem) -> some View {
        HStack(spacing: 10) {
            // Day Label (Left: 64pt fixed width)
            Text(day.displayDate)
                .font(.premium(12, weight: day.displayDate == "today" ? .semibold : .regular))
                .foregroundColor(day.displayDate == "today" ? Color.primary : Color.gray)
                .frame(width: 64, alignment: .leading)

            // Middle: Clean session representation (● for <= 4, ● × N for > 4)
            HStack(spacing: 5) {
                if day.completedCount == 0 {
                    // Empty day
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.35), lineWidth: 1.2)
                        .frame(width: 7, height: 7)
                } else if day.completedCount <= 4 {
                    // 1 to 4 sessions: show each dot (one full Pomodoro cycle)
                    ForEach(0..<day.completedCount, id: \.self) { _ in
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 7, height: 7)
                    }
                } else {
                    // > 4 sessions: Strictly ONE dot × count (e.g. ● × 16, ● × 48)
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 7, height: 7)

                    Text("× \(day.completedCount)")
                        .font(.premium(12, weight: .medium))
                        .foregroundColor(Color.primary)
                }
            }

            Spacer()

            // Right: Duration (Fixed width alignment)
            if day.completedCount > 0 {
                Text(day.formattedDuration)
                    .font(.premium(11, weight: .regular))
                    .foregroundColor(Color.gray)
                    .monospacedDigit()
                    .frame(width: 60, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
