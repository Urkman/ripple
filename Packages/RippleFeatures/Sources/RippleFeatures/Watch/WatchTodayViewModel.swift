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
    public private(set) var customSelection: WatchAmountSelection
    public private(set) var isCustomPresented: Bool
    public private(set) var isLogging: Bool
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
        self.customSelection = WatchAmountSelection(
            milliliters: initialSnapshot.defaultAddMl,
            unit: initialSnapshot.unit
        )
        self.isCustomPresented = false
        self.isLogging = false
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

            if !isCustomPresented {
                selectedAmountMl = refreshed.defaultAddMl
                selectedContainerID = refreshed.containers.first(where: \.isDefault)?.id
                customSelection = WatchAmountSelection(
                    milliliters: refreshed.defaultAddMl,
                    unit: refreshed.unit
                )
            } else if customSelection.unit != refreshed.unit {
                customSelection = WatchAmountSelection(
                    milliliters: selectedAmountMl,
                    unit: refreshed.unit
                )
                selectedAmountMl = customSelection.milliliters
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func select(container: Container) {
        selectedAmountMl = max(container.amountMl, WatchAmountSelection.minimumMilliliters)
        selectedContainerID = container.id
        errorMessage = nil
    }

    public func openCustom() {
        savedSelection = SavedSelection(
            amountMl: selectedAmountMl,
            containerID: selectedContainerID
        )
        customSelection = WatchAmountSelection(
            milliliters: selectedAmountMl,
            unit: snapshot.unit
        )
        selectedAmountMl = customSelection.milliliters
        selectedContainerID = nil
        isCustomPresented = true
        errorMessage = nil
    }

    public func updateCustomCrown(_ value: Double) {
        guard isCustomPresented else { return }
        customSelection.update(crownValue: value)
        selectedAmountMl = customSelection.milliliters
        selectedContainerID = nil
        errorMessage = nil
    }

    public func cancelCustom() {
        if let savedSelection {
            selectedAmountMl = savedSelection.amountMl
            selectedContainerID = savedSelection.containerID
        }
        self.savedSelection = nil
        isCustomPresented = false
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

            let amountText = VolumeFormatter.current.string(
                milliliters: amountMl,
                unit: snapshot.unit
            )
            await refresh()
            confirmation = L10n.confirmation(amount: amountText)
            scheduleConfirmationClear()
            if isCustomPresented {
                savedSelection = nil
                isCustomPresented = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func scheduleConfirmationClear() {
        confirmationTask?.cancel()
        confirmationTask = Task { @MainActor [weak self] in
            try? await Task.sleep(
                for: .seconds(RippleMotion.durationConfirm + RippleMotion.confirmFade)
            )
            guard !Task.isCancelled else { return }
            self?.confirmation = nil
        }
    }
}
