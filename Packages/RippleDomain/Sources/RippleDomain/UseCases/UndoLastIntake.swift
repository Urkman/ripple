import Foundation

public struct UndoLastIntake: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository
    private let widgetReloading: any WidgetReloading
    private let health: any HealthProjecting
    private let reminders: any ReminderScheduling
    private let observeToday: ObserveToday

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        widgetReloading: any WidgetReloading,
        health: any HealthProjecting,
        reminders: any ReminderScheduling,
        observeToday: ObserveToday
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
        self.widgetReloading = widgetReloading
        self.health = health
        self.reminders = reminders
        self.observeToday = observeToday
    }

    @discardableResult
    public func run() async throws -> Intake? {
        guard var intake = try await intakeRepository.lastUndeletedIntake() else {
            return nil
        }
        intake.isDeleted = true
        intake.updatedAt = Date()
        try await intakeRepository.update(intake)

        let snapshot = (try? await observeToday.snapshot(for: intake.date)) ?? .empty(date: intake.date)
        let rule = (try? await settingsRepository.reminderRule()) ?? .default
        let lastSip = snapshot.entries.last?.date

        await widgetReloading.reload()
        await health.retract(intakeID: intake.id)
        await reminders.reschedule(rule: rule, lastSip: lastSip)
        return intake
    }
}
