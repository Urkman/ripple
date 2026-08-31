import Foundation

public struct ObserveMonth: Sendable {
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
        year: Int,
        month: Int,
        calendar: Calendar = .current
    ) async throws -> [DaySummary] {
        let (start, end) = DayWindow.month(year: year, month: month, calendar: calendar)
        let goalMl = try await fallbackGoalMl()
        return try await intakeRepository.monthSummaries(
            from: start,
            to: end,
            goalMl: goalMl,
            calendar: calendar
        )
    }

    private func fallbackGoalMl() async throws -> Int {
        let profile = try await settingsRepository.profile()
        let settings = try await settingsRepository.goalSettings()
        return calculateGoal.historicalFallback(profile: profile, settings: settings).value
    }
}
