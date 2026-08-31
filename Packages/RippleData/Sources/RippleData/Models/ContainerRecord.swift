import Foundation
import SwiftData

@Model
public final class ContainerRecord {
    public var id: UUID = UUID()
    public var name: String = "Glass"
    public var amountMl: Int = 250
    public var isDefault: Bool = false
    public var sort: Int = 0
    public var symbolName: String = "drop.fill"
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    public init(
        id: UUID = UUID(),
        name: String = "Glass",
        amountMl: Int = 250,
        isDefault: Bool = false,
        sort: Int = 0,
        symbolName: String = "drop.fill",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.amountMl = amountMl
        self.isDefault = isDefault
        self.sort = sort
        self.symbolName = symbolName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
