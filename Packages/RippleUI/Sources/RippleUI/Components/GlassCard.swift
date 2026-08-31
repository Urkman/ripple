import SwiftUI

public struct GlassCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
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
    GlassCard {
        Text("Ripple")
    }
    .padding()
}
