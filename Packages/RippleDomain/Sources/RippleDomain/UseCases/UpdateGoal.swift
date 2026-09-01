import Foundation

public struct UpdateGoal: Sendable {
    private let settingsRepository: any SettingsRepository
    private let workoutReading: any WorkoutReading
    private let widgetReloading: any WidgetReloading
    private let calculateGoal: CalculateGoal

    public init(
        settingsRepository: any SettingsRepository,
        workoutReading: any WorkoutReading,
        widgetReloading: any WidgetReloading,
        calculateGoal: CalculateGoal = CalculateGoal()
    ) {
        self.settingsRepository = settingsRepository
        self.workoutReading = workoutReading
        self.widgetReloading = widgetReloading
        self.calculateGoal = calculateGoal
    }

    public func run(mode: GoalMode, manualGoalMl: Int? = nil, now: Date = Date()) async throws {
        var settings = try await settingsRepository.goalSettings()
        settings.mode = mode
        settings.updatedAt = now

        if mode == .manual, let manualGoalMl {
            settings.manualGoalMl = max(manualGoalMl, 250)
        } else if mode == .calculated {
            let profile = try await settingsRepository.profile()
            let minutes = profile.healthReadWorkoutsEnabled ? await workoutReading.moderateMinutes(on: now) : 0
            settings.manualGoalMl = calculateGoal.run(profile: profile, workoutMinutes: minutes).value
        }

        try await settingsRepository.saveGoalSettings(settings)
        await widgetReloading.reload()
    }
}
