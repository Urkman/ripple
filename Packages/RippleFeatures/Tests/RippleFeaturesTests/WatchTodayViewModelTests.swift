import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Watch Today model")
@MainActor
struct WatchTodayViewModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    @Test("refresh selects the default amount and container")
    func refreshSelectsDefault() async {
        let intakes = InMemoryIntakeRepository()
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )

        await model.refresh(now: now)

        let defaultContainer = model.quickContainers.first(where: \.isDefault)
        #expect(model.selectedAmountMl == 250)
        #expect(model.selectedContainerID == defaultContainer?.id)
        #expect(model.quickContainers.count == 3)
    }

    @Test("predefined selection does not write until Add")
    func predefinedSelectionWritesThroughLogIntake() async throws {
        let intakes = InMemoryIntakeRepository()
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )
        await model.refresh(now: now)
        let container = Container.seededDefaults()[1]

        model.select(container: container)
        #expect(try await intakes.intakes(from: .distantPast, to: .distantFuture).isEmpty)

        await model.addSelected()
        let rows = try await intakes.intakes(from: .distantPast, to: .distantFuture)
        #expect(rows.count == 1)
        #expect(rows.first?.amountMl == container.amountMl)
        #expect(rows.first?.containerId == container.id)
        #expect(rows.first?.source == .watch)
        #expect(model.successFeedback == 1)
        let expected = L10n.confirmation(
            amount: VolumeFormatter.current.string(
                milliliters: container.amountMl,
                unit: model.snapshot.unit
            )
        )
        #expect(model.confirmation == expected)
    }

    @Test("opening the amount sheet keeps the quick selection")
    func openingAmountSheetKeepsQuickSelection() async {
        let intakes = InMemoryIntakeRepository()
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )
        await model.refresh(now: now)
        let defaultContainer = model.quickContainers.first(where: \.isDefault)

        model.openAmountSheet()

        #expect(model.isAmountSheetPresented)
        #expect(model.selectedAmountMl == defaultContainer?.amountMl)
        #expect(model.selectedContainerID == defaultContainer?.id)
    }

    @Test("Crown adjustment writes without a container")
    func crownAdjustmentWritesWithoutContainer() async throws {
        let intakes = InMemoryIntakeRepository()
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )
        await model.refresh(now: now)

        model.openAmountSheet()
        #expect(model.isAmountSheetPresented)
        #expect(model.selectedContainerID != nil)
        model.updateCrown(300)
        #expect(model.selectedAmountMl == 300)
        #expect(model.selectedContainerID == nil)

        await model.addSelected()
        let rows = try await intakes.intakes(from: .distantPast, to: .distantFuture)
        #expect(rows.count == 1)
        #expect(rows.first?.amountMl == 300)
        #expect(rows.first?.containerId == nil)
        #expect(rows.first?.source == .watch)
    }

    @Test("logging failure preserves the selected amount and reports an error")
    func loggingFailurePreservesSelection() async {
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: ThrowingIntakeRepository()),
            now: now,
            calendar: calendar
        )
        let container = Container.seededDefaults()[2]
        model.select(container: container)
        model.openAmountSheet()
        model.updateCrown(310)
        let amountBeforeLog = model.selectedAmountMl
        let selectionBeforeLog = model.crownSelection

        await model.addSelected()

        #expect(model.selectedAmountMl == amountBeforeLog)
        #expect(model.crownSelection == selectionBeforeLog)
        #expect(model.errorMessage != nil)
    }

    @Test("top dismissal restores the pending quick selection")
    func amountSheetDismissalRestoresSelection() async {
        let intakes = InMemoryIntakeRepository()
        let model = WatchTodayViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )
        await model.refresh(now: now)
        let container = Container.seededDefaults()[2]
        model.select(container: container)

        model.openAmountSheet()
        model.updateCrown(310)
        model.dismissAmountSheet()

        #expect(!model.isAmountSheetPresented)
        #expect(model.selectedAmountMl == container.amountMl)
        #expect(model.selectedContainerID == container.id)
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 31, hour: 12))!
    }

    private func makeUseCases(intakes: any IntakeRepository) -> UseCases {
        UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: InMemorySettingsRepository(containers: Container.seededDefaults()),
            widgetReloading: NoOpWidgetReloading(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
    }
}

private enum WatchTodayTestError: Error {
    case failure
}

private struct ThrowingIntakeRepository: IntakeRepository {
    func save(_ intake: Intake) async throws {
        throw WatchTodayTestError.failure
    }

    func update(_ intake: Intake) async throws {
        throw WatchTodayTestError.failure
    }

    func intake(id: UUID) async throws -> Intake? {
        throw WatchTodayTestError.failure
    }

    func intakes(from start: Date, to end: Date) async throws -> [Intake] {
        throw WatchTodayTestError.failure
    }

    func firstUndeletedIntake() async throws -> Intake? {
        throw WatchTodayTestError.failure
    }

    func lastUndeletedIntake() async throws -> Intake? {
        throw WatchTodayTestError.failure
    }

    func monthSummaries(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar
    ) async throws -> [DaySummary] {
        throw WatchTodayTestError.failure
    }

    func statsSnapshot(
        from start: Date,
        to end: Date,
        goalMl: Int,
        calendar: Calendar,
        now: Date
    ) async throws -> StatsSnapshot {
        throw WatchTodayTestError.failure
    }
}
