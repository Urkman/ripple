import Foundation

public struct ObserveStats: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository
    private let calculateGoal: CalculateGoal

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        calculateGoal: CalculateGoal = CalculateGoal()
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
        self.calculateGoal = calculateGoal
    }

    public func run(
        range period: StatsPeriod,
        calendar: Calendar = .current,
        now: Date = Date()
    ) async throws -> StatsSnapshot {
        let (start, end) = period.bounds(calendar: calendar)
        let goalMl = try await fallbackGoalMl()
        return try await intakeRepository.statsSnapshot(
            from: start,
            to: end,
            goalMl: goalMl,
            calendar: calendar,
            now: now
        )
    }

    private func fallbackGoalMl() async throws -> Int {
        let profile = try await settingsRepository.profile()
        let settings = try await settingsRepository.goalSettings()
        return calculateGoal.historicalFallback(profile: profile, settings: settings).value
    }
}
