import Foundation

#if canImport(ActivityKit) && os(iOS)
import ActivityKit

public struct RippleActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var consumedMl: Int
        public var goalMl: Int
        public var defaultAddMl: Int
        public var unitRaw: String

        public init(consumedMl: Int, goalMl: Int, defaultAddMl: Int, unitRaw: String) {
            self.consumedMl = consumedMl
            self.goalMl = goalMl
            self.defaultAddMl = defaultAddMl
            self.unitRaw = unitRaw
        }
    }

    public var dayStart: Date

    public init(dayStart: Date) {
        self.dayStart = dayStart
    }
}
#endif
