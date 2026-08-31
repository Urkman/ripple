import Foundation

public protocol HealthProjecting: Sendable {
    func project(intake: Intake) async
    func retract(intakeID: UUID) async
}
