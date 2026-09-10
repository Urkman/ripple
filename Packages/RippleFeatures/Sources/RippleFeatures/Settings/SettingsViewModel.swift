import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class SettingsViewModel {
    public var profile: Profile
    public var goal: GoalSettings
    public var containers: [Container]
    public var reminder: ReminderRule
    public var syncStatus: SyncStatus
    public var health: HealthAuthorizationStatus
    public var exportPayload: ExportPayload?
    public var suggestedGoal: Int

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private var reorderTask: Task<Void, Never>?

    public init(useCases: UseCases) {
        self.useCases = useCases
        self.profile = .fresh()
        self.goal = .default
        self.containers = []
        self.reminder = .default
        self.syncStatus = .unavailable
        self.health = .init()
        self.suggestedGoal = 2000
        self.reorderTask = nil
    }

    public func refresh() async {
        profile = (try? await useCases.settingsRepository.profile()) ?? profile
        goal = (try? await useCases.settingsRepository.goalSettings()) ?? goal
        containers = (try? await useCases.settingsRepository.containers()) ?? containers
        reminder = (try? await useCases.settingsRepository.reminderRule()) ?? reminder
        syncStatus = await useCases.settingsRepository.syncStatus()
        health = await useCases.healthAuthorizing.status()
        let minutes = profile.healthReadWorkoutsEnabled ? 0 : 0
        suggestedGoal = useCases.calculateGoal.run(profile: profile, workoutMinutes: minutes).value
    }

    public func saveProfile() async {
        try? await useCases.updateProfile.run(profile)
        try? await useCases.settingsRepository.saveReminderRule(reminder)
        try? await useCases.rescheduleReminders.run()
        await refresh()
    }

    public func saveGoal() async {
        try? await useCases.updateGoal.run(mode: goal.mode, manualGoalMl: goal.manualGoalMl)
        await refresh()
    }

    public func saveContainer(_ container: Container) async {
        reorderTask?.cancel()
        try? await useCases.upsertContainer.run(container)
        await refresh()
    }

    public func reorderContainers(_ reordered: [Container]) {
        persistContainerOrder(reordered)
    }

    public func saveReminder(_ updatedReminder: ReminderRule) async {
        reminder = updatedReminder
        reminder.updatedAt = Date()
        profile.remindersEnabled = reminder.enabled
        try? await useCases.settingsRepository.saveReminderRule(reminder)
        try? await useCases.updateProfile.run(profile)
        try? await useCases.rescheduleReminders.run()
        await refresh()
    }

    public func deleteContainer(_ container: Container) async {
        reorderTask?.cancel()
        try? await useCases.deleteContainer.run(id: container.id)
        await refresh()
    }

    public func requestHealthWrite() async {
        let allowed = await useCases.healthAuthorizing.requestWaterWrite()
        profile.healthWriteEnabled = allowed
        await saveProfile()
    }

    public func requestWorkouts() async {
        let allowed = await useCases.healthAuthorizing.requestWorkoutRead()
        profile.healthReadWorkoutsEnabled = allowed
        await saveProfile()
    }

    public func export() async {
        exportPayload = try? await useCases.exportData.run()
    }

    private func persistContainerOrder(_ reordered: [Container]) {
        containers = reordered.enumerated().map { index, container in
            var normalized = container
            normalized.sort = index
            return normalized
        }

        let valuesToPersist = containers
        reorderTask?.cancel()
        reorderTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for container in valuesToPersist {
                guard !Task.isCancelled else { return }
                try? await self.useCases.upsertContainer.run(container)
            }

            guard !Task.isCancelled else { return }
            await self.refresh()
        }
    }
}
