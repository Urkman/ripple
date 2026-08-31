import Foundation

public enum VolumeUnit: String, Sendable, Codable, CaseIterable, Equatable {
    case milliliters
    case fluidOunces

    public var symbol: String {
        switch self {
        case .milliliters: "ml"
        case .fluidOunces: "fl oz"
        }
    }
}
