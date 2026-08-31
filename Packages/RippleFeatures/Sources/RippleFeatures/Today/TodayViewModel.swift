import Foundation
import Observation
import RippleDomain
import RippleUI

@MainActor
@Observable
public final class TodayViewModel {
    public var snapshot: TodaySnapshot
    public var presentedSnapshot: TodaySnapshot
    public var motion: RippleMotionPhase
    public var addedMl: Int?
    public var confirmation: String?
    public var errorMessage: String?

    @ObservationIgnored private let useCases: UseCases
    @ObservationIgnored private var seriesID = 0
    @ObservationIgnored private var seriesActive = false
    @ObservationIgnored private var confirmationTask: Task<Void, Never>?
    @ObservationIgnored private var motionTask: Task<Void, Never>?

    public init(useCases: UseCases, snapshot: TodaySnapshot = .empty()) {
        self.useCases = useCases
        self.snapshot = snapshot
        self.presentedSnapshot = snapshot
        self.motion = .idle
    }

    public func refresh(now: Date = Date()) async {
        do {
            snapshot = try await useCases.observeToday.snapshot(for: now)
            if !seriesActive {
                presentedSnapshot = snapshot
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func addDefault() async {
        await add(milliliters: snapshot.defaultAddMl)
    }

    public func add(container: Container) async {
        await log(amount: container.amountMl, containerId: container.id)
    }

    public func add(milliliters: Int) async {
        await log(amount: milliliters, containerId: nil)
    }

    public func undo() async {
        do {
            guard let undone = try await useCases.undoLastIntake.run() else { return }
            await refresh()
            await playUndo(delta: undone.amountMl)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func log(amount: Int, containerId: UUID?) async {
        let isFirstOfSeries = !seriesActive
        if isFirstOfSeries {
            seriesActive = true
            seriesID += 1
            addedMl = amount
            motion = .stream(deltaMl: amount)
        }
        let generation = seriesID
        do {
            _ = try await useCases.logIntake.run(
                amount: Milliliters(amount),
                source: .app,
                containerId: containerId
            )
            if !isFirstOfSeries {
                addedMl = (addedMl ?? 0) + amount
            }
            await refresh()
            scheduleAddMotion(
                generation: generation,
                confirming: amount,
                includesLeadIn: isFirstOfSeries
            )
        } catch {
            if isFirstOfSeries {
                motionTask?.cancel()
                seriesActive = false
                addedMl = nil
                motion = .idle
            }
            errorMessage = error.localizedDescription
        }
    }

    private func showConfirmation(amount: Int) {
        let formatter = VolumeFormatter.current
        if snapshot.isGoalMet {
            confirmation = L10n.inTheFlow
        } else {
            confirmation = L10n.confirmation(
                amount: formatter.string(milliliters: amount, unit: snapshot.unit)
            )
        }
        confirmationTask?.cancel()
        confirmationTask = Task {
            try? await Task.sleep(for: .seconds(RippleMotion.durationConfirm))
            guard !Task.isCancelled else { return }
            confirmation = nil
        }
    }

    private func scheduleAddMotion(
        generation: Int,
        confirming amount: Int,
        includesLeadIn: Bool
    ) {
        motionTask?.cancel()
        let seriesAmount = addedMl ?? amount
        motion = .pour(deltaMl: seriesAmount)
        let leadIn = includesLeadIn ? RippleMotion.pourLeadIn : 0
        let flowDuration = RippleMotion.pourDuration(for: seriesAmount)

        motionTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(leadIn + flowDuration))
            guard !Task.isCancelled, generation == seriesID else { return }
            motion = .ripple(deltaMl: seriesAmount)
            revealChrome(confirming: amount)

            try? await Task.sleep(for: .seconds(RippleMotion.durationHero))
            guard !Task.isCancelled, generation == seriesID else { return }
            motion = .settle(deltaMl: seriesAmount)
            presentedSnapshot = snapshot
            motion = .afterglow(deltaMl: seriesAmount)

            try? await Task.sleep(for: .seconds(RippleMotion.afterglowDuration))
            guard !Task.isCancelled, generation == seriesID else { return }
            motion = .idle
            seriesActive = false
            addedMl = nil
            presentedSnapshot = snapshot
            motionTask = nil
        }
    }

    private func revealChrome(confirming amount: Int) {
        presentedSnapshot = snapshot
        showConfirmation(amount: amount)
    }

    private func playUndo(delta: Int) async {
        seriesID += 1
        motionTask?.cancel()
        motionTask = nil
        seriesActive = false
        addedMl = nil
        presentedSnapshot = snapshot
        confirmation = nil
        motion = .undo(deltaMl: delta)
        try? await Task.sleep(for: .seconds(RippleMotion.undoDuration))
        motion = .idle
    }
}
