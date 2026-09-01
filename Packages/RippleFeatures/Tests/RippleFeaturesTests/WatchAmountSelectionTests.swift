import Foundation
import RippleDomain
import Testing
@testable import RippleFeatures

@Suite("Watch Crown amount selection")
struct WatchAmountSelectionTests {
    @Test("metric Crown values snap and clamp to 50 ml steps")
    func metricSteps() {
        var selection = WatchAmountSelection(milliliters: 251, unit: .milliliters)

        #expect(selection.milliliters == 250)
        #expect(selection.crownValue == 5)
        #expect(selection.crownLowerBound == 1)
        #expect(selection.crownUpperBound == 40)

        selection.update(crownValue: 6)
        #expect(selection.milliliters == 300)

        selection.update(crownValue: -10)
        #expect(selection.milliliters == 50)
        selection.update(crownValue: 99)
        #expect(selection.milliliters == 2_000)
    }

    @Test("fluid-ounce Crown values use one-ounce steps")
    func fluidOunceSteps() {
        var selection = WatchAmountSelection(milliliters: 250, unit: .fluidOunces)

        #expect(selection.milliliters == 237)
        #expect(selection.crownValue == 8)
        #expect(selection.crownLowerBound == 2)
        #expect(selection.crownUpperBound == 67)

        selection.update(crownValue: 9)
        #expect(selection.milliliters == 266)

        selection.update(crownValue: 1)
        #expect(selection.crownValue == 2)
        #expect(selection.milliliters == 59)
        selection.update(crownValue: 100)
        #expect(selection.crownValue == 67)
        #expect(selection.milliliters == 1_981)
    }

    @Test("selection is a value type with stable equality")
    func valueSemantics() {
        let first = WatchAmountSelection(milliliters: 500, unit: .milliliters)
        let second = WatchAmountSelection(milliliters: 500, unit: .milliliters)

        #expect(first == second)
        #expect([first].contains(second))
    }
}
