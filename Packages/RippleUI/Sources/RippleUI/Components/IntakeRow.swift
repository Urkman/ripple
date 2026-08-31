import SwiftUI

public struct IntakeRow: View {
    public var amount: String
    public var time: String
    public var source: String
    public var container: String?

    public init(amount: String, time: String, source: String, container: String? = nil) {
        self.amount = amount
        self.time = time
        self.source = source
        self.container = container
    }

    public var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundStyle(RippleColor.waterLagoon)
            VStack(alignment: .leading, spacing: 2) {
                Text(amount)
                    .font(.body.monospacedDigit().weight(.medium))
                if let container, !container.isEmpty {
                    Text(container)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(.callout.monospacedDigit())
                Text(source)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if let container, !container.isEmpty {
            return "\(amount), \(container), \(time), \(source)"
        }
        return "\(amount), \(time), \(source)"
    }
}
