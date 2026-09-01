import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Watch History and Stats models")
@MainActor
struct WatchHistoryAndStatsViewModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    @Test("history keeps seven elapsed days newest first")
    func historyKeepsSevenElapsedDaysNewestFirst() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            goal: GoalSettings(mode: .manual, manualGoalMl: 2_000),
            containers: Container.seededDefaults()
        )
        let useCases = makeUseCases(intakes: intakes, settings: settings)
        let now = date(year: 2026, month: 8, day: 31, hour: 12)

        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 25, hour: 9), amountMl: 250, source: .app)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 27, hour: 13), amountMl: 750, source: .watch)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 31, hour: 8), amountMl: 500, source: .widget)
        )

        let model = WatchHistoryViewModel(useCases: useCases, now: now, calendar: calendar)
        await model.refresh(now: now)

        #expect(model.days.count == 7)
        #expect(model.days.first?.date == calendar.startOfDay(for: now))
        #expect(model.days.last?.date == date(year: 2026, month: 8, day: 25))
        #expect(model.days[1].consumed == .zero)
        #expect(model.days[4].consumed.value == 750)
        #expect(model.days.allSatisfy { $0.date <= calendar.startOfDay(for: now) })
    }

    @Test("day detail filters deleted entries and orders the rest newest first")
    func dayDetailFiltersAndOrdersEntries() async throws {
        let intakes = InMemoryIntakeRepository()
        let containers = Container.seededDefaults()
        let bottle = containers[2]
        let settings = InMemorySettingsRepository(
            goal: GoalSettings(mode: .manual, manualGoalMl: 2_000),
            containers: containers
        )
        let useCases = makeUseCases(intakes: intakes, settings: settings)
        let day = date(year: 2026, month: 8, day: 28, hour: 12)
        let early = date(year: 2026, month: 8, day: 28, hour: 8)
        let midday = date(year: 2026, month: 8, day: 28, hour: 12)
        let late = date(year: 2026, month: 8, day: 28, hour: 19)

        try await intakes.save(Intake(date: midday, amountMl: 250, source: .app, containerId: bottle.id))
        try await intakes.save(Intake(date: late, amountMl: 500, source: .watch))
        try await intakes.save(Intake(date: early, amountMl: 150, source: .widget))
        try await intakes.save(
            Intake(
                date: date(year: 2026, month: 8, day: 28, hour: 23),
                amountMl: 900,
                source: .app,
                isDeleted: true
            )
        )

        let model = WatchDayDetailViewModel(useCases: useCases, day: day, calendar: calendar)
        await model.refresh()

        #expect(model.snapshot.date == calendar.startOfDay(for: day))
        #expect(model.snapshot.consumed.value == 900)
        #expect(model.entries.count == 3)
        #expect(model.entries.map(\.date) == [late, midday, early])
        #expect(model.containerName(for: model.entries[1]) == bottle.name)
        #expect(model.containerName(for: model.entries[0]) == nil)
    }

    @Test("stats use the current ISO week and expose raw chart days")
    func statsUseCurrentISOWeek() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            profile: Profile(preferredUnit: .fluidOunces),
            goal: GoalSettings(mode: .manual, manualGoalMl: 1_000),
            containers: Container.seededDefaults()
        )
        let useCases = makeUseCases(intakes: intakes, settings: settings)
        let now = date(year: 2026, month: 8, day: 28, hour: 12)

        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 24, hour: 8), amountMl: 1_000, source: .app)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 25, hour: 12), amountMl: 1_000, source: .watch)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 26, hour: 20), amountMl: 400, source: .widget)
        )

        let model = WatchStatsViewModel(useCases: useCases, now: now, calendar: calendar)
        await model.refresh(now: now)
        let bounds = StatsPeriod.week(now).bounds(calendar: calendar)

        #expect(model.snapshot.range.start == bounds.0)
        #expect(model.snapshot.range.end == bounds.1)
        #expect(model.unit == .fluidOunces)
        #expect(model.elapsedDayCount == 5)
        #expect(model.hitDayCount == 2)
        #expect(model.averageMl == 480)
        #expect(model.snapshot.totalMl == 2_400)
        #expect(model.chartPoints.count == 7)
        #expect(model.chartPoints.contains { $0.date == date(year: 2026, month: 8, day: 27) && $0.consumedMl == 0 })
    }

    @Test("empty stats keep seven source days but expose no chart points")
    func emptyStatsExposeNoChartPoints() async {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            goal: GoalSettings(mode: .manual, manualGoalMl: 2_000),
            containers: Container.seededDefaults()
        )
        let useCases = makeUseCases(intakes: intakes, settings: settings)
        let now = date(year: 2026, month: 8, day: 28, hour: 12)
        let model = WatchStatsViewModel(useCases: useCases, now: now, calendar: calendar)

        await model.refresh(now: now)

        #expect(model.snapshot.hasData == false)
        #expect(model.snapshot.daily.count == 7)
        #expect(model.chartPoints.isEmpty)
    }

    private func makeUseCases(
        intakes: any IntakeRepository,
        settings: any SettingsRepository
    ) -> UseCases {
        UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
    }

    private func date(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
