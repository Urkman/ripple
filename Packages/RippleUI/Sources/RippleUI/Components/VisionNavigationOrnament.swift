import SwiftUI

#if os(visionOS)
public struct VisionNavigationItem: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let isSelected: Bool

    public init(
        id: String,
        title: String,
        systemImage: String,
        isSelected: Bool
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
    }
}

public struct VisionNavigationOrnament: View {
    public let items: [VisionNavigationItem]
    public let onSelect: (VisionNavigationItem) -> Void

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    public init(
        items: [VisionNavigationItem],
        onSelect: @escaping (VisionNavigationItem) -> Void
    ) {
        self.items = items
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: RippleSpace.xs) {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    Image(systemName: item.systemImage)
                        .font(RippleFont.callout.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(item.isSelected ? RippleColor.waterDeep : .primary)
                        .frame(
                            width: RippleLayout.visionOrnamentTargetMinSize,
                            height: RippleLayout.visionOrnamentTargetMinSize
                        )
                        .background(
                            item.isSelected
                                ? selectedBackground
                                : Color.clear,
                            in: RoundedRectangle(
                                cornerRadius: RippleRadius.control,
                                style: .continuous
                            )
                        )
                        .contentShape(
                            RoundedRectangle(
                                cornerRadius: RippleRadius.control,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
                .hoverEffect(.highlight)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(item.isSelected ? .isSelected : [])
            }
        }
        .padding(RippleSpace.xs)
        .background(
            .regularMaterial,
            in: RoundedRectangle(
                cornerRadius: RippleRadius.card,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: RippleRadius.card,
                style: .continuous
            )
            .stroke(RippleColor.glassHighlight.opacity(0.18), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var selectedBackground: Color {
        switch colorSchemeContrast {
        case .increased:
            RippleColor.waterAqua
        default:
            RippleColor.waterAqua.opacity(0.82)
        }
    }
}

#Preview("Vision Navigation · Light") {
    VisionNavigationOrnament(
        items: [
            VisionNavigationItem(id: "today", title: "Today", systemImage: "drop.fill", isSelected: true),
            VisionNavigationItem(id: "history", title: "History", systemImage: "calendar", isSelected: false),
            VisionNavigationItem(id: "stats", title: "Stats", systemImage: "chart.bar.xaxis", isSelected: false),
            VisionNavigationItem(id: "settings", title: "Settings", systemImage: "gearshape", isSelected: false),
        ],
        onSelect: { _ in }
    )
}

#Preview("Vision Navigation · Dark · XXXL") {
    VisionNavigationOrnament(
        items: [
            VisionNavigationItem(id: "today", title: "Today", systemImage: "drop.fill", isSelected: false),
            VisionNavigationItem(id: "history", title: "History", systemImage: "calendar", isSelected: true),
            VisionNavigationItem(id: "stats", title: "Stats", systemImage: "chart.bar.xaxis", isSelected: false),
            VisionNavigationItem(id: "settings", title: "Settings", systemImage: "gearshape", isSelected: false),
        ],
        onSelect: { _ in }
    )
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}
#endif
