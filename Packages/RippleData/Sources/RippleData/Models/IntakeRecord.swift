import Foundation
import SwiftData

@Model
public final class IntakeRecord {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var amountMl: Int = 0
    public var beverageRaw: String = "water"
    public var sourceRaw: String = "app"
    public var containerId: UUID?
    public var note: String?
    public var isDeleted: Bool = false
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        amountMl: Int = 0,
        beverageRaw: String = "water",
        sourceRaw: String = "app",
        containerId: UUID? = nil,
        note: String? = nil,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.amountMl = amountMl
        self.beverageRaw = beverageRaw
        self.sourceRaw = sourceRaw
        self.containerId = containerId
        self.note = note
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
