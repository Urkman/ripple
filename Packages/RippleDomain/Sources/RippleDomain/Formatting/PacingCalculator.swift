import Foundation

public enum PacingCalculator: Sendable {
    public static func millilitersPerHour(
        remaining: Milliliters,
        now: Date,
        wake: ClockTime,
        sleep: ClockTime,
        calendar: Calendar = .current
    ) -> Int? {
        let remainingMinutes = minutesUntilSleep(now: now, wake: wake, sleep: sleep, calendar: calendar)
        guard remainingMinutes > 0, remaining.value > 0 else { return nil }
        let hours = Double(remainingMinutes) / 60.0
        return Int((Double(remaining.value) / hours).rounded())
    }

    public static func minutesUntilSleep(
        now: Date,
        wake: ClockTime,
        sleep: ClockTime,
        calendar: Calendar = .current
    ) -> Int {
        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        let wakeMinutes = wake.minutesSinceMidnight
        let sleepMinutes = sleep.minutesSinceMidnight

        if sleepMinutes > wakeMinutes {
            if nowMinutes < wakeMinutes || nowMinutes >= sleepMinutes {
                return 0
            }
            return sleepMinutes - nowMinutes
        }

        if nowMinutes >= sleepMinutes && nowMinutes < wakeMinutes {
            return 0
        }
        if nowMinutes >= wakeMinutes {
            return (24 * 60 - nowMinutes) + sleepMinutes
        }
        return sleepMinutes - nowMinutes
    }
}
