import SwiftUI

public struct ContainerChip: View {
    public var name: String
    public var amount: String
    public var symbolName: String
    public var action: () -> Void

    public init(name: String, amount: String, symbolName: String, action: @escaping () -> Void) {
        self.name = name
        self.amount = amount
        self.symbolName = symbolName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
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
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .rippleGlass(cornerRadius: RippleRadius.control)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name), \(amount)")
    }
}

#Preview("ContainerChip") {
    ContainerChip(name: "Glas", amount: "250 ml", symbolName: "cup.and.saucer.fill") {}
        .padding()
}
