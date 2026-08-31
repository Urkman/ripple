import Foundation

public enum ActivityLevel: String, Sendable, Codable, CaseIterable, Equatable {
    case sedentary
    case moderate
    case high

    public var bonusMilliliters: Int {
        switch self {
        case .sedentary: 0
        case .moderate: 350
        case .high: 700
        }
    }
}
