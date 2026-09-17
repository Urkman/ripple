import Foundation
import RippleDomain
import UserNotifications

struct ScheduledReminderNotification: Sendable {
    let identifier: String
    let title: String
    let body: String
    let categoryIdentifier: String
    let fireDate: Date
}

protocol ReminderNotificationCenter: Sendable {
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) async
    func add(_ notification: ScheduledReminderNotification) async
}

private struct SystemReminderNotificationCenter: ReminderNotificationCenter {
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func add(_ notification: ScheduledReminderNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.categoryIdentifier = notification.categoryIdentifier

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notification.fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notification.identifier,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}

public struct ReminderScheduler: ReminderScheduling {
    private let notificationAuthorizing: any NotificationAuthorizing
    private let notificationCenter: any ReminderNotificationCenter

    public init(
        notificationAuthorizing: any NotificationAuthorizing = NotificationAuthorizer()
    ) {
        self.notificationAuthorizing = notificationAuthorizing
        self.notificationCenter = SystemReminderNotificationCenter()
    }

    init(
        notificationAuthorizing: any NotificationAuthorizing,
        notificationCenter: any ReminderNotificationCenter
    ) {
        self.notificationAuthorizing = notificationAuthorizing
        self.notificationCenter = notificationCenter
    }

    public func reschedule(rule: ReminderRule, lastSip: Date?) async {
        await notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [Self.identifier]
        )

        guard rule.enabled else { return }

        let authorization = await notificationAuthorizing.status()
        guard authorization.isAllowed else { return }

        guard let fireDate = Self.nextFireDate(rule: rule, lastSip: lastSip, now: Date()) else {
            return
        }

        let notification = ScheduledReminderNotification(
            identifier: Self.identifier,
            title: String(localized: "Time for a sip"),
            body: String(localized: "A small Ripple keeps you in the flow."),
            categoryIdentifier: Self.category,
            fireDate: fireDate
        )
        await notificationCenter.add(notification)
    }

    public static let identifier = "de.stefansturm.ripple.reminder"
    public static let category = "RIPPLE_LOG"
    public static let logAction = "LOG_DEFAULT"

    public static func registerCategories() {
        let log = UNNotificationAction(
            identifier: logAction,
            title: String(localized: "Log default"),
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Self.category,
            actions: [log],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    public static func nextFireDate(rule: ReminderRule, lastSip: Date?, now: Date, calendar: Calendar = .current) -> Date? {
        guard rule.enabled else { return nil }

        let delayMinutes = max(rule.afterLastSipMinutes, 1)
        let proposed = (lastSip ?? now).addingTimeInterval(TimeInterval(delayMinutes * 60))
        var candidate = max(proposed, now.addingTimeInterval(60))

        for _ in 0..<3 {
            if isInsideWindow(candidate, rule: rule, calendar: calendar) {
                return candidate
            }
            if let nextStart = nextWindowStart(after: candidate, rule: rule, calendar: calendar) {
                candidate = nextStart
            } else {
                return nil
            }
        }
        return nil
    }

    private static func isInsideWindow(_ date: Date, rule: ReminderRule, calendar: Calendar) -> Bool {
        let minutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        let start = rule.start.minutesSinceMidnight
        let end = rule.end.minutesSinceMidnight
        if end > start {
            return minutes >= start && minutes < end
        }
        return minutes >= start || minutes < end
    }

    private static func nextWindowStart(after date: Date, rule: ReminderRule, calendar: Calendar) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = rule.start.hour
        components.minute = rule.start.minute
        components.second = 0
        guard let todayStart = calendar.date(from: components) else { return nil }
        if todayStart > date {
            return todayStart
        }
        return calendar.date(byAdding: .day, value: 1, to: todayStart)
    }
}
