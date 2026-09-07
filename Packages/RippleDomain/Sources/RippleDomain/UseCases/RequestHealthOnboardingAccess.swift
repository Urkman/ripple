import Foundation

public struct RequestHealthOnboardingAccess: Sendable {
    private let healthAuthorizing: any HealthAuthorizing

    public init(healthAuthorizing: any HealthAuthorizing) {
        self.healthAuthorizing = healthAuthorizing
    }

    public func run() async -> HealthOnboardingAccess {
        let access = await healthAuthorizing.requestOnboardingAccess()

        guard let kilograms = access.bodyMassKg,
              kilograms.isFinite,
              kilograms > 0 else {
            return HealthOnboardingAccess(
                bodyMassKg: nil,
                waterWriteAuthorized: access.waterWriteAuthorized
            )
        }

        return access
    }
}
