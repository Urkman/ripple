import Foundation

public enum DayWindow: Sendable {
    public static func startOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    public static func endOfDay(_ date: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
    }

    public static func range(for history: HistoryRange, calendar: Calendar = .current) -> (Date, Date) {
        switch history {
        case .day(let date):
            return (startOfDay(date, calendar: calendar), endOfDay(date, calendar: calendar))
        case .week(let date):
            let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(date, calendar: calendar)
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(86_400 * 7)
            return (start, end)
        case .month(let date):
            let start = calendar.dateInterval(of: .month, for: date)?.start ?? startOfDay(date, calendar: calendar)
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            return (start, end)
        case .recentDays(let anchor, let count):
            let anchorStart = startOfDay(anchor, calendar: calendar)
            let dayCount = max(count, 1)
            let start = calendar.date(
                byAdding: .day,
                value: -(dayCount - 1),
                to: anchorStart
            ) ?? anchorStart
            let end = calendar.date(byAdding: .day, value: 1, to: anchorStart) ?? anchorStart
            return (start, end)
        }
    }

    public static func month(year: Int, month: Int, calendar: Calendar = .current) -> (Date, Date) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let start = calendar.date(from: components).map { calendar.startOfDay(for: $0) }
            ?? startOfDay(Date(), calendar: calendar)
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
        return (start, end)
    }

    public static func year(for date: Date, calendar: Calendar = .current) -> (Date, Date) {
        let start = calendar.dateInterval(of: .year, for: date)?.start ?? startOfDay(date, calendar: calendar)
        let end = calendar.date(byAdding: .year, value: 1, to: start) ?? start
        return (start, end)
    }

    public static func isoWeek(for date: Date, timeZone: TimeZone = .current) -> (Date, Date) {
        var iso = Calendar(identifier: .iso8601)
        iso.timeZone = timeZone
        let start = iso.dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(date, calendar: iso)
        let end = iso.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(86_400 * 7)
        return (start, end)
    }
}
