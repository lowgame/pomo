import Foundation

public enum TimerMode: String, Codable, CaseIterable, Sendable {
    case focus
    case rest

    public var defaultDuration: TimeInterval {
        switch self {
        case .focus:
            return 25 * 60 // 25 minutes
        case .rest:
            return 5 * 60  // 5 minutes
        }
    }

    public var title: String {
        switch self {
        case .focus:
            return "focus"
        case .rest:
            return "rest"
        }
    }

    public var shortLabel: String {
        switch self {
        case .focus:
            return "25m"
        case .rest:
            return "5m"
        }
    }
}
