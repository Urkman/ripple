import Foundation

public actor InMemoryIntakeRepository: IntakeRepository {
    private var items: [UUID: Intake] = [:]

    public init() {}

    public func save(_ intake: Intake) async throws {
        items[intake.id] = intake
    }

    public func update(_ intake: Intake) async throws {
        items[intake.id] = intake
    }

    public func intake(id: UUID) async throws -> Intake? {
        items[id]
    }

    public func intakes(from start: Date, to end: Date) async throws -> [Intake] {
        items.values
            .filter { $0.date >= start && $0.date < end }
            .sorted { $0.date < $1.date }
    }

    public func firstUndeletedIntake() async throws -> Intake? {
        items.values
            .filter { !$0.isDeleted }
            .sorted { $0.date < $1.date }
            .first
    }

    public func lastUndeletedIntake() async throws -> Intake? {
        items.values
            .filter { !$0.isDeleted }
            .sorted { $0.date > $1.date }
            .first
    }

    public func monthSummaries(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar
    ) async throws -> [DaySummary] {
        let intakes = try await intakes(from: start, to: end)
        return HistoryAggregator.daySummaries(
            intakes: intakes,
            rangeStart: start,
            rangeEnd: end,
            goalMl: goalMl,
            calendar: calendar
        )
    }

    public func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) async throws -> StatsSnapshot {
        let intakes = try await intakes(from: start, to: end)
        return HistoryAggregator.stats(
            intakes: intakes,
            rangeStart: start,
            rangeEnd: end,
            goalMl: goalMl,
            calendar: calendar,
            now: now
        )
    }
}
