import Foundation

public protocol IntakeRepository: Sendable {
    func save(_ intake: Intake) async throws
    func update(_ intake: Intake) async throws
    func intake(id: UUID) async throws -> Intake?
    func intakes(from start: Date, to end: Date) async throws -> [Intake]
    func firstUndeletedIntake() async throws -> Intake?
    func lastUndeletedIntake() async throws -> Intake?
    func monthSummaries(from start: Date, to end: Date, goalMl: Int, calendar: Calendar) async throws -> [DaySummary]
    func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) async throws -> StatsSnapshot
}
