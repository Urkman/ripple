import Foundation
import RippleDomain
import UserNotifications

public struct ReminderScheduler: ReminderScheduling {
    public init() {}

    public func reschedule(rule: ReminderRule, lastSip: Date?) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])

        guard rule.enabled else { return }

        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }

        guard let fireDate = Self.nextFireDate(rule: rule, lastSip: lastSip, now: Date()) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time for a sip")
        content.body = String(localized: "A small Ripple keeps you in the flow.")
        content.sound = .default
        content.categoryIdentifier = Self.category

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.identifier,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
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
