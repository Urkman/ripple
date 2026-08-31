import Foundation

public struct HealthAuthorizationStatus: Sendable, Hashable, Equatable {
    public var waterWrite: Bool
    public var workoutRead: Bool

    public init(waterWrite: Bool = false, workoutRead: Bool = false) {
        self.waterWrite = waterWrite
        self.workoutRead = workoutRead
    }
}
