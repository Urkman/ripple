import Foundation
import RippleDomain

public struct RippleContainer: Sendable {
    public let shared: SharedContainer
    public let useCases: UseCases
    public let store: RippleStore
    public let sync: SyncStatusStore

    public static func make(inMemory: Bool = false) -> RippleContainer {
        let shared = SharedContainer.make(inMemory: inMemory)
        return make(shared: shared)
    }

    /// Builds another repository/context facade over the already-open shared
    /// model container. Extensions use this for timeline reads so a reload
    /// gets a fresh ModelActor context without opening a second persistent
    /// container for the same App Group store.
    public static func make(shared: SharedContainer) -> RippleContainer {
        let store = RippleStore(modelContainer: shared.modelContainer)
        let sync = SyncStatusStore(shared.syncStatus)
        let intakeRepository = SwiftDataIntakeRepository(
            store: store,
            readModelContainer: shared.modelContainer
        )
        let settingsRepository = SwiftDataSettingsRepository(store: store, sync: sync)
        let notificationAuthorizer = NotificationAuthorizer()
        let useCases = UseCases.assemble(
            intakeRepository: intakeRepository,
            settingsRepository: settingsRepository,
            widgetReloading: WidgetReloader(),
            health: HealthProjector(),
            reminders: ReminderScheduler(notificationAuthorizing: notificationAuthorizer),
            workouts: WorkoutReader(),
            healthAuthorizing: HealthAuthorizer(),
            notificationAuthorizing: notificationAuthorizer
        )
        return RippleContainer(shared: shared, useCases: useCases, store: store, sync: sync)
    }
}

public enum RippleBootstrap {
    public static func start(inMemory: Bool = false) -> RippleContainer {
        ReminderScheduler.registerCategories()
        let container = RippleContainer.make(inMemory: inMemory)
        RippleRuntime.install(container.useCases)
        Task {
            try? await container.useCases.settingsRepository.seedDefaultsIfNeeded(locale: .current)
        }
        return container
    }
}
