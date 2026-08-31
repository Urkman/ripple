import Foundation

public struct Container: Sendable, Hashable, Codable, Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var amountMl: Int
    public var isDefault: Bool
    public var sort: Int
    public var symbolName: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        amountMl: Int,
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

    public var amount: Milliliters {
        Milliliters(amountMl)
    }

    public static func seededDefaults(locale: Locale = .current) -> [Container] {
        let usesGerman = locale.language.languageCode?.identifier == "de"
        return [
            Container(
                name: usesGerman ? "Glas" : "Glass",
                amountMl: 250,
                isDefault: true,
                sort: 0,
                symbolName: "cup.and.saucer.fill"
            ),
            Container(
                name: usesGerman ? "Tasse" : "Cup",
                amountMl: 200,
                isDefault: false,
                sort: 1,
                symbolName: "mug.fill"
            ),
            Container(
                name: usesGerman ? "Flasche" : "Bottle",
                amountMl: 500,
                isDefault: false,
                sort: 2,
                symbolName: "waterbottle.fill"
            ),
        ]
    }
}
