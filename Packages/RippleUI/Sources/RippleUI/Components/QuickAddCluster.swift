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
    public enum Layout: Sendable, Equatable {
        case horizontal
        case vertical
    }

    public var items: [QuickAddItem]
    public var layout: Layout
    public var style: ContainerChip.Style
    public var onSelect: (QuickAddItem) -> Void

    public init(
        items: [QuickAddItem],
        layout: Layout = .horizontal,
        style: ContainerChip.Style = .glass,
        onSelect: @escaping (QuickAddItem) -> Void
    ) {
        self.items = items
        self.layout = layout
        self.style = style
        self.onSelect = onSelect
    }

    public var body: some View {
        Group {
            switch layout {
            case .horizontal:
                HStack(spacing: RippleSpace.sm) {
                    chips
                }
                .frame(maxWidth: .infinity)
            case .vertical:
                VStack(spacing: RippleSpace.sm) {
                    chips
                }
            }
        }
    }

    @ViewBuilder
    private var chips: some View {
        ForEach(items) { item in
            ContainerChip(
                name: item.name,
                amount: item.amount,
                symbolName: item.symbolName,
                style: style
            ) {
                onSelect(item)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
