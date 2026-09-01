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
    public var action: () -> Void

    public init(
        name: String,
        amount: String,
        symbolName: String,
        style: Style = .glass,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.amount = amount
        self.symbolName = symbolName
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(amount)")
    }

    @ViewBuilder
    private var label: some View {
        let content = HStack(spacing: RippleSpace.sm) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundStyle(RippleColor.waterLagoon)
                .symbolRenderingMode(.hierarchical)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.subheadline.weight(.medium))
                Text(amount)
                    .font(.caption.monospacedDigit())
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
        case .flat:
            content
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(RippleColor.waterLagoon.opacity(0.18))
                        .frame(height: 1)
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
