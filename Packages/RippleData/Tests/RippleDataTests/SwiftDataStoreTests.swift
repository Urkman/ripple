import Foundation
import SwiftData
import Testing
import RippleDomain
@testable import RippleData

@Suite("SwiftData store")
struct SwiftDataStoreTests {
    @Test("in-memory CRUD for intakes")
    func crud() async throws {
        let shared = SharedContainer.makeInMemory()
        let store = RippleStore(modelContainer: shared.modelContainer)
        let intake = Intake(date: Date(), amountMl: 250, source: .app)
        try await store.saveIntake(intake)
        let fetched = try await store.intake(id: intake.id)
        #expect(fetched?.amountMl == 250)

        var updated = intake
        updated.amountMl = 400
        updated.isDeleted = true
        try await store.updateIntake(updated)
        let after = try await store.intake(id: intake.id)
        #expect(after?.amountMl == 400)
        #expect(after?.isDeleted == true)
        let last = try await store.lastUndeletedIntake()
        #expect(last == nil)
    }

    @Test("first undeleted intake ignores soft-deleted records")
    func firstUndeletedIntake() async throws {
        let shared = SharedContainer.makeInMemory()
        let store = RippleStore(modelContainer: shared.modelContainer)
        let deleted = Intake(
            date: Date(timeIntervalSince1970: 100),
            amountMl: 200,
            source: .app,
            isDeleted: true
        )
        let first = Intake(date: Date(timeIntervalSince1970: 200), amountMl: 300, source: .app)
        let last = Intake(date: Date(timeIntervalSince1970: 300), amountMl: 400, source: .widget)
        try await store.saveIntake(last)
        try await store.saveIntake(deleted)
        try await store.saveIntake(first)

        let result = try await store.firstUndeletedIntake()

        #expect(result?.id == first.id)
    }

    @Test("month summaries aggregate on the model actor")
    func monthSummaries() async throws {
        let shared = SharedContainer.makeInMemory()
        let store = RippleStore(modelContainer: shared.modelContainer)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1))!
        let morning = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1, hour: 8))!
        let evening = calendar.date(from: DateComponents(year: 2026, month: 8, day: 1, hour: 19))!
        try await store.saveIntake(Intake(date: morning, amountMl: 300, source: .app))
        try await store.saveIntake(Intake(date: evening, amountMl: 200, source: .widget))
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        let days = try await store.monthSummaries(from: start, to: end, goalMl: 2000, calendar: calendar)
        #expect(days.count == 31)
        #expect(days[0].consumedMl == 500)
        #expect(days[0].entryCount == 2)
        #expect(days[0].hitGoal == false)
    }

    @Test("seed defaults creates three containers")
    func seed() async throws {
        let shared = SharedContainer.makeInMemory()
        let store = RippleStore(modelContainer: shared.modelContainer)
        try await store.seedDefaultsIfNeeded(locale: Locale(identifier: "en_US"))
        let containers = try await store.containers()
        #expect(containers.count == 3)
        #expect(containers.contains { $0.isDefault })
        try await store.seedDefaultsIfNeeded(locale: Locale(identifier: "en_US"))
        let again = try await store.containers()
        #expect(again.count == 3)
    }

    @Test("goal last-writer-wins uses updatedAt")
    func goalConflict() async throws {
        let shared = SharedContainer.makeInMemory()
        let store = RippleStore(modelContainer: shared.modelContainer)
        let older = GoalSettings(mode: .manual, manualGoalMl: 1800, updatedAt: Date(timeIntervalSince1970: 1))
        let newer = GoalSettings(mode: .manual, manualGoalMl: 2200, updatedAt: Date(timeIntervalSince1970: 10))
        try await store.saveGoalSettings(newer)
        try await store.saveGoalSettings(older)
        let stored = try await store.goalSettings()
        #expect(stored.manualGoalMl == 2200)
    }
}

@Suite("Reminder window")
struct ReminderWindowTests {
    @Test("next fire stays inside wake-sleep window")
    func window() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 21, minute: 30))!
        let lastSip = calendar.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 21, minute: 0))!
        let rule = ReminderRule(
            enabled: true,
            start: ClockTime(hour: 7, minute: 0),
            end: ClockTime(hour: 22, minute: 0),
            afterLastSipMinutes: 120
        )
        let fire = ReminderScheduler.nextFireDate(
            rule: rule,
            lastSip: lastSip,
            now: now,
            calendar: calendar
        )
        #expect(fire != nil)
        let hour = calendar.component(.hour, from: fire!)
        #expect(hour == 7)
    }
}
