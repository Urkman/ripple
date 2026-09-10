import Foundation
import Observation
import RippleDomain
import RippleUI

@MainActor
@Observable
public final class WatchTodayViewModel {
    public private(set) var snapshot: TodaySnapshot
    public private(set) var selectedAmountMl: Int
    public private(set) var selectedContainerID: UUID?
    public private(set) var crownSelection: WatchAmountSelection
    public private(set) var isAmountSheetPresented: Bool
    public private(set) var isLogging: Bool
    public private(set) var successFeedback: Int
    public private(set) var confirmation: String?
    public private(set) var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private var savedSelection: SavedSelection?
    @ObservationIgnored private var confirmationTask: Task<Void, Never>?

    private struct SavedSelection: Sendable {
        var amountMl: Int
        var containerID: UUID?
    }

    public init(useCases: UseCases, now: Date = Date(), calendar: Calendar = .current) {
        let initialSnapshot = TodaySnapshot.empty(date: now)
        self.useCases = useCases
        self.calendar = calendar
        self.snapshot = initialSnapshot
        self.selectedAmountMl = initialSnapshot.defaultAddMl
        self.selectedContainerID = initialSnapshot.containers.first(where: \.isDefault)?.id
        self.crownSelection = WatchAmountSelection(
            milliliters: initialSnapshot.defaultAddMl,
            unit: initialSnapshot.unit
        )
        self.isAmountSheetPresented = false
        self.isLogging = false
        self.successFeedback = 0
        self.confirmation = nil
        self.errorMessage = nil
    }

    public var quickContainers: [Container] {
        Array(snapshot.containers.prefix(3))
    }

    public var waterLevel: Double {
        Double(
            RippleMotion.fillLevel(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value
            )
        )
    }

    public func refresh(now: Date = Date()) async {
        do {
            let refreshed = try await useCases.observeToday.snapshot(
                for: now,
                now: now,
                calendar: calendar
            )
            snapshot = refreshed
            errorMessage = nil

            if !isAmountSheetPresented {
                selectedAmountMl = refreshed.defaultAddMl
                selectedContainerID = refreshed.containers.first(where: \.isDefault)?.id
                crownSelection = WatchAmountSelection(
                    milliliters: refreshed.defaultAddMl,
                    unit: refreshed.unit
                )
            } else if crownSelection.unit != refreshed.unit {
                crownSelection = WatchAmountSelection(
                    milliliters: selectedAmountMl,
                    unit: refreshed.unit
                )
                selectedAmountMl = crownSelection.milliliters
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func select(container: Container) {
        selectedAmountMl = max(container.amountMl, WatchAmountSelection.minimumMilliliters)
        selectedContainerID = container.id
        crownSelection = WatchAmountSelection(
            milliliters: selectedAmountMl,
            unit: snapshot.unit
        )
        errorMessage = nil
    }

    public func openAmountSheet() {
        savedSelection = SavedSelection(
            amountMl: selectedAmountMl,
            containerID: selectedContainerID
        )
        crownSelection = WatchAmountSelection(
            milliliters: selectedAmountMl,
            unit: snapshot.unit
        )
        isAmountSheetPresented = true
        errorMessage = nil
    }

    public func updateCrown(_ value: Double) {
        guard isAmountSheetPresented else { return }
        crownSelection.update(crownValue: value)
        selectedAmountMl = crownSelection.milliliters
        selectedContainerID = nil
        errorMessage = nil
    }

    public func dismissAmountSheet() {
        if let savedSelection {
            selectedAmountMl = savedSelection.amountMl
            selectedContainerID = savedSelection.containerID
            crownSelection = WatchAmountSelection(
                milliliters: savedSelection.amountMl,
                unit: snapshot.unit
            )
        }
        self.savedSelection = nil
        isAmountSheetPresented = false
        errorMessage = nil
    }

    public func addSelected() async {
        guard !isLogging else { return }

        let amountMl = selectedAmountMl
        let containerID = selectedContainerID
        isLogging = true
        errorMessage = nil
        defer { isLogging = false }

        do {
            _ = try await useCases.logIntake.run(
                amount: Milliliters(amountMl),
                source: .watch,
                date: Date(),
                containerId: containerID
            )

            await refresh()
            successFeedback += 1
            showConfirmation(amount: amountMl)
            if isAmountSheetPresented {
                savedSelection = nil
                isAmountSheetPresented = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func showConfirmation(amount: Int) {
        let formatter = VolumeFormatter.current
        confirmation = snapshot.isGoalMet
            ? L10n.inTheFlow
            : L10n.confirmation(
                amount: formatter.string(
                    milliliters: amount,
                    unit: snapshot.unit
                )
            )

        confirmationTask?.cancel()
        confirmationTask = Task {
            try? await Task.sleep(for: .seconds(RippleMotion.durationConfirm))
            guard !Task.isCancelled else { return }
            confirmation = nil
        }
    }

}
