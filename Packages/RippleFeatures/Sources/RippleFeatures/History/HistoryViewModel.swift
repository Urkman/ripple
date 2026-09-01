import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class HistoryViewModel {
    public var days: [DaySummary]
    public var visibleMonth: Date
    public var selectedDay: Date?
    public var slots: [MonthSlot]
    public var weekdayColumns: [WeekdayColumn]
    public private(set) var availableMonths: [Date]
    public var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let currentMonth: Date
    @ObservationIgnored private let currentDay: Date
    private var monthDays: [Date: [DaySummary]] = [:]

    public struct MonthSlot: Identifiable, Equatable, Sendable {
        public var id: Int
        public var date: Date?
    }

    public struct WeekdayColumn: Identifiable, Equatable, Sendable {
        public var id: Int
        public var symbol: String
    }

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current) {
        let currentDay = calendar.startOfDay(for: now)
        let currentMonth = calendar.dateInterval(of: .month, for: now)?.start
            ?? calendar.startOfDay(for: now)
        self.useCases = useCases
        self.calendar = calendar
        self.currentMonth = currentMonth
        self.currentDay = currentDay
        self.visibleMonth = currentMonth
        self.days = []
        self.selectedDay = currentDay
        self.slots = []
        self.weekdayColumns = Self.orderedWeekdayColumns(calendar: calendar)
        self.availableMonths = [currentMonth]
        rebuildSlots()
    }

    public var monthTitle: String {
        monthTitle(for: visibleMonth)
    }

    public func monthTitle(for month: Date) -> String {
        month.formatted(.dateTime.month(.wide).year())
    }

    public func summary(on date: Date) -> DaySummary? {
        summary(on: date, in: visibleMonth)
    }

    public func summary(on date: Date, in month: Date) -> DaySummary? {
        let start = calendar.startOfDay(for: date)
        let monthStart = self.monthStart(for: month)
        let summaries = monthDays[monthStart] ?? (monthStart == self.monthStart ? days : [])
        return summaries.first { calendar.isDate($0.date, inSameDayAs: start) }
    }

    public func isToday(_ date: Date, now: Date = Date()) -> Bool {
        calendar.isDate(date, inSameDayAs: now)
    }

    public func isFuture(_ date: Date, now: Date = Date()) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: now)
    }

    public func isSelected(_ date: Date) -> Bool {
        guard let selectedDay else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDay)
    }

    public func select(_ date: Date, now: Date = Date()) {
        guard !isFuture(date, now: now) else { return }
        selectedDay = calendar.startOfDay(for: date)
    }

    public func shiftMonth(_ delta: Int) {
        showMonth(month(atOffset: delta))
    }

    public func showMonth(_ month: Date) {
        let next = monthStart(for: month)
        guard availableMonths.contains(next) else { return }
        guard next != visibleMonth else { return }
        visibleMonth = next
        days = monthDays[next] ?? []
        rebuildSlots()
    }

    public func canNavigate(from month: Date, by delta: Int) -> Bool {
        availableMonths.contains(self.month(atOffset: delta, from: month))
    }

    public func refreshAvailableMonths() async {
        selectTodayIfNeeded()
        do {
            let firstDate = try await useCases.observeHistory.firstIntakeDate()
            let firstMonth = firstDate.map { monthStart(for: $0) } ?? currentMonth
            let boundedFirstMonth = min(firstMonth, currentMonth)
            let months = makeMonths(from: boundedFirstMonth, through: currentMonth)
            availableMonths = months

            if !months.contains(visibleMonth), let firstAvailableMonth = months.first {
                visibleMonth = firstAvailableMonth
                days = monthDays[firstAvailableMonth] ?? []
                rebuildSlots()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func selectTodayIfNeeded() {
        guard selectedDay == nil else { return }
        selectedDay = currentDay
    }

    public func refresh() async {
        await refresh(month: visibleMonth)
    }

    public func refresh(month: Date) async {
        let monthStart = self.monthStart(for: month)
        let year = calendar.component(.year, from: monthStart)
        let month = calendar.component(.month, from: monthStart)
        do {
            let summaries = try await useCases.observeMonth.run(year: year, month: month, calendar: calendar)
            monthDays[monthStart] = summaries
            if monthStart == self.monthStart {
                days = summaries
                rebuildSlots()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func month(atOffset offset: Int) -> Date {
        month(atOffset: offset, from: monthStart)
    }

    public func month(atOffset offset: Int, from month: Date) -> Date {
        let start = monthStart(for: month)
        return calendar.date(byAdding: .month, value: offset, to: start) ?? start
    }

    public func slots(for month: Date) -> [MonthSlot] {
        makeSlots(for: month)
    }

    private var monthStart: Date {
        monthStart(for: visibleMonth)
    }

    private func rebuildSlots() {
        slots = makeSlots(for: visibleMonth)
    }

    private func monthStart(for date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start
            ?? calendar.startOfDay(for: date)
    }

    private func makeSlots(for month: Date) -> [MonthSlot] {
        let start = monthStart(for: month)
        let dayCount = calendar.range(of: .day, in: .month, for: start)?.count ?? 0
        let weekday = calendar.component(.weekday, from: start)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        var result: [MonthSlot] = []
        var index = 0
        for _ in 0..<leading {
            result.append(MonthSlot(id: index, date: nil))
            index += 1
        }
        for day in 0..<dayCount {
            let date = calendar.date(byAdding: .day, value: day, to: start)
            result.append(MonthSlot(id: index, date: date.map { calendar.startOfDay(for: $0) }))
            index += 1
        }
        return result
    }

    private func makeMonths(from firstMonth: Date, through lastMonth: Date) -> [Date] {
        var months: [Date] = []
        var month = monthStart(for: firstMonth)
        let end = monthStart(for: lastMonth)
        while month <= end {
            months.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month), next > month else {
                break
            }
            month = next
        }
        return months.isEmpty ? [currentMonth] : months
    }

    private static func orderedWeekdayColumns(calendar: Calendar) -> [WeekdayColumn] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        let ordered: [String]
        if start >= 0, start < symbols.count {
            ordered = Array(symbols[start...] + symbols[..<start])
        } else {
            ordered = symbols
        }
        return ordered.enumerated().map { WeekdayColumn(id: $0.offset, symbol: $0.element) }
    }
}
