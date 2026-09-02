import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class WatchDayDetailViewModel {
    public let day: Date
    public private(set) var snapshot: TodaySnapshot
    public private(set) var undoIntakeID: UUID?
    public private(set) var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private var undoTask: Task<Void, Never>?

    public init(useCases: UseCases, day: Date, calendar: Calendar = .current) {
        self.useCases = useCases
        self.day = day
        self.calendar = calendar
        self.snapshot = TodaySnapshot.empty(date: day)
        self.undoIntakeID = nil
        self.errorMessage = nil
    }

    public var entries: [Intake] {
        snapshot.entries
            .filter { !$0.isDeleted }
            .sorted { $0.date > $1.date }
    }

    public func refresh() async {
        do {
            snapshot = try await useCases.observeToday.snapshot(for: day, calendar: calendar)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func containerName(for intake: Intake) -> String? {
        guard let containerID = intake.containerId else { return nil }
        return snapshot.containers.first { $0.id == containerID }?.name
    }

    public func delete(_ intake: Intake) async {
        do {
            try await useCases.deleteIntake.run(id: intake.id)
            undoIntakeID = intake.id
            undoTask?.cancel()
            undoTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                self?.undoIntakeID = nil
            }
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func undoDelete() async {
        guard let undoIntakeID else { return }

        do {
            try await useCases.restoreIntake.run(id: undoIntakeID)
            self.undoIntakeID = nil
            undoTask?.cancel()
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
