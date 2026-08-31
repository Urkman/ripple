import Foundation

public struct EditIntake: Sendable {
    private let intakeRepository: any IntakeRepository
    private let widgetReloading: any WidgetReloading
    private let liveActivity: any LiveActivityControlling
    private let health: any HealthProjecting
    private let observeToday: ObserveToday

    public init(
        intakeRepository: any IntakeRepository,
        widgetReloading: any WidgetReloading,
        liveActivity: any LiveActivityControlling,
        health: any HealthProjecting,
        observeToday: ObserveToday
    ) {
        self.intakeRepository = intakeRepository
        self.widgetReloading = widgetReloading
        self.liveActivity = liveActivity
        self.health = health
        self.observeToday = observeToday
    }

    public func run(
        id: UUID,
        amountMl: Int,
        date: Date,
        containerId: UUID? = nil,
        updateContainer: Bool = false
    ) async throws {
        guard var intake = try await intakeRepository.intake(id: id), !intake.isDeleted else {
            return
        }
        intake.amountMl = max(amountMl, 0)
        intake.date = date
        if updateContainer {
            intake.containerId = containerId
        }
        intake.updatedAt = Date()
        try await intakeRepository.update(intake)

        let snapshot = (try? await observeToday.snapshot(for: intake.date)) ?? .empty(date: intake.date)
        await widgetReloading.reload()
        await liveActivity.startOrUpdate(snapshot)
        await health.retract(intakeID: intake.id)
        await health.project(intake: intake)
    }
}
