import Foundation
import Synchronization

public enum RippleRuntime: Sendable {
    private static let slot = Mutex<UseCases?>(nil)

    public static func install(_ useCases: UseCases) {
        slot.withLock { $0 = useCases }
    }

    public static var current: UseCases {
        if let installed = slot.withLock({ $0 }) {
            return installed
        }
        return preview
    }

    public static let preview: UseCases = makePreview()

    private static func makePreview() -> UseCases {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            containers: Container.seededDefaults(),
            syncStatus: .unavailable
        )
        return UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            liveActivity: NoOpLiveActivityControlling(),
            health: PreviewHealth(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
    }
}

private struct PreviewHealth: HealthProjecting {
    func project(intake: Intake) async { _ = intake }
    func retract(intakeID: UUID) async { _ = intakeID }
}
