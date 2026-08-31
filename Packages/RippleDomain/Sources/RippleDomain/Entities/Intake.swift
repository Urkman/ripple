import Foundation

public struct Intake: Sendable, Hashable, Codable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    public var amountMl: Int
    public var beverage: Beverage
    public var source: IntakeSource
    public var containerId: UUID?
    public var note: String?
    public var isDeleted: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        date: Date,
        amountMl: Int,
        beverage: Beverage = .water,
        source: IntakeSource,
        containerId: UUID? = nil,
        note: String? = nil,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.amountMl = amountMl
        self.beverage = beverage
        self.source = source
        self.containerId = containerId
        self.note = note
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var amount: Milliliters {
        Milliliters(amountMl)
    }
}
