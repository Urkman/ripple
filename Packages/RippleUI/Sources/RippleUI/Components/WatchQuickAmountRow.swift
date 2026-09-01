import SwiftUI

public struct WatchAmountOption: Identifiable, Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case predefined(UUID)
        case custom
    }

    public let id: String
    public let title: String
    public let subtitle: String
    public let kind: Kind
    public let accessibilityLabel: String?
    public let accessibilityValue: String?

    public init(
        id: String,
        title: String,
        subtitle: String,
        kind: Kind,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.kind = kind
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
    }
}

public struct WatchQuickAmountRow: View {
    public var options: [WatchAmountOption]
    public var selectedID: String?
    public var onSelect: (WatchAmountOption) -> Void

    public init(
        options: [WatchAmountOption],
        selectedID: String?,
        onSelect: @escaping (WatchAmountOption) -> Void
    ) {
        self.options = options
        self.selectedID = selectedID
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: RippleWatchLayout.quickOptionSpacing) {
            ForEach(options) { option in
                let isSelected = selectedID == option.id
                Button {
                    onSelect(option)
                } label: {
                    VStack(spacing: RippleSpace.grid) {
                        Text(option.title)
                            .font(RippleFont.caption.weight(.semibold).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                        if !option.subtitle.isEmpty {
                            Text(option.subtitle)
                                .font(RippleFont.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.45)
                        }
                    }
                }
                .buttonStyle(WatchQuickAmountButtonStyle(isSelected: isSelected))
                .accessibilityLabel(option.accessibilityLabel ?? option.title)
                .accessibilityValue(option.accessibilityValue ?? option.subtitle)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .animation(RippleMotion.springSnappy, value: selectedID)
    }
}

private struct WatchQuickAmountButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: RippleWatchLayout.controlHeight)
            .padding(.horizontal, RippleSpace.xs)
            .foregroundStyle(isSelected ? Color.white : RippleColor.waterDeep)
            .background(
                RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous)
                    .fill(isSelected ? RippleColor.waterLagoon : RippleColor.surface.opacity(0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous)
                    .stroke(
                        isSelected ? RippleColor.waterAqua : RippleColor.waterDeep.opacity(0.14),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(RippleMotion.springSnappy, value: configuration.isPressed)
    }
}

#Preview("Watch Quick Amounts") {
    WatchQuickAmountRow(
        options: [
            WatchAmountOption(id: "glass", title: "Glass", subtitle: "250 ml", kind: .predefined(UUID())),
            WatchAmountOption(id: "cup", title: "Cup", subtitle: "200 ml", kind: .predefined(UUID())),
            WatchAmountOption(id: "custom", title: "Custom", subtitle: "+", kind: .custom),
        ],
        selectedID: "glass",
        onSelect: { _ in }
    )
    .padding()
}

#Preview("Watch Quick Amounts · Dark · XXXL") {
    WatchQuickAmountRow(
        options: [
            WatchAmountOption(id: "glass", title: "Glass", subtitle: "250 ml", kind: .predefined(UUID())),
            WatchAmountOption(id: "cup", title: "Cup", subtitle: "200 ml", kind: .predefined(UUID())),
            WatchAmountOption(id: "bottle", title: "Bottle", subtitle: "500 ml", kind: .predefined(UUID())),
            WatchAmountOption(id: "custom", title: "Custom", subtitle: "+", kind: .custom),
        ],
        selectedID: "custom",
        onSelect: { _ in }
    )
    .padding()
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}
