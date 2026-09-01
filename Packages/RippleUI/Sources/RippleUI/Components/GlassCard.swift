import SwiftUI

public struct GlassCard<Content: View>: View {
    private let title: String?
    private let content: Content

    public init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: title == nil ? 0 : RippleSpace.md) {
            if let title {
                Text(title)
                    .font(RippleFont.callout.weight(.semibold))
                    .foregroundStyle(RippleColor.waterDeep)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            content
        }
            .padding(RippleSpace.lg)
            .rippleGlass(cornerRadius: RippleRadius.card)
    }
}

public extension View {
    func rippleGlass(cornerRadius: CGFloat) -> some View {
        #if os(iOS) || os(macOS) || os(visionOS)
        self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        #else
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
}

#Preview("GlassCard") {
    GlassCard(title: "Profile") {
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

#Preview("GlassCard dark XXXL") {
    GlassCard(title: "Daily goal") {
        Text(verbatim: "2 000 ml")
            .font(RippleFont.title.monospacedDigit())
            .foregroundStyle(RippleColor.waterDeep)
    }
    .padding()
    .background(RippleColor.waterFoam)
    .environment(\.colorScheme, .dark)
    .environment(\.dynamicTypeSize, .xxxLarge)
}
