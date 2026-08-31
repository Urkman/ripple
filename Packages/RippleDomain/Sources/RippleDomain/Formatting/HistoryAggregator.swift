import Foundation

public enum HistoryAggregator: Sendable {
    public static func daySummaries(
        intakes: [Intake],
        rangeStart: Date,
        rangeEnd: Date,
        goalMl: Int,
        calendar: Calendar
    ) -> [DaySummary] {
        let active = intakes.filter { !$0.isDeleted }
        var consumed: [Date: Int] = [:]
        var counts: [Date: Int] = [:]
        for intake in active {
            let day = calendar.startOfDay(for: intake.date)
            consumed[day, default: 0] += intake.amountMl
            counts[day, default: 0] += 1
        }

        var days: [DaySummary] = []
        var cursor = calendar.startOfDay(for: rangeStart)
        let end = calendar.startOfDay(for: rangeEnd)
        let resolvedGoal = max(goalMl, 1)
        while cursor < end {
            let amount = consumed[cursor] ?? 0
            let count = counts[cursor] ?? 0
            days.append(
                DaySummary(
                    date: cursor,
                    consumedMl: amount,
                    goalMl: resolvedGoal,
                    entryCount: count,
                    hitGoal: amount >= resolvedGoal
                )
            )
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return days
    }

    public static func stats(
        intakes: [Intake],
        rangeStart: Date,
        rangeEnd: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) -> StatsSnapshot {
        let daily = daySummaries(
            intakes: intakes,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            goalMl: goalMl,
            calendar: calendar
        )
        let active = intakes.filter { !$0.isDeleted }
        var byDaypart: [Daypart: Int] = [:]
        var byContainer: [UUID?: Int] = [:]
        for intake in active {
            let hour = calendar.component(.hour, from: intake.date)
            let part = Daypart.from(hour: hour)
            byDaypart[part, default: 0] += intake.amountMl
            byContainer[intake.containerId, default: 0] += intake.amountMl
        }

        let today = calendar.startOfDay(for: now)
        let bestDay = daily
            .filter { $0.consumedMl > 0 }
            .max { lhs, rhs in
                if lhs.consumedMl == rhs.consumedMl {
                    return lhs.date < rhs.date
                }
                return lhs.consumedMl < rhs.consumedMl
            }

        let elapsed = daily.filter { $0.date <= today }
        var run = 0
        var longest = 0
        for day in elapsed {
            if day.hitGoal {
                run += 1
                longest = max(longest, run)
            } else {
                run = 0
            }
        }

        let interval = DateInterval(start: rangeStart, duration: rangeEnd.timeIntervalSince(rangeStart))
        return StatsSnapshot(
            range: interval,
            daily: daily,
            byDaypart: byDaypart,
            byContainer: byContainer,
            bestDay: bestDay,
            currentHitRun: longest
        )
    }
}
