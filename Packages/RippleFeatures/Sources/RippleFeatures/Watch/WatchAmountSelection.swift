import RippleDomain

public struct WatchAmountSelection: Equatable, Sendable {
    public static let minimumMilliliters = 50
    public static let maximumMilliliters = 2_000
    public static let stepMilliliters = 10

    public let unit: VolumeUnit
    public private(set) var milliliters: Int

    public init(milliliters: Int, unit: VolumeUnit) {
        self.unit = unit
        self.milliliters = Self.snappedMilliliters(milliliters)
    }

    public var crownValue: Double {
        Double(milliliters)
    }

    public var crownLowerBound: Double {
        Double(Self.minimumMilliliters)
    }

    public var crownUpperBound: Double {
        Double(Self.maximumMilliliters)
    }

    public mutating func update(crownValue: Double) {
        let safeValue = crownValue.isFinite ? crownValue : self.crownValue
        let clampedValue = min(max(safeValue, crownLowerBound), crownUpperBound)
        let snappedValue = (clampedValue / Double(Self.stepMilliliters)).rounded()
            * Double(Self.stepMilliliters)
        milliliters = Int(snappedValue)
    }

    private static func snappedMilliliters(_ milliliters: Int) -> Int {
        let clamped = min(max(milliliters, minimumMilliliters), maximumMilliliters)
        let step = Int((Double(clamped) / Double(stepMilliliters)).rounded())
        return min(
            max(step * stepMilliliters, minimumMilliliters),
            maximumMilliliters
        )
    }
}
