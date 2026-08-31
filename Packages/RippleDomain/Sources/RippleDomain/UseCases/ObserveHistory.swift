import Foundation

public struct ObserveHistory: Sendable {
    private let intakeRepository: any IntakeRepository
    private let observeToday: ObserveToday

    public init(intakeRepository: any IntakeRepository, observeToday: ObserveToday) {
        self.intakeRepository = intakeRepository
        self.observeToday = observeToday
    }

    public func firstIntakeDate() async throws -> Date? {
        try await intakeRepository.firstUndeletedIntake()?.date
    }

    public func snapshot(for range: HistoryRange, calendar: Calendar = .current) async throws -> HistorySnapshot {
        let (start, end) = DayWindow.range(for: range, calendar: calendar)
        let all = try await intakeRepository.intakes(from: start, to: end)
        let entries = all.filter { !$0.isDeleted }.sorted { $0.date > $1.date }

        var days: [DayTotal] = []
        var cursor = start
        while cursor < end {
            let daySnapshot = try await observeToday.snapshot(for: cursor, calendar: calendar)
            days.append(
                DayTotal(
                    date: cursor,
                    consumed: daySnapshot.consumed,
                    goal: daySnapshot.goal
                )
            )
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        return HistorySnapshot(range: range, days: days, entries: entries)
    }
}
