import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Watch Crown amount selection")
struct WatchAmountSelectionTests {
    @Test("Crown values snap and clamp to 10 ml steps")
    func metricSteps() {
        var selection = WatchAmountSelection(milliliters: 251, unit: .milliliters)

        #expect(selection.milliliters == 250)
        #expect(selection.crownValue == 250)
        #expect(selection.crownLowerBound == 50)
        #expect(selection.crownUpperBound == 2_000)

        selection.update(crownValue: 260)
        #expect(selection.milliliters == 260)

        selection.update(crownValue: 1)
        #expect(selection.milliliters == 50)
        selection.update(crownValue: 2_099)
        #expect(selection.milliliters == 2_000)
    }

    @Test("fluid-ounce display preserves 10 ml Crown steps")
    func fluidOunceSteps() {
        var selection = WatchAmountSelection(milliliters: 250, unit: .fluidOunces)

        #expect(selection.milliliters == 250)
        #expect(selection.crownValue == 250)
        #expect(selection.crownLowerBound == 50)
        #expect(selection.crownUpperBound == 2_000)

        selection.update(crownValue: 260)
        #expect(selection.milliliters == 260)
        #expect(UnitConverter.fluidOunces(fromMilliliters: selection.milliliters) > 8)

        selection.update(crownValue: 1)
        #expect(selection.crownValue == 50)
        #expect(selection.milliliters == 50)
        selection.update(crownValue: 2_099)
        #expect(selection.crownValue == 2_000)
        #expect(selection.milliliters == 2_000)
    }

    @Test("selection is a value type with stable equality")
    func valueSemantics() {
        let first = WatchAmountSelection(milliliters: 500, unit: .milliliters)
        let second = WatchAmountSelection(milliliters: 500, unit: .milliliters)

        #expect(first == second)
        #expect([first].contains(second))
    }
}
