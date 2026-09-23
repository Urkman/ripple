import SwiftUI

public struct ContainerChip: View {
    public enum Style: Sendable {
        case glass
        case flat
    }

    public var name: String
    public var amount: String
    public var symbolName: String
    public var style: Style
    public var isSelected: Bool
    public var action: () -> Void

    public init(
        name: String,
        amount: String,
        symbolName: String,
        style: Style = .glass,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.amount = amount
        self.symbolName = symbolName
        self.style = style
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(amount)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var label: some View {
        let content = HStack(spacing: RippleSpace.sm) {
            Image(systemName: symbolName)
                .font(RippleFont.symbol)
                .foregroundStyle(RippleColor.waterLagoon)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(RippleFont.subheadlineMedium)
                Text(amount)
                    .font(RippleFont.captionNumeric)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, RippleSpace.sm)
        .padding(.vertical, RippleSpace.md)

        switch style {
        case .glass:
            content
                .rippleGlass(cornerRadius: RippleRadius.control)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: RippleRadius.control,
                        style: .continuous
                    )
                    .stroke(
                        isSelected ? RippleColor.waterLagoon : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
                }
        case .flat:
            content
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(RippleColor.waterLagoon.opacity(0.18))
                        .frame(height: RippleStroke.standard)
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: RippleRadius.control,
                        style: .continuous
                    )
                    .stroke(
                        isSelected ? RippleColor.waterLagoon : .clear,
                        lineWidth: isSelected ? 2 : 0
                    )
                }
        }
    }
}

#Preview("ContainerChip") {
    ContainerChip(name: "Glas", amount: "250 ml", symbolName: "cup.and.saucer.fill") {}
        .padding()
}

#Preview("ContainerChip · Flat") {
    ContainerChip(
        name: "Glas",
        amount: "250 ml",
        symbolName: "cup.and.saucer.fill",
        style: .flat
    ) {}
    .padding()
}
