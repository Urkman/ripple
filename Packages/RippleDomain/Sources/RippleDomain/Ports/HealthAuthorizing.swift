import Foundation

public protocol HealthAuthorizing: Sendable {
    func status() async -> HealthAuthorizationStatus
    func requestOnboardingAccess() async -> HealthOnboardingAccess
    func requestBodyMassRead() async -> Bool
    func latestBodyMassKg() async -> Double?
    func requestWaterWrite() async -> Bool
    func requestWorkoutRead() async -> Bool
}
