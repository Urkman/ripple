import Foundation

public struct RescheduleReminders: Sendable {
    private let settingsRepository: any SettingsRepository
    private let intakeRepository: any IntakeRepository
    private let reminders: any ReminderScheduling

    public init(
        settingsRepository: any SettingsRepository,
        intakeRepository: any IntakeRepository,
        reminders: any ReminderScheduling
    ) {
        self.settingsRepository = settingsRepository
        self.intakeRepository = intakeRepository
        self.reminders = reminders
    }

    public func run(now: Date = Date()) async throws {
        let rule = try await settingsRepository.reminderRule()
        let last = try await intakeRepository.lastUndeletedIntake()
        await reminders.reschedule(rule: rule, lastSip: last?.date)
        _ = now
    }
}
