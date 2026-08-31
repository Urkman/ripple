import Foundation
import RippleDomain

public struct SwiftDataIntakeRepository: IntakeRepository {
    private let store: RippleStore

    public init(store: RippleStore) {
        self.store = store
    }

    public func save(_ intake: Intake) async throws {
        try await store.saveIntake(intake)
    }

    public func update(_ intake: Intake) async throws {
        try await store.updateIntake(intake)
    }

    public func intake(id: UUID) async throws -> Intake? {
        try await store.intake(id: id)
    }

    public func intakes(from start: Date, to end: Date) async throws -> [Intake] {
        try await store.intakes(from: start, to: end)
    }

    public func firstUndeletedIntake() async throws -> Intake? {
        try await store.firstUndeletedIntake()
    }

    public func lastUndeletedIntake() async throws -> Intake? {
        try await store.lastUndeletedIntake()
    }

    public func monthSummaries(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar
    ) async throws -> [DaySummary] {
        try await store.monthSummaries(from: start, to: end, goalMl: goalMl, calendar: calendar)
    }

    public func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) async throws -> StatsSnapshot {
        try await store.statsSnapshot(from: start, to: end, goalMl: goalMl, calendar: calendar, now: now)
    }
}

public struct SwiftDataSettingsRepository: SettingsRepository {
    private let store: RippleStore
    private let sync: SyncStatusStore

    public init(store: RippleStore, sync: SyncStatusStore) {
        self.store = store
        self.sync = sync
    }

    public func profile() async throws -> Profile {
        try await store.profile()
    }

    public func saveProfile(_ profile: Profile) async throws {
        try await store.saveProfile(profile)
    }

    public func goalSettings() async throws -> GoalSettings {
        try await store.goalSettings()
    }

    public func saveGoalSettings(_ settings: GoalSettings) async throws {
        try await store.saveGoalSettings(settings)
    }

    public func containers() async throws -> [Container] {
        try await store.containers()
    }

    public func saveContainer(_ container: Container) async throws {
        try await store.saveContainer(container)
    }

    public func deleteContainer(id: UUID) async throws {
        try await store.deleteContainer(id: id)
    }

    public func reminderRule() async throws -> ReminderRule {
        try await store.reminderRule()
    }

    public func saveReminderRule(_ rule: ReminderRule) async throws {
        try await store.saveReminderRule(rule)
    }

    public func syncStatus() async -> SyncStatus {
        await sync.current
    }

    public func seedDefaultsIfNeeded(locale: Locale) async throws {
        try await store.seedDefaultsIfNeeded(locale: locale)
    }
}
