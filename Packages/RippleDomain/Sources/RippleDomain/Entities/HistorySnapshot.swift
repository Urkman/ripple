import Foundation

public enum HistoryRange: Sendable, Hashable, Equatable {
    case day(Date)
    case week(Date)
    case month(Date)
}

public struct DayTotal: Sendable, Hashable, Equatable, Identifiable {
    public var date: Date
    public var consumed: Milliliters
    public var goal: Milliliters

    public var id: TimeInterval { date.timeIntervalSince1970 }

    public init(date: Date, consumed: Milliliters, goal: Milliliters) {
        self.date = date
        self.consumed = consumed
        self.goal = goal
    }
}

public struct HistorySnapshot: Sendable, Hashable, Equatable {
    public var range: HistoryRange
    public var days: [DayTotal]
    public var entries: [Intake]

    public init(range: HistoryRange, days: [DayTotal], entries: [Intake]) {
        self.range = range
        self.days = days
        self.entries = entries
    }
}
