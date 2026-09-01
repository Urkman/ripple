import Foundation

public struct LogIntake: Sendable {
    private let intakeRepository: any IntakeRepository
    private let settingsRepository: any SettingsRepository
    private let widgetReloading: any WidgetReloading
    private let health: any HealthProjecting
    private let reminders: any ReminderScheduling

    public init(
        intakeRepository: any IntakeRepository,
        settingsRepository: any SettingsRepository,
        widgetReloading: any WidgetReloading,
        health: any HealthProjecting,
        reminders: any ReminderScheduling
    ) {
        self.intakeRepository = intakeRepository
        self.settingsRepository = settingsRepository
        self.widgetReloading = widgetReloading
        self.health = health
        self.reminders = reminders
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
        await project(after: intake, source: source)
        return intake
    }

    private func project(after intake: Intake, source: IntakeSource) async {
        let rule = (try? await settingsRepository.reminderRule()) ?? .default

        // WidgetKit reloads the interacted widget after the AppIntent returns.
        // Requesting another reload while that render session is paused can
        // leave the active small widget displaying its previous entry.
        if source != .widget {
            await widgetReloading.reload()
        }
        await health.project(intake: intake)
        await reminders.reschedule(rule: rule, lastSip: intake.date)
    }
}
