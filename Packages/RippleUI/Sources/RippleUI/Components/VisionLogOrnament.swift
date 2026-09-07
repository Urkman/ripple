import SwiftUI

#if os(visionOS)
public struct VisionLogOrnament: View {
    public let items: [QuickAddItem]
    public let customTitle: String
    public let customAccessibilityLabel: String
    public let maxWidth: CGFloat?
    public let onSelect: (QuickAddItem) -> Void
    public let onCustom: () -> Void

    public init(
        items: [QuickAddItem],
        customTitle: String,
        customAccessibilityLabel: String,
        maxWidth: CGFloat? = nil,
        onSelect: @escaping (QuickAddItem) -> Void,
        onCustom: @escaping () -> Void
    ) {
        self.items = items
        self.customTitle = customTitle
        self.customAccessibilityLabel = customAccessibilityLabel
        self.maxWidth = maxWidth
        self.onSelect = onSelect
        self.onCustom = onCustom
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(items) { item in
                    VisionOrnamentButton(
                        title: item.name,
                        amount: item.amount,
                        symbolName: item.symbolName,
                        accessibilityLabel: "\(item.name), \(item.amount)"
                    ) {
                        onSelect(item)
                    }

                    VisionOrnamentDivider()
                }

                VisionOrnamentButton(
                    title: customTitle,
                    amount: nil,
                    symbolName: "plus",
                    accessibilityLabel: customAccessibilityLabel,
                    isEmphasized: true,
                    action: onCustom
                )
            }
        }
        .frame(maxWidth: maxWidth ?? .infinity)
        .padding(RippleSpace.xs)
        .background(.regularMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .stroke(RippleColor.glassHighlight.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct VisionOrnamentButton: View {
    let title: String
    let amount: String?
    let symbolName: String?
    let accessibilityLabel: String
    let isEmphasized: Bool
    let action: () -> Void

    init(
        title: String,
        amount: String?,
        symbolName: String?,
        accessibilityLabel: String,
        isEmphasized: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.amount = amount
        self.symbolName = symbolName
        self.accessibilityLabel = accessibilityLabel
        self.isEmphasized = isEmphasized
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: RippleSpace.xs) {
                if let symbolName {
                    Image(systemName: symbolName)
                        .font(RippleFont.caption)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(RippleFont.caption.weight(.semibold))
                        .lineLimit(1)
                    if let amount {
                        Text(amount)
                            .font(RippleFont.caption.monospacedDigit())
                            .opacity(0.72)
                            .lineLimit(1)
                    }
                }
            }
            .foregroundStyle(isEmphasized ? RippleColor.glassHighlight : RippleColor.waterDeep)
            .padding(.horizontal, RippleSpace.md)
            .frame(
                minWidth: RippleLayout.visionOrnamentTargetMinSize,
                minHeight: RippleLayout.visionOrnamentTargetMinSize
            )
            .background(
                isEmphasized
                    ? RippleColor.waterAqua.opacity(0.86)
                    : .clear,
                in: Capsule(style: .continuous)
            )
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct VisionOrnamentDivider: View {
    var body: some View {
        Rectangle()
            .fill(RippleColor.waterDeep.opacity(0.20))
            .frame(width: 1, height: 20)
            .accessibilityHidden(true)
    }
}
#endif
