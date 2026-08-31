import Foundation

public struct ReminderRule: Sendable, Hashable, Codable, Equatable {
    public var enabled: Bool
    public var start: ClockTime
    public var end: ClockTime
    public var intervalMinutes: Int
    public var afterLastSipMinutes: Int
    public var updatedAt: Date

    public init(
        enabled: Bool = true,
        start: ClockTime = .defaultWake,
        end: ClockTime = .defaultSleep,
        intervalMinutes: Int = 120,
        afterLastSipMinutes: Int = 120,
        updatedAt: Date = Date()
    ) {
        self.enabled = enabled
        self.start = start
        self.end = end
        self.intervalMinutes = intervalMinutes
        self.afterLastSipMinutes = afterLastSipMinutes
        self.updatedAt = updatedAt
    }

    public static let `default` = ReminderRule()
}
