import Foundation

public struct VolumeFormatter: Sendable {
    public var locale: Locale

    public static var current: VolumeFormatter { VolumeFormatter(locale: .current) }

    public init(locale: Locale = .current) {
        self.locale = locale
    }

    public func string(milliliters: Int, unit: VolumeUnit) -> String {
        "\(valueString(milliliters: milliliters, unit: unit)) \(unit.symbol)"
    }

    public func valueString(milliliters: Int, unit: VolumeUnit) -> String {
        switch unit {
        case .milliliters:
            return grouped(milliliters)
        case .fluidOunces:
            return ounceString(UnitConverter.fluidOunces(fromMilliliters: milliliters))
        }
    }

    public func grouped(_ milliliters: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "\u{202F}"
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: milliliters)) ?? "\(milliliters)"
    }

    public func percentString(_ percent: Double) -> String {
        let clamped = Int((percent * 100).rounded(.toNearestOrEven))
        return "\(clamped)\u{00A0}%"
    }

    public func remainingPhrase(milliliters: Int, unit: VolumeUnit) -> String {
        let amount = string(milliliters: milliliters, unit: unit)
        if locale.language.languageCode?.identifier == "de" {
            return "noch \(amount)"
        }
        return "\(amount) left"
    }

    public func heroAccessibility(consumedMl: Int, goalMl: Int, remainingMl: Int, percent: Double) -> String {
        let consumed = grouped(consumedMl)
        let goal = grouped(goalMl)
        let remaining = grouped(remainingMl)
        let pct = Int((percent * 100).rounded(.toNearestOrEven))
        if locale.language.languageCode?.identifier == "de" {
            return "\(consumed) Milliliter von \(goal). \(pct) Prozent. Noch \(remaining) Milliliter."
        }
        return "\(consumed) milliliters of \(goal). \(pct) percent. \(remaining) milliliters left."
    }

    public func dayCellAccessibility(date: Date, consumedMl: Int, goalMl: Int, hitGoal: Bool) -> String {
        let day = date.formatted(.dateTime.day().month(.wide))
        let consumed = grouped(consumedMl)
        let goal = grouped(goalMl)
        if locale.language.languageCode?.identifier == "de" {
            let status = hitGoal ? "Ziel erreicht." : "Ziel noch nicht erreicht."
            return "\(day), \(consumed) Milliliter von \(goal), \(status)"
        }
        let status = hitGoal ? "Goal reached." : "Goal not reached."
        return "\(day), \(consumed) milliliters of \(goal), \(status)"
    }

    public func litersSpeech(milliliters: Int) -> String {
        let liters = Double(milliliters) / 1000.0
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = liters.rounded() == liters ? 0 : 1
        let value = formatter.string(from: NSNumber(value: liters)) ?? "\(liters)"
        if locale.language.languageCode?.identifier == "de" {
            return "\(value) Liter"
        }
        return "\(value) liters"
    }

    private func ounceString(_ ounces: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.maximumFractionDigits = ounces.rounded() == ounces ? 0 : 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: ounces)) ?? "\(ounces)"
    }
}
