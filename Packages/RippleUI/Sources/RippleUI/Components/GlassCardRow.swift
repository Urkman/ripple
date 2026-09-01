import SwiftUI

public struct GlassCardRow<Content: View>: View {
    private let title: String
    private let showsDivider: Bool
    private let content: Content

    public init(
        _ title: String,
        showsDivider: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showsDivider = showsDivider
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .center, spacing: RippleSpace.lg) {
            Text(title)
                .font(RippleFont.body)
                .foregroundStyle(RippleColor.waterDeep)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: RippleSpace.sm)
            content
        }
        .padding(.vertical, RippleSpace.md)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(RippleColor.waterDeep.opacity(0.10))
                    .frame(height: 1)
            }
        }
    }
}

#Preview("GlassCardRow · Light") {
    GlassCard {
        VStack(spacing: 0) {
            GlassCardRow("Units") {
                Text(verbatim: "ml")
                    .foregroundStyle(RippleColor.waterLagoon)
            }
            GlassCardRow("Haptics", showsDivider: false) {
                Toggle("Haptics", isOn: .constant(true))
                    .labelsHidden()
            }
        }
    }
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("GlassCardRow · Dark · XXXL") {
    GlassCard {
        GlassCardRow("Daily goal", showsDivider: false) {
            Text(verbatim: "2 000 ml")
                .font(RippleFont.body.monospacedDigit())
                .foregroundStyle(RippleColor.waterDeep)
        }
    }
    .padding()
    .background(RippleColor.waterFoam)
    .environment(\.colorScheme, .dark)
    .environment(\.dynamicTypeSize, .xxxLarge)
}
