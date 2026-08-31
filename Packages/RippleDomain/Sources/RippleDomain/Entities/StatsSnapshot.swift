import Foundation

public struct StatsSnapshot: Sendable, Hashable, Equatable {
    public var range: DateInterval
    public var daily: [DaySummary]
    public var byDaypart: [Daypart: Int]
    public var byContainer: [UUID?: Int]
    public var bestDay: DaySummary?
    public var currentHitRun: Int

    public init(
        range: DateInterval,
        daily: [DaySummary],
        byDaypart: [Daypart: Int],
        byContainer: [UUID?: Int],
        bestDay: DaySummary?,
        currentHitRun: Int
    ) {
        self.range = range
        self.daily = daily
        self.byDaypart = byDaypart
        self.byContainer = byContainer
        self.bestDay = bestDay
        self.currentHitRun = currentHitRun
    }

    public static func empty(range: DateInterval) -> StatsSnapshot {
        StatsSnapshot(
            range: range,
            daily: [],
            byDaypart: [:],
            byContainer: [:],
            bestDay: nil,
            currentHitRun: 0
        )
    }

    public var hasData: Bool {
        daily.contains { $0.entryCount > 0 || $0.consumedMl > 0 }
    }

    public var totalMl: Int {
        daily.reduce(0) { $0 + $1.consumedMl }
    }

    public func daysElapsed(now: Date, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: now)
        return daily.filter { $0.date <= today }.count
    }

    public func hitDays(now: Date, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: now)
        return daily.filter { $0.date <= today && $0.hitGoal }.count
    }

    public func averageMlPerDay(now: Date, calendar: Calendar) -> Int {
        let elapsed = daysElapsed(now: now, calendar: calendar)
        guard elapsed > 0 else { return 0 }
        let today = calendar.startOfDay(for: now)
        let sum = daily.filter { $0.date <= today }.reduce(0) { $0 + $1.consumedMl }
        return Int((Double(sum) / Double(elapsed)).rounded())
    }

    public func emptyDays(now: Date, calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: now)
        return daily.filter { $0.date <= today && $0.entryCount == 0 }.count
    }

    public func weakestDay(now: Date, calendar: Calendar) -> DaySummary? {
        let today = calendar.startOfDay(for: now)
        return daily
            .filter { $0.date < today && $0.consumedMl > 0 }
            .min { lhs, rhs in
                if lhs.consumedMl == rhs.consumedMl {
                    return lhs.date < rhs.date
                }
                return lhs.consumedMl < rhs.consumedMl
            }
    }
}
