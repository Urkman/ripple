import Foundation
import Testing
import RippleDomain
@testable import RippleIntentsCore

@Suite("App Intents", .serialized)
struct IntentTests {
    @Test("widget intent writes through the shared log path")
    func logIntent() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(containers: Container.seededDefaults())
        let reloader = RecordingWidgetReloading()
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: reloader,
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
        RippleRuntime.install(useCases)

        let intent = LogWidgetWaterIntent(milliliters: 250)
        _ = try await intent.perform()

        let stored = try await intakes.intakes(
            from: Date().addingTimeInterval(-60),
            to: Date().addingTimeInterval(60)
        )
        #expect(stored.contains { $0.amountMl == 250 && $0.source == .widget && !$0.isDeleted })
        #expect(await reloader.reloadCount == 0)

        let appIntent = LogWaterIntent(milliliters: 250, source: .app)
        _ = try await appIntent.perform()
        #expect(await reloader.reloadCount == 1)
    }

    @Test("GetTodayProgressIntent returns remaining")
    func progressIntent() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(containers: Container.seededDefaults())
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
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
