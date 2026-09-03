import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Onboarding")
@MainActor
struct OnboardingViewModelTests {
    @Test("Health weight populates the profile and calculated goal")
    func healthWeightCalculatesGoal() async {
        let model = OnboardingViewModel(useCases: makeUseCases(bodyMassKg: 70))

        await model.requestHealthWeight()

        #expect(model.healthWeightState == .found)
        #expect(model.profile.bodyMassKg == 70)
        #expect(model.calculatedGoalMl == 2300)
    }

    @Test("Missing Health weight keeps the manual fallback available")
    func missingHealthWeightUsesFallback() async {
        let model = OnboardingViewModel(useCases: makeUseCases(bodyMassKg: nil))

        await model.requestHealthWeight()

        #expect(model.healthWeightState == .unavailable)
        #expect(model.profile.bodyMassKg == nil)
        #expect(model.calculatedGoalMl == 2000)
    }

    @Test("Denied notifications do not block onboarding")
    func deniedNotificationsDoNotBlockFinish() async throws {
        let settings = InMemorySettingsRepository()
        let model = OnboardingViewModel(
            useCases: makeUseCases(
                bodyMassKg: nil,
                notificationStatus: .denied,
                settings: settings
            )
        )

        await model.requestNotifications()
        await model.finish()
        let profile = try await settings.profile()
        let rule = try await settings.reminderRule()

        #expect(model.notificationStatus == .denied)
        #expect(profile.onboardingCompleted)
        #expect(!profile.remindersEnabled)
        #expect(!rule.enabled)
    }

    private func makeUseCases(
        bodyMassKg: Double?,
        notificationStatus: NotificationAuthorizationStatus = .notDetermined,
        settings: InMemorySettingsRepository = InMemorySettingsRepository()
    ) -> UseCases {
        UseCases.assemble(
            intakeRepository: InMemoryIntakeRepository(),
            settingsRepository: settings,
            widgetReloading: NoOpWidgetReloading(),
            health: FakeHealthProjector(),
            reminders: NoOpReminderScheduling(),
            workouts: NoOpWorkoutReading(),
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: bodyMassKg),
            notificationAuthorizing: NoOpNotificationAuthorizing(current: notificationStatus)
        )
    }
}
