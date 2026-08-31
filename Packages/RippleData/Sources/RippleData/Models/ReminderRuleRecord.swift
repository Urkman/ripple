import Foundation
import SwiftData

@Model
public final class ReminderRuleRecord {
    public var enabled: Bool = true
    public var startHour: Int = 7
    public var startMinute: Int = 0
    public var endHour: Int = 22
    public var endMinute: Int = 0
    public var intervalMinutes: Int = 120
    public var afterLastSipMinutes: Int = 120
    public var updatedAt: Date = Date()

    public init() {}
}
