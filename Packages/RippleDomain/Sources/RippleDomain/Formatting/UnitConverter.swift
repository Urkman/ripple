import Foundation

public enum UnitConverter: Sendable {
    public static let millilitersPerFluidOunce = 29.5735295625

    public static func milliliters(fromFluidOunces ounces: Double) -> Int {
        Int((ounces * millilitersPerFluidOunce).rounded())
    }

    public static func fluidOunces(fromMilliliters milliliters: Int) -> Double {
        Double(milliliters) / millilitersPerFluidOunce
    }

    public static func convert(_ milliliters: Int, to unit: VolumeUnit) -> Double {
        switch unit {
        case .milliliters:
            Double(milliliters)
        case .fluidOunces:
            fluidOunces(fromMilliliters: milliliters)
        }
    }

    public static func milliliters(amount: Double, unit: VolumeUnit) -> Int {
        switch unit {
        case .milliliters:
            Int(amount.rounded())
        case .fluidOunces:
            Self.milliliters(fromFluidOunces: amount)
        }
    }

    public static func quickAddPresets(for unit: VolumeUnit) -> [Int] {
        switch unit {
        case .milliliters:
            [250, 500]
        case .fluidOunces:
            [
                milliliters(fromFluidOunces: 8),
                milliliters(fromFluidOunces: 16),
            ]
        }
    }
}
