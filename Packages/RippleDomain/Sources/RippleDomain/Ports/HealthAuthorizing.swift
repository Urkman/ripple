import Foundation

public protocol HealthAuthorizing: Sendable {
    func status() async -> HealthAuthorizationStatus
    func requestWaterWrite() async -> Bool
    func requestWorkoutRead() async -> Bool
}
