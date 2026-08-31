import Foundation
import Testing
@testable import RippleDomain

@Suite("History and stats")
struct HistoryStatsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    @Test("ObserveMonth aggregates one ring per day and caps hit at the daily goal")
    func observeMonth() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            goal: GoalSettings(mode: .manual, manualGoalMl: 2000),
            containers: Container.seededDefaults()
        )
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

        let day1 = date(year: 2026, month: 8, day: 1, hour: 9)
        let day2 = date(year: 2026, month: 8, day: 2, hour: 8)
        try await intakes.save(Intake(date: day1, amountMl: 500, source: .app))
        try await intakes.save(Intake(date: date(year: 2026, month: 8, day: 1, hour: 18), amountMl: 250, source: .widget))
        try await intakes.save(Intake(date: day2, amountMl: 2200, source: .app))
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 3, hour: 12), amountMl: 100, source: .app, isDeleted: true)
        )

        let days = try await useCases.observeMonth.run(year: 2026, month: 8, calendar: calendar)
        #expect(days.count == 31)
        #expect(days[0].consumedMl == 750)
        #expect(days[0].entryCount == 2)
        #expect(days[0].hitGoal == false)
        #expect(days[0].progress == 750.0 / 2000.0)
        #expect(days[1].consumedMl == 2200)
        #expect(days[1].hitGoal == true)
        #expect(days[1].progress == 1)
        #expect(days[2].consumedMl == 0)
        #expect(days[2].entryCount == 0)
    }

    @Test("ObserveHistory reports the first undeleted intake")
    func observeHistoryFirstIntakeDate() async throws {
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
        let deletedDate = date(year: 2026, month: 4, day: 1, hour: 8)
        let firstDate = date(year: 2026, month: 5, day: 10, hour: 9)
        try await intakes.save(
            Intake(date: deletedDate, amountMl: 250, source: .app, isDeleted: true)
        )
        try await intakes.save(Intake(date: firstDate, amountMl: 300, source: .app))
        try await intakes.save(
            Intake(date: date(year: 2026, month: 7, day: 1, hour: 10), amountMl: 400, source: .watch)
        )

        let result = try await useCases.observeHistory.firstIntakeDate()

        #expect(result == firstDate)
    }

    @Test("ObserveStats buckets daypart, includes empty days, and reports longest hit run")
    func observeStats() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(
            goal: GoalSettings(mode: .manual, manualGoalMl: 1000),
            containers: Container.seededDefaults()
        )
        let glass = try await settings.containers().first!
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

        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 24, hour: 7), amountMl: 1000, source: .app, containerId: glass.id)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 25, hour: 12), amountMl: 1000, source: .watch, containerId: glass.id)
        )
        try await intakes.save(
            Intake(date: date(year: 2026, month: 8, day: 26, hour: 20), amountMl: 400, source: .widget)
        )

        let now = date(year: 2026, month: 8, day: 28, hour: 12)
        let snapshot = try await useCases.observeStats.run(
            range: .week(now),
            calendar: calendar,
            now: now
        )

        #expect(snapshot.daily.count == 7)
        #expect(snapshot.hasData)
        #expect(snapshot.byDaypart[.morning] == 1000)
        #expect(snapshot.byDaypart[.midday] == 1000)
        #expect(snapshot.byDaypart[.evening] == 400)
        #expect(snapshot.bestDay?.consumedMl == 1000)
        #expect(snapshot.currentHitRun == 2)
        #expect(snapshot.emptyDays(now: now, calendar: calendar) == 2)
        #expect(snapshot.weakestDay(now: now, calendar: calendar)?.consumedMl == 400)
        #expect(snapshot.averageMlPerDay(now: now, calendar: calendar) == 480)
    }

    @Test("empty period does not crash and reports no data")
    func emptyPeriod() async throws {
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository(goal: GoalSettings(mode: .manual, manualGoalMl: 2000))
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
        let now = date(year: 2026, month: 1, day: 15, hour: 10)
        let snapshot = try await useCases.observeStats.run(range: .month(now), calendar: calendar, now: now)
        #expect(snapshot.daily.count == 31)
        #expect(snapshot.hasData == false)
        #expect(snapshot.totalMl == 0)
        #expect(snapshot.bestDay == nil)
        #expect(snapshot.currentHitRun == 0)
    }

    @Test("restore undoes a soft delete")
    func restore() async throws {
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
        let logged = try await useCases.logIntake.run(amount: Milliliters(250), source: .app)
        try await useCases.deleteIntake.run(id: logged.id)
        try await useCases.restoreIntake.run(id: logged.id)
        let stored = try await intakes.intake(id: logged.id)
        #expect(stored?.isDeleted == false)
        let snapshot = try await useCases.observeToday.snapshot(for: Date())
        #expect(snapshot.consumed.value == 250)
    }

    private func date(year: Int, month: Int, day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
