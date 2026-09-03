import Foundation

public protocol HealthAuthorizing: Sendable {
    func status() async -> HealthAuthorizationStatus
    func requestBodyMassRead() async -> Bool
    func latestBodyMassKg() async -> Double?
    func requestWaterWrite() async -> Bool
    func requestWorkoutRead() async -> Bool
}
