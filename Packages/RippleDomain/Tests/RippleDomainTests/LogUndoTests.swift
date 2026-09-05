import Foundation
import Testing
@testable import RippleDomain

@Suite("Log and Undo")
struct LogUndoTests {
    @Test("log stores an intake and undo soft-deletes the last one")
    func logAndUndo() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(containers: Container.seededDefaults())
        let health = FakeHealthProjector()
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            health: health,
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )

        let first = try await useCases.logIntake.run(amount: Milliliters(250), source: .app)
        let second = try await useCases.logIntake.run(amount: Milliliters(500), source: .widget)
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        #expect(snapshot.consumed.value == 750)
        #expect(snapshot.entries.count == 2)

        let undone = try await useCases.undoLastIntake.run()
        #expect(undone?.id == second.id)
        let afterUndo = try await useCases.observeToday.snapshot(for: Date())
        #expect(afterUndo.consumed.value == 250)
        #expect(afterUndo.entries.count == 1)

        let stored = try await intakes.intake(id: second.id)
        #expect(stored?.isDeleted == true)
        #expect(first.isDeleted == false)
    }

    @Test("explicit intake IDs upsert without changing normal logging")
    func explicitIDUpserts() async throws {
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
        let id = UUID()
        _ = try await useCases.logIntake.run(
            amount: Milliliters(250),
            source: .app,
            id: id
        )
        _ = try await useCases.logIntake.run(
            amount: Milliliters(500),
            source: .widget,
            id: id
        )

        let stored = try await intakes.intake(id: id)
        #expect(stored?.amountMl == 500)
        #expect(stored?.source == .widget)
    }

    @Test("delete is a soft delete")
    func softDelete() async throws {
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
        let logged = try await useCases.logIntake.run(amount: Milliliters(200), source: .app)
        try await useCases.deleteIntake.run(id: logged.id)
        let stored = try await intakes.intake(id: logged.id)
        #expect(stored?.isDeleted == true)
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        #expect(snapshot.entries.isEmpty)
    }

    @Test("health projector skips duplicate UUIDs")
    func healthDedup() async throws {
        let health = FakeHealthProjector()
        let intake = Intake(date: Date(), amountMl: 250, source: .app)
        await health.project(intake: intake)
        await health.project(intake: intake)
        let ids = await health.writtenIDs
        #expect(ids == [intake.id])
    }
}
