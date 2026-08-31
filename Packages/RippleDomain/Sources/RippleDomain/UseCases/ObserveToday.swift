import Foundation

public struct ObserveToday: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository
    private let workoutReading: any WorkoutReading
    private let calculateGoal: CalculateGoal

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        workoutReading: any WorkoutReading,
        calculateGoal: CalculateGoal = CalculateGoal()
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
        self.workoutReading = workoutReading
        self.calculateGoal = calculateGoal
    }

    public func snapshot(for date: Date, now: Date = Date(), calendar: Calendar = .current) async throws -> TodaySnapshot {
        let start = DayWindow.startOfDay(date, calendar: calendar)
        let end = DayWindow.endOfDay(date, calendar: calendar)
        let all = try await intakeRepository.intakes(from: start, to: end)
        let entries = all.filter { !$0.isDeleted }.sorted { $0.date < $1.date }
        let consumed = entries.reduce(0) { $0 + $1.amountMl }

        let profile = try await settingsRepository.profile()
        let goalSettings = try await settingsRepository.goalSettings()
        let containers = try await settingsRepository.containers().sorted { $0.sort < $1.sort }
        let workoutMinutes = profile.healthReadWorkoutsEnabled
            ? await workoutReading.moderateMinutes(on: date)
            : 0

        let goal: Int
        if goalSettings.mode == .calculated {
            goal = calculateGoal.run(profile: profile, workoutMinutes: workoutMinutes).value
        } else {
            goal = goalSettings.manualGoalMl
        }

        let remaining = max(goal - consumed, 0)
        let percent = goal > 0 ? Double(consumed) / Double(goal) : 0
        let defaultAdd = containers.first(where: \.isDefault)?.amountMl ?? 250
        let pacing = PacingCalculator.millilitersPerHour(
            remaining: Milliliters(remaining),
            now: now,
            wake: profile.wakeTime,
            sleep: profile.sleepTime,
            calendar: calendar
        )

        return TodaySnapshot(
            date: start,
            consumed: Milliliters(consumed),
            goal: Milliliters(goal),
            remaining: Milliliters(remaining),
            percent: percent,
            entries: entries,
            unit: profile.preferredUnit,
            defaultAddMl: defaultAdd,
            containers: containers,
            pacingMlPerHour: pacing
        )
    }
}
