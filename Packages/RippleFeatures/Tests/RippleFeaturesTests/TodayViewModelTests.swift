import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Today refresh")
@MainActor
struct TodayViewModelTests {
    @Test("refresh reads an intake added by another surface")
    func refreshReadsNewIntake() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 31))!
        let intakes = InMemoryIntakeRepository()
        let model = TodayViewModel(useCases: makeUseCases(intakes: intakes))

        await model.refresh(now: now)
        #expect(model.snapshot.consumed.value == 0)

        try await intakes.save(Intake(date: now, amountMl: 250, source: .widget))
        await model.refresh(now: now)

        #expect(model.snapshot.consumed.value == 250)
    }

    private func makeUseCases(intakes: InMemoryIntakeRepository) -> UseCases {
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
