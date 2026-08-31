import Foundation

public struct UpdateProfile: Sendable {
    private let settingsRepository: any SettingsRepository
    private let reminders: any ReminderScheduling

    public init(settingsRepository: any SettingsRepository, reminders: any ReminderScheduling) {
        self.settingsRepository = settingsRepository
        self.reminders = reminders
    }

    public func run(_ profile: Profile) async throws {
        var updated = profile
        updated.updatedAt = Date()
        try await settingsRepository.saveProfile(updated)
        let rule = try await settingsRepository.reminderRule()
        await reminders.reschedule(rule: rule, lastSip: nil)
    }
}
