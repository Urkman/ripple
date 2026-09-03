import Foundation

public struct RequestHealthReadAccess: Sendable {
    private let healthAuthorizing: any HealthAuthorizing

    public init(healthAuthorizing: any HealthAuthorizing) {
        self.healthAuthorizing = healthAuthorizing
    }

    public func run() async -> Double? {
        guard await healthAuthorizing.requestBodyMassRead() else {
            return nil
        }

        guard let kilograms = await healthAuthorizing.latestBodyMassKg(),
              kilograms.isFinite,
              kilograms > 0 else {
            return nil
        }

        return kilograms
    }
}
