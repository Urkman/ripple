import SwiftUI

public struct QuickAddItem: Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var amount: String
    public var symbolName: String

    public init(id: UUID, name: String, amount: String, symbolName: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.symbolName = symbolName
    }
}

public struct QuickAddCluster: View {
    public var items: [QuickAddItem]
    public var onSelect: (QuickAddItem) -> Void

    public init(items: [QuickAddItem], onSelect: @escaping (QuickAddItem) -> Void) {
        self.items = items
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                ContainerChip(
                    name: item.name,
                    amount: item.amount,
                    symbolName: item.symbolName
                ) {
                    onSelect(item)
                }
            }
        }
    }
}
