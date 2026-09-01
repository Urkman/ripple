import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class WatchStatsViewModel {
    public struct ChartPoint: Identifiable, Equatable, Sendable {
        public let date: Date
        public let consumedMl: Int
        public let goalMl: Int

        public var id: Date { date }

        public init(date: Date, consumedMl: Int, goalMl: Int) {
            self.date = date
            self.consumedMl = consumedMl
            self.goalMl = goalMl
        }
    }

    public private(set) var snapshot: StatsSnapshot
    public private(set) var unit: VolumeUnit
    public private(set) var referenceNow: Date
    public private(set) var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current) {
        self.useCases = useCases
        self.calendar = calendar
        let bounds = StatsPeriod.week(now).bounds(calendar: calendar)
        self.snapshot = StatsSnapshot.empty(
            range: DateInterval(start: bounds.0, end: bounds.1)
        )
        self.unit = .milliliters
        self.referenceNow = now
        self.errorMessage = nil
    }

    public var averageMl: Int {
        snapshot.averageMlPerDay(now: referenceNow, calendar: calendar)
    }

    public var elapsedDayCount: Int {
        snapshot.daysElapsed(now: referenceNow, calendar: calendar)
    }

    public var hitDayCount: Int {
        snapshot.hitDays(now: referenceNow, calendar: calendar)
    }

    public var chartPoints: [ChartPoint] {
        guard snapshot.hasData else { return [] }
        return snapshot.daily.map {
            ChartPoint(date: $0.date, consumedMl: $0.consumedMl, goalMl: $0.goalMl)
        }
    }

    public func refresh(now: Date = Date()) async {
        do {
            let refreshedSnapshot = try await useCases.observeStats.run(
                range: .week(now),
                calendar: calendar,
                now: now
            )
            let profile = try await useCases.settingsRepository.profile()
            snapshot = refreshedSnapshot
            unit = profile.preferredUnit
            referenceNow = now
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
