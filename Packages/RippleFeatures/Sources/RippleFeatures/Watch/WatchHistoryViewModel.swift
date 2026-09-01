import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class WatchHistoryViewModel {
    public private(set) var days: [DayTotal]
    public private(set) var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current) {
        self.useCases = useCases
        self.calendar = calendar
        self.days = []
        self.errorMessage = nil
    }

    public func refresh(now: Date = Date()) async {
        do {
            let snapshot = try await useCases.observeHistory.snapshot(
                for: .recentDays(anchor: now, count: 7),
                calendar: calendar
            )
            let today = calendar.startOfDay(for: now)
            days = snapshot.days
                .filter { $0.date <= today }
                .sorted { $0.date > $1.date }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
