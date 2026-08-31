import Foundation
import Testing
import RippleDomain
@testable import RippleIntentsCore

@Suite("App Intents", .serialized)
struct IntentTests {
    @Test("LogWaterIntent writes through fake repository")
    func logIntent() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(containers: Container.seededDefaults())
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            liveActivity: NoOpLiveActivityControlling(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
        RippleRuntime.install(useCases)

        let intent = LogWaterIntent(milliliters: 250)
        _ = try await intent.perform()

        let stored = try await intakes.intakes(
            from: Date().addingTimeInterval(-60),
            to: Date().addingTimeInterval(60)
        )
        #expect(stored.contains { $0.amountMl == 250 && !$0.isDeleted })
    }

    @Test("GetTodayProgressIntent returns remaining")
    func progressIntent() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(containers: Container.seededDefaults())
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            liveActivity: NoOpLiveActivityControlling(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
        RippleRuntime.install(useCases)
        _ = try await useCases.logIntake.run(amount: Milliliters(500), source: .intent)

        let intent = GetTodayProgressIntent()
        _ = try await intent.perform()
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        #expect(snapshot.consumed.value == 500)
        #expect(snapshot.remaining.value == 1500)
    }
}
