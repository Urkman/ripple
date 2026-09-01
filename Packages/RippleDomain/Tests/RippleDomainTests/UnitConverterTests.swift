import Foundation
import Testing
@testable import RippleDomain

@Suite("UnitConverter")
struct UnitConverterTests {
    @Test("ounces convert to milliliters")
    func ouncesToMilliliters() {
        #expect(UnitConverter.milliliters(fromFluidOunces: 8) == 237)
        #expect(UnitConverter.milliliters(fromFluidOunces: 1) == 30)
    }

    @Test("milliliters convert to ounces")
    func millilitersToOunces() {
        let ounces = UnitConverter.fluidOunces(fromMilliliters: 250)
        #expect(abs(ounces - 8.45) < 0.05)
    }

    @Test("German grouping uses narrow space")
    func germanGrouping() {
        let formatter = VolumeFormatter(locale: Locale(identifier: "de_DE"))
        let text = formatter.string(milliliters: 1250, unit: .milliliters)
        #expect(text.contains("\u{202F}"))
        #expect(text.contains("ml"))
        #expect(!text.contains("°"))
    }

    @Test("hero VoiceOver copy names milliliters and remaining")
    func heroAccessibility() {
        let formatter = VolumeFormatter(locale: Locale(identifier: "de_DE"))
        let text = formatter.heroAccessibility(consumedMl: 1250, goalMl: 2000, remainingMl: 750, percent: 0.625)
        #expect(text.contains("Milliliter von"))
        #expect(text.contains("62 Prozent"))
        #expect(text.contains("Noch"))
        #expect(text.contains("750"))
    }

    @Test("hero VoiceOver copy follows the preferred unit")
    func heroAccessibilityUsesUnit() {
        let formatter = VolumeFormatter(locale: Locale(identifier: "en_US"))
        let text = formatter.heroAccessibility(
            consumedMl: 250,
            goalMl: 2000,
            remainingMl: 1750,
            percent: 0.125,
            unit: .fluidOunces
        )
        #expect(text.contains("fluid ounces"))
        #expect(!text.contains("milliliters"))
    }
}
