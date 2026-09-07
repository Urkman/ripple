import Foundation
import Testing
@testable import RippleDomain

@Suite("Authorization use cases")
struct AuthorizationUseCaseTests {
    @Test("Health onboarding requests weight and water access together")
    func healthOnboardingReturnsCombinedAccess() async {
        let health = RecordingHealthAuthorizer(
            access: HealthOnboardingAccess(
                bodyMassKg: 70,
                waterWriteAuthorized: true
            )
        )
        let sut = RequestHealthOnboardingAccess(healthAuthorizing: health)

        #expect(
            await sut.run() == HealthOnboardingAccess(
                bodyMassKg: 70,
                waterWriteAuthorized: true
            )
        )
        #expect(await health.onboardingRequestCount == 1)
        #expect(await health.bodyMassReadRequestCount == 0)
        #expect(await health.waterWriteRequestCount == 0)
    }

    @Test("Health read returns a valid body mass")
    func healthReadReturnsBodyMass() async {
        let health = NoOpHealthAuthorizing(bodyMassKg: 70)
        let sut = RequestHealthReadAccess(healthAuthorizing: health)

        #expect(await sut.run() == 70)
    }

    @Test("Health read rejects missing and invalid body mass")
    func healthReadRejectsInvalidValues() async {
        let missing = RequestHealthReadAccess(
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: nil)
        )
        let invalid = RequestHealthReadAccess(
            healthAuthorizing: NoOpHealthAuthorizing(bodyMassKg: .infinity)
        )

        #expect(await missing.run() == nil)
        #expect(await invalid.run() == nil)
    }

    @Test("Notification status reads without prompting")
    func notificationStatusDoesNotPrompt() async {
        let sut = RequestNotificationAuthorization(
            authorizing: NoOpNotificationAuthorizing(current: .denied)
        )

        #expect(await sut.status() == .denied)
    }
}

private actor RecordingHealthAuthorizer: HealthAuthorizing {
    let access: HealthOnboardingAccess
    private(set) var onboardingRequestCount = 0
    private(set) var bodyMassReadRequestCount = 0
    private(set) var waterWriteRequestCount = 0

    init(access: HealthOnboardingAccess) {
        self.access = access
    }

    func status() async -> HealthAuthorizationStatus { .init() }

    func requestOnboardingAccess() async -> HealthOnboardingAccess {
        onboardingRequestCount += 1
        return access
    }

    func requestBodyMassRead() async -> Bool {
        bodyMassReadRequestCount += 1
        return false
    }

    func latestBodyMassKg() async -> Double? { nil }

    func requestWaterWrite() async -> Bool {
        waterWriteRequestCount += 1
        return false
    }

    func requestWorkoutRead() async -> Bool { false }
}
