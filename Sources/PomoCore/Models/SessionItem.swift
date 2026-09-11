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
