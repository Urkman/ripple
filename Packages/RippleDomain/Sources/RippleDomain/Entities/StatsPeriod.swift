import Foundation

public enum StatsPeriod: Sendable, Hashable, Equatable {
    case week(Date)
    case month(Date)
    case year(Date)

    public func bounds(calendar: Calendar) -> (Date, Date) {
        switch self {
        case .week(let date):
            return DayWindow.isoWeek(for: date, timeZone: calendar.timeZone)
        case .month(let date):
            return DayWindow.range(for: .month(date), calendar: calendar)
        case .year(let date):
            return DayWindow.year(for: date, calendar: calendar)
        }
    }
}
