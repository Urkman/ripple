import Foundation
import RippleDomain

public struct DemoDataSeeder: Sendable {
    public init() {}

    public func seed(
        using useCases: UseCases,
        now: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current
    ) async throws {
        try await useCases.settingsRepository.seedDefaultsIfNeeded(locale: locale)

        var profile = try await useCases.settingsRepository.profile()
        profile.onboardingCompleted = true
        profile.preferredUnit = .milliliters
        profile.updatedAt = now
        try await useCases.updateProfile.run(profile)

        try await useCases.updateGoal.run(
            mode: .manual,
            manualGoalMl: 2_000,
            now: now
        )

        let containers = try await useCases.settingsRepository.containers()
        let scenario = DemoDataScenario.make(
            now: now,
            calendar: calendar,
            containerIDs: containers.map(\.id)
        )

        for record in scenario.records {
            _ = try await useCases.logIntake.run(
                amount: Milliliters(record.amountMl),
                source: record.source,
                date: record.date,
                containerId: record.containerId,
                id: record.id
            )
        }
    }
}
