import Foundation

public struct ClockTime: Sendable, Hashable, Codable, Equatable {
    public var hour: Int
    public var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = min(max(hour, 0), 23)
        self.minute = min(max(minute, 0), 59)
    }

    public var minutesSinceMidnight: Int {
        hour * 60 + minute
    }

    public static let defaultWake = ClockTime(hour: 7, minute: 0)
    public static let defaultSleep = ClockTime(hour: 22, minute: 0)
}
