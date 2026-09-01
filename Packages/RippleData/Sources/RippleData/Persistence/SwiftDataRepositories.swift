import Foundation
import RippleDomain
import SwiftData

public struct SwiftDataIntakeRepository: IntakeRepository {
    private let store: RippleStore
    private let readModelContainer: ModelContainer?

    public init(
        store: RippleStore,
        readModelContainer: ModelContainer? = nil
    ) {
        self.store = store
        self.readModelContainer = readModelContainer
    }

    public func save(_ intake: Intake) async throws {
        try await store.saveIntake(intake)
    }

    public func update(_ intake: Intake) async throws {
        try await store.updateIntake(intake)
    }

    public func intake(id: UUID) async throws -> Intake? {
        try await readStore().intake(id: id)
    }

    public func intakes(from start: Date, to end: Date) async throws -> [Intake] {
        try await readStore().intakes(from: start, to: end)
    }

    public func firstUndeletedIntake() async throws -> Intake? {
        try await readStore().firstUndeletedIntake()
    }

    public func lastUndeletedIntake() async throws -> Intake? {
        try await readStore().lastUndeletedIntake()
    }

    public func monthSummaries(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar
    ) async throws -> [DaySummary] {
        try await readStore().monthSummaries(
            from: start,
            to: end,
            goalMl: goalMl,
            calendar: calendar
        )
    }

    public func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) async throws -> StatsSnapshot {
        try await readStore().statsSnapshot(
            from: start,
            to: end,
            goalMl: goalMl,
            calendar: calendar,
            now: now
        )
    }

    private func readStore() -> RippleStore {
        guard let readModelContainer else { return store }
        // Extension writes occur in another process. A fresh ModelActor context
        // prevents a foreground refresh from reusing pre-interaction objects.
        return RippleStore(modelContainer: readModelContainer)
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
