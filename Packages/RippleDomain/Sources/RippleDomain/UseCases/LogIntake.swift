import Foundation

public struct LogIntake: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository
    private let widgetReloading: any WidgetReloading
    private let liveActivity: any LiveActivityControlling
    private let health: any HealthProjecting
    private let reminders: any ReminderScheduling
    private let observeToday: ObserveToday

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        widgetReloading: any WidgetReloading,
        liveActivity: any LiveActivityControlling,
        health: any HealthProjecting,
        reminders: any ReminderScheduling,
        observeToday: ObserveToday
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
        self.widgetReloading = widgetReloading
        self.liveActivity = liveActivity
        self.health = health
        self.reminders = reminders
        self.observeToday = observeToday
    }

    @discardableResult
    public func run(
        amount: Milliliters,
        source: IntakeSource,
        date: Date = Date(),
        containerId: UUID? = nil,
        note: String? = nil
    ) async throws -> Intake {
        let now = Date()
        let intake = Intake(
            date: date,
            amountMl: max(amount.value, 0),
            source: source,
            containerId: containerId,
            note: note,
            createdAt: now,
            updatedAt: now
        )
        try await intakeRepository.save(intake)
        await project(after: intake)
        return intake
    }

    private func project(after intake: Intake) async {
        let snapshot = (try? await observeToday.snapshot(for: intake.date)) ?? .empty(date: intake.date)
        let rule = (try? await settingsRepository.reminderRule()) ?? .default
        let profile = try? await settingsRepository.profile()

        await widgetReloading.reload()
        if profile?.liveActivityEnabled == true {
            await liveActivity.startOrUpdate(snapshot)
        }
        await health.project(intake: intake)
        await reminders.reschedule(rule: rule, lastSip: intake.date)
    }
}
