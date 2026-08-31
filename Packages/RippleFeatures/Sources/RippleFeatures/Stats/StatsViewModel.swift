import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class StatsViewModel {
    public var kind: Kind
    public var anchor: Date
    public var snapshot: StatsSnapshot
    public var unit: VolumeUnit
    public var containers: [Container]
    public var errorMessage: String?

    public enum Kind: String, CaseIterable, Identifiable, Sendable {
        case week, month, year
        public var id: String { rawValue }
    }

    struct VolumeBarPoint: Identifiable, Equatable {
        var id: Date { date }
        var date: Date
        var consumed: Double
        var goal: Double
        var percent: Double
    }

    struct HitRatePoint: Identifiable, Equatable {
        var id: Date { date }
        var date: Date
        var percent: Double
    }

    struct DaypartPoint: Identifiable, Equatable {
        var id: Daypart { part }
        var part: Daypart
        var milliliters: Int
        var plotValue: Double
    }

    struct ContainerSharePoint: Identifiable, Equatable {
        var id: String { name }
        var name: String
        var milliliters: Int
        var plotValue: Double
    }

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current) {
        self.useCases = useCases
        self.calendar = calendar
        self.kind = .week
        self.anchor = now
        self.unit = .milliliters
        self.containers = []
        self.snapshot = .empty(range: DateInterval(start: now, duration: 0))
        self.referenceNow = now
    }

    public var periodTitle: String {
        switch kind {
        case .week:
            let (start, _) = StatsPeriod.week(anchor).bounds(calendar: calendar)
            return start.formatted(.dateTime.month(.abbreviated).day())
        case .month:
            return anchor.formatted(.dateTime.month(.wide).year())
        case .year:
            return anchor.formatted(.dateTime.year())
        }
    }

    var volumeBars: [VolumeBarPoint] {
        switch kind {
        case .week, .month:
            return snapshot.daily.map { day in
                VolumeBarPoint(
                    date: day.date,
                    consumed: plot(day.consumedMl),
                    goal: plot(day.goalMl),
                    percent: day.progress
                )
            }
        case .year:
            return monthlyTotals().map { month in
                let percent = month.goalMl > 0 ? min(1, Double(month.consumedMl) / Double(month.goalMl)) : 0
                return VolumeBarPoint(
                    date: month.date,
                    consumed: plot(month.consumedMl),
                    goal: plot(month.goalMl),
                    percent: percent
                )
            }
        }
    }

    var hitRatePoints: [HitRatePoint] {
        switch kind {
        case .week, .month:
            return snapshot.daily.map {
                HitRatePoint(date: $0.date, percent: $0.hitGoal ? 100 : 0)
            }
        case .year:
            return monthlyTotals().map { month in
                HitRatePoint(date: month.date, percent: month.hitRate * 100)
            }
        }
    }

    var daypartPoints: [DaypartPoint] {
        Daypart.allCases.map { part in
            let ml = snapshot.byDaypart[part] ?? 0
            return DaypartPoint(part: part, milliliters: ml, plotValue: plot(ml))
        }
    }

    var containerPoints: [ContainerSharePoint] {
        let named: [(String, Int)] = snapshot.byContainer.map { id, ml in
            if let id, let name = containers.first(where: { $0.id == id })?.name {
                return (name, ml)
            }
            return (L10n.text("Unknown"), ml)
        }
        let grouped = Dictionary(named, uniquingKeysWith: +)
        let sorted = grouped.sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        if sorted.count <= 6 {
            return sorted.map {
                ContainerSharePoint(name: $0.key, milliliters: $0.value, plotValue: plot($0.value))
            }
        }
        let top = sorted.prefix(5)
        let rest = sorted.dropFirst(5).reduce(0) { $0 + $1.value }
        var points = top.map {
            ContainerSharePoint(name: $0.key, milliliters: $0.value, plotValue: plot($0.value))
        }
        points.append(
            ContainerSharePoint(
                name: L10n.text("Other"),
                milliliters: rest,
                plotValue: plot(rest)
            )
        )
        return points
    }

    public var referenceNow: Date

    public var averageMl: Int {
        snapshot.averageMlPerDay(now: referenceNow, calendar: calendar)
    }

    public var elapsedCount: Int {
        snapshot.daysElapsed(now: referenceNow, calendar: calendar)
    }

    public var hitDayCount: Int {
        snapshot.hitDays(now: referenceNow, calendar: calendar)
    }

    public var emptyDayCount: Int {
        snapshot.emptyDays(now: referenceNow, calendar: calendar)
    }

    public var weakestDay: DaySummary? {
        snapshot.weakestDay(now: referenceNow, calendar: calendar)
    }

    public func shift(_ delta: Int) {
        switch kind {
        case .week:
            anchor = calendar.date(byAdding: .day, value: 7 * delta, to: anchor) ?? anchor
        case .month:
            anchor = calendar.date(byAdding: .month, value: delta, to: anchor) ?? anchor
        case .year:
            anchor = calendar.date(byAdding: .year, value: delta, to: anchor) ?? anchor
        }
    }

    public func refresh(now: Date = Date()) async {
        referenceNow = now
        let period: StatsPeriod
        switch kind {
        case .week: period = .week(anchor)
        case .month: period = .month(anchor)
        case .year: period = .year(anchor)
        }
        do {
            snapshot = try await useCases.observeStats.run(range: period, calendar: calendar, now: now)
            let profile = try await useCases.settingsRepository.profile()
            unit = profile.preferredUnit
            containers = try await useCases.settingsRepository.containers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func plot(_ milliliters: Int) -> Double {
        UnitConverter.convert(milliliters, to: unit)
    }

    private struct MonthTotal {
        var date: Date
        var consumedMl: Int
        var goalMl: Int
        var hitRate: Double
    }

    private func monthlyTotals() -> [MonthTotal] {
        let (yearStart, _) = DayWindow.year(for: anchor, calendar: calendar)
        return (0..<12).compactMap { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: yearStart) else {
                return nil
            }
            let days = snapshot.daily.filter { calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
            let today = calendar.startOfDay(for: referenceNow)
            let elapsed = days.filter { $0.date <= today }
            let consumed = days.reduce(0) { $0 + $1.consumedMl }
            let goal = elapsed.reduce(0) { $0 + $1.goalMl }
            let hits = elapsed.filter(\.hitGoal).count
            let rate = elapsed.isEmpty ? 0 : Double(hits) / Double(elapsed.count)
            return MonthTotal(date: monthDate, consumedMl: consumed, goalMl: goal, hitRate: rate)
        }
    }
}
