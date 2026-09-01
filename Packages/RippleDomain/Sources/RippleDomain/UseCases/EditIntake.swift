import Foundation

public struct EditIntake: Sendable {
    private let intakeRepository: any IntakeRepository
    private let widgetReloading: any WidgetReloading
    private let health: any HealthProjecting

    public init(
        intakeRepository: any IntakeRepository,
        widgetReloading: any WidgetReloading,
        health: any HealthProjecting
    ) {
        self.intakeRepository = intakeRepository
        self.widgetReloading = widgetReloading
        self.health = health
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

        await widgetReloading.reload()
        await health.retract(intakeID: intake.id)
        await health.project(intake: intake)
    }
}
