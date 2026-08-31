import Foundation
import RippleDomain

public struct RippleContainer: Sendable {
    public let shared: SharedContainer
    public let useCases: UseCases
    public let store: RippleStore
    public let sync: SyncStatusStore

    public static func make(inMemory: Bool = false) -> RippleContainer {
        let shared = SharedContainer.make(inMemory: inMemory)
        let store = RippleStore(modelContainer: shared.modelContainer)
        let sync = SyncStatusStore(shared.syncStatus)
        let intakeRepository = SwiftDataIntakeRepository(store: store)
        let settingsRepository = SwiftDataSettingsRepository(store: store, sync: sync)
        let useCases = UseCases.assemble(
            intakeRepository: intakeRepository,
            settingsRepository: settingsRepository,
            widgetReloading: WidgetReloader(),
            liveActivity: LiveActivityController(),
            health: HealthProjector(),
            reminders: ReminderScheduler(),
            workouts: WorkoutReader(),
            healthAuthorizing: HealthAuthorizer()
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
