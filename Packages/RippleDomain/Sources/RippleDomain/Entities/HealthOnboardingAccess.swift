import Foundation

/// The result of Ripple's single HealthKit onboarding authorization request.
public struct HealthOnboardingAccess: Sendable, Equatable, Hashable {
    public let bodyMassKg: Double?
    public let waterWriteAuthorized: Bool

    public init(
        bodyMassKg: Double? = nil,
        waterWriteAuthorized: Bool = false
    ) {
        self.bodyMassKg = bodyMassKg
        self.waterWriteAuthorized = waterWriteAuthorized
    }
}
