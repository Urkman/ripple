import Foundation

public struct Milliliters: Sendable, Hashable, Codable, Equatable, Comparable {
    public var value: Int

    public init(_ value: Int) {
        self.value = value
    }

    public static func < (lhs: Milliliters, rhs: Milliliters) -> Bool {
        lhs.value < rhs.value
    }

    public static func + (lhs: Milliliters, rhs: Milliliters) -> Milliliters {
        Milliliters(lhs.value + rhs.value)
    }

    public static func - (lhs: Milliliters, rhs: Milliliters) -> Milliliters {
        Milliliters(lhs.value - rhs.value)
    }

    public static let zero = Milliliters(0)
}
