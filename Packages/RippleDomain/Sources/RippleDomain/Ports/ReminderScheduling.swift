import Foundation

public protocol ReminderScheduling: Sendable {
    func reschedule(rule: ReminderRule, lastSip: Date?) async
}
