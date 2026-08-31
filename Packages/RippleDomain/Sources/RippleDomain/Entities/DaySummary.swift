import Foundation

public struct DaySummary: Sendable, Hashable, Equatable, Identifiable {
    public var date: Date
    public var consumedMl: Int
    public var goalMl: Int
    public var entryCount: Int
    public var hitGoal: Bool

    public var id: TimeInterval { date.timeIntervalSince1970 }

    public init(date: Date, consumedMl: Int, goalMl: Int, entryCount: Int, hitGoal: Bool) {
        self.date = date
        self.consumedMl = consumedMl
        self.goalMl = goalMl
        self.entryCount = entryCount
        self.hitGoal = hitGoal
    }

    public var progress: Double {
        min(1, Double(consumedMl) / Double(max(goalMl, 1)))
    }
}
