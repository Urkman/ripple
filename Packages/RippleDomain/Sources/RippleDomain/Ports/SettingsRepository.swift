import Foundation

public protocol SettingsRepository: Sendable {
    func profile() async throws -> Profile
    func saveProfile(_ profile: Profile) async throws
    func goalSettings() async throws -> GoalSettings
    func saveGoalSettings(_ settings: GoalSettings) async throws
    func containers() async throws -> [Container]
    func saveContainer(_ container: Container) async throws
    func deleteContainer(id: UUID) async throws
    func reminderRule() async throws -> ReminderRule
    func saveReminderRule(_ rule: ReminderRule) async throws
    func syncStatus() async -> SyncStatus
    func seedDefaultsIfNeeded(locale: Locale) async throws
}
