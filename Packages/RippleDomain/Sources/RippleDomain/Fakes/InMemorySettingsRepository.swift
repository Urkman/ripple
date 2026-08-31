import Foundation

public actor InMemorySettingsRepository: SettingsRepository {
    private var storedProfile: Profile
    private var storedGoal: GoalSettings
    private var storedContainers: [UUID: Container]
    private var storedRule: ReminderRule
    private var storedSync: SyncStatus

    public init(
        profile: Profile = .fresh(),
        goal: GoalSettings = .default,
        containers: [Container] = [],
        rule: ReminderRule = .default,
        syncStatus: SyncStatus = .unavailable
    ) {
        self.storedProfile = profile
        self.storedGoal = goal
        self.storedContainers = Dictionary(uniqueKeysWithValues: containers.map { ($0.id, $0) })
        self.storedRule = rule
        self.storedSync = syncStatus
    }

    public func profile() async throws -> Profile { storedProfile }

    public func saveProfile(_ profile: Profile) async throws {
        storedProfile = profile
    }

    public func goalSettings() async throws -> GoalSettings { storedGoal }

    public func saveGoalSettings(_ settings: GoalSettings) async throws {
        storedGoal = settings
    }

    public func containers() async throws -> [Container] {
        storedContainers.values.sorted { $0.sort < $1.sort }
    }

    public func saveContainer(_ container: Container) async throws {
        storedContainers[container.id] = container
    }

    public func deleteContainer(id: UUID) async throws {
        storedContainers.removeValue(forKey: id)
    }

    public func reminderRule() async throws -> ReminderRule { storedRule }

    public func saveReminderRule(_ rule: ReminderRule) async throws {
        storedRule = rule
    }

    public func syncStatus() async -> SyncStatus { storedSync }

    public func setSyncStatus(_ status: SyncStatus) {
        storedSync = status
    }

    public func seedDefaultsIfNeeded(locale: Locale) async throws {
        if storedContainers.isEmpty {
            for container in Container.seededDefaults(locale: locale) {
                storedContainers[container.id] = container
            }
        }
    }
}
