import Foundation
import Testing
@testable import RippleDomain

@Suite("Authorization use cases")
struct AuthorizationUseCaseTests {
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
