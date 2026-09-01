import RippleDomain

public struct WatchAmountSelection: Equatable, Sendable {
    public static let minimumMilliliters = 50
    public static let maximumMilliliters = 2_000
    public static let metricStepMilliliters = 50
    public static let fluidOunceStep = 1

    public let unit: VolumeUnit
    public private(set) var milliliters: Int

    public init(milliliters: Int, unit: VolumeUnit) {
        self.unit = unit
        self.milliliters = Self.snappedMilliliters(milliliters, unit: unit)
    }

    public var crownValue: Double {
        switch unit {
        case .milliliters:
            Double(milliliters / Self.metricStepMilliliters)
        case .fluidOunces:
            UnitConverter.fluidOunces(fromMilliliters: milliliters).rounded()
        }
    }

    public var crownLowerBound: Double {
        switch unit {
        case .milliliters:
            1
        case .fluidOunces:
            2
        }
    }

    public var crownUpperBound: Double {
        switch unit {
        case .milliliters:
            Double(Self.maximumMilliliters / Self.metricStepMilliliters)
        case .fluidOunces:
            67
        }
    }

    public mutating func update(crownValue: Double) {
        let safeValue = crownValue.isFinite ? crownValue : self.crownValue
        let snappedValue = min(max(safeValue.rounded(), crownLowerBound), crownUpperBound)

        switch unit {
        case .milliliters:
            milliliters = Int(snappedValue) * Self.metricStepMilliliters
        case .fluidOunces:
            milliliters = UnitConverter.milliliters(amount: snappedValue, unit: .fluidOunces)
        }
    }

    private static func snappedMilliliters(_ milliliters: Int, unit: VolumeUnit) -> Int {
        switch unit {
        case .milliliters:
            let clamped = min(max(milliliters, minimumMilliliters), maximumMilliliters)
            let step = Int((Double(clamped) / Double(metricStepMilliliters)).rounded())
            return min(max(step * metricStepMilliliters, minimumMilliliters), maximumMilliliters)
        case .fluidOunces:
            let ounces = UnitConverter.fluidOunces(fromMilliliters: milliliters).rounded()
            let clamped = min(max(ounces, 2), 67)
            return UnitConverter.milliliters(amount: clamped, unit: .fluidOunces)
        }
    }
}
