import Foundation
import Testing
@testable import RippleDomain

@Suite("Pacing")
struct PacingTests {
    @Test("pacing is remaining divided by wake hours left")
    func pacingDuringDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 14, minute: 0))!
        let result = PacingCalculator.millilitersPerHour(
            remaining: Milliliters(800),
            now: now,
            wake: ClockTime(hour: 7, minute: 0),
            sleep: ClockTime(hour: 22, minute: 0),
            calendar: calendar
        )
        #expect(result == 100)
    }

    @Test("no pacing after sleep")
    func afterSleep() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 28, hour: 23, minute: 0))!
        let result = PacingCalculator.millilitersPerHour(
            remaining: Milliliters(800),
            now: now,
            wake: ClockTime(hour: 7, minute: 0),
            sleep: ClockTime(hour: 22, minute: 0),
            calendar: calendar
        )
        #expect(result == nil)
    }
}
