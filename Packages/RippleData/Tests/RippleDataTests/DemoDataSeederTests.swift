import Foundation
import Testing
import RippleDomain
@testable import RippleData

@Suite("Demo data seeder")
struct DemoDataSeederTests {
    @Test("seeding is idempotent and preserves user data")
    func seedIsIdempotent() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 11))
        )
        let intakes = InMemoryIntakeRepository()
        let settings = InMemorySettingsRepository()
        let useCases = UseCases.assemble(
            intakeRepository: intakes,
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing()
        )
        let userIntake = try await useCases.logIntake.run(
            amount: Milliliters(330),
            source: .app,
            date: now.addingTimeInterval(-3_600)
        )
        let seeder = DemoDataSeeder()

        try await seeder.seed(
            using: useCases,
            now: now,
            calendar: calendar,
            locale: Locale(identifier: "de_DE")
        )
        let first = try await intakes.intakes(from: .distantPast, to: .distantFuture)

        try await seeder.seed(
            using: useCases,
            now: now,
            calendar: calendar,
            locale: Locale(identifier: "de_DE")
        )
        let second = try await intakes.intakes(from: .distantPast, to: .distantFuture)

        #expect(second.count == first.count)
        #expect(Set(second.map(\.id)) == Set(first.map(\.id)))
        #expect(try await intakes.intake(id: userIntake.id) == userIntake)

        let seededProfile = try await settings.profile()
        let seededGoal = try await settings.goalSettings()
        #expect(seededProfile.onboardingCompleted)
        #expect(seededProfile.preferredUnit == .milliliters)
        #expect(seededGoal.mode == .manual)
        #expect(seededGoal.manualGoalMl == 2_000)

        let containers = try await settings.containers()
        #expect(containers.count == 3)
        #expect(containers.map(\.name) == ["Glas", "Tasse", "Flasche"])
    }
}
