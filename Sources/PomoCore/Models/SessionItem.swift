import Foundation

public struct SessionItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let mode: TimerMode
    public let startedAt: Date
    public var completedAt: Date?
    public let duration: TimeInterval
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        mode: TimerMode,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        duration: TimeInterval,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.mode = mode
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.duration = duration
        self.isCompleted = isCompleted
    }
}

public struct DayRecord: Codable, Equatable, Sendable {
    public let dateString: String // YYYY-MM-DD
    public var completedFocusCount: Int
    public var totalFocusSeconds: TimeInterval

    public init(dateString: String, completedFocusCount: Int, totalFocusSeconds: TimeInterval) {
        self.dateString = dateString
        self.completedFocusCount = completedFocusCount
        self.totalFocusSeconds = totalFocusSeconds
    }
}

public struct DayHistoryItem: Identifiable, Equatable, Sendable {
    public var id: String { dateString }
    public let dateString: String
    public let displayDate: String
    public let completedCount: Int
    public let totalSeconds: TimeInterval

    public init(dateString: String, displayDate: String, completedCount: Int, totalSeconds: TimeInterval) {
        self.dateString = dateString
        self.displayDate = displayDate
        self.completedCount = completedCount
        self.totalSeconds = totalSeconds
    }

    public var formattedDuration: String {
        let total = Int(totalSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
