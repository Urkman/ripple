import Foundation

public struct RequestHealthWaterWrite: Sendable {
    private let healthAuthorizing: any HealthAuthorizing

    public init(healthAuthorizing: any HealthAuthorizing) {
        self.healthAuthorizing = healthAuthorizing
    }

    public func run() async -> Bool {
        await healthAuthorizing.requestWaterWrite()
    }
}
