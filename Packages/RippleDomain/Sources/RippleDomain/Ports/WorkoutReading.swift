import Foundation

public protocol WorkoutReading: Sendable {
    func moderateMinutes(on day: Date) async -> Int
}
