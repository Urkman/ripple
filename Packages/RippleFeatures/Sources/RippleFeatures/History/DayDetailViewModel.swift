import Foundation
import Observation
import RippleDomain

@MainActor
@Observable
public final class DayDetailViewModel {
    public var snapshot: TodaySnapshot
    public var editing: Intake?
    public var undoIntakeID: UUID?
    public var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored public let day: Date
    @ObservationIgnored private var undoTask: Task<Void, Never>?

    public init(useCases: UseCases, day: Date, calendar: Calendar = .current) {
        self.useCases = useCases
        self.calendar = calendar
        self.day = day
        self.snapshot = .empty(date: day)
    }

    public var isToday: Bool {
        calendar.isDateInToday(day)
    }

    public func refresh() async {
        do {
            snapshot = try await useCases.observeToday.snapshot(for: day)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func addDefault() async {
        guard isToday else { return }
        do {
            _ = try await useCases.logIntake.run(
                amount: Milliliters(snapshot.defaultAddMl),
                source: .app,
                containerId: snapshot.containers.first(where: \.isDefault)?.id
            )
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func delete(_ intake: Intake) async {
        do {
            try await useCases.deleteIntake.run(id: intake.id)
            undoIntakeID = intake.id
            undoTask?.cancel()
            undoTask = Task {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                undoIntakeID = nil
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

    public func saveEdit(amountMl: Int, date: Date, containerId: UUID?) async {
        guard let editing else { return }
        do {
            try await useCases.editIntake.run(
                id: editing.id,
                amountMl: amountMl,
                date: date,
                containerId: containerId,
                updateContainer: true
            )
            self.editing = nil
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func containerName(for intake: Intake) -> String? {
        snapshot.containers.first(where: { $0.id == intake.containerId })?.name
    }
}
