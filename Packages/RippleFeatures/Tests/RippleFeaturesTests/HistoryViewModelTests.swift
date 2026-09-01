import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("History calendar range")
@MainActor
struct HistoryViewModelTests {
    @Test("months run from the first undeleted intake through the current month")
    func availableMonthsAreBounded() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let intakes = InMemoryIntakeRepository()
        let useCases = makeUseCases(intakes: intakes)
        let deletedApril = date(year: 2026, month: 4, day: 1, calendar: calendar)
        let firstMay = date(year: 2026, month: 5, day: 12, calendar: calendar)
        let now = date(year: 2026, month: 8, day: 31, calendar: calendar)
        try await intakes.save(
            Intake(date: deletedApril, amountMl: 200, source: .app, isDeleted: true)
        )
        try await intakes.save(Intake(date: firstMay, amountMl: 300, source: .app))

        let model = HistoryViewModel(useCases: useCases, now: now, calendar: calendar)
        await model.refreshAvailableMonths()

        #expect(model.availableMonths.count == 4)
        #expect(calendar.component(.month, from: model.availableMonths.first!) == 5)
        #expect(calendar.component(.month, from: model.availableMonths.last!) == 8)
        #expect(!model.canNavigate(from: model.availableMonths.first!, by: -1))
        #expect(!model.canNavigate(from: model.availableMonths.last!, by: 1))
    }

    @Test("an empty history exposes only the current month")
    func emptyHistoryUsesCurrentMonth() async {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let intakes = InMemoryIntakeRepository()
        let now = date(year: 2026, month: 8, day: 31, calendar: calendar)
        let model = HistoryViewModel(
            useCases: makeUseCases(intakes: intakes),
            now: now,
            calendar: calendar
        )

        await model.refreshAvailableMonths()

        #expect(model.availableMonths == [model.visibleMonth])
        #expect(!model.canNavigate(from: model.visibleMonth, by: -1))
        #expect(!model.canNavigate(from: model.visibleMonth, by: 1))
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

    private func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
