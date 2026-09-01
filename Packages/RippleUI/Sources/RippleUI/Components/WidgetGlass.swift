import SwiftUI

/// A compact, static version of Ripple's glass for widgets and system surfaces.
/// It intentionally has no readout, tilt, stream, or surface response.
public struct WidgetGlass: View {
    public var level: CGFloat

    public init(consumedMl: Int, goalMl: Int) {
        self.level = RippleMotion.fillLevel(consumedMl: consumedMl, goalMl: goalMl)
    }

    public init(level: CGFloat) {
        self.level = level
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                WaterFill(level: level, tilt: 0)
                    .frame(width: proxy.size.width, height: proxy.size.height)

                GlassShape()
                    .stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth)
            }
        }
        .aspectRatio(RippleMotion.heroWidth / RippleMotion.heroHeight, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview("Widget glass · Light") {
    WidgetGlass(consumedMl: 1250, goalMl: 2000)
        .frame(width: 80)
        .padding()
        .background(RippleColor.waterFoam)
}

#Preview("Widget glass · Dark") {
    WidgetGlass(consumedMl: 1250, goalMl: 2000)
        .frame(width: 80)
        .padding()
        .background(RippleColor.surface)
        .preferredColorScheme(.dark)
}

#Preview("Widget glass · XXXL") {
    WidgetGlass(consumedMl: 1250, goalMl: 2000)
        .frame(width: 80)
        .dynamicTypeSize(.accessibility3)
        .padding()
        .background(RippleColor.waterFoam)
}

#Preview("Widget glass · Reduce Motion") {
    WidgetGlass(consumedMl: 1250, goalMl: 2000)
        .frame(width: 80)
        .padding()
        .background(RippleColor.waterFoam)
}
