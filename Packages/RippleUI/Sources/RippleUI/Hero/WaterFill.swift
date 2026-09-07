import SwiftUI

@Animatable
struct WaterFillShape: Shape {
    var level: CGFloat
    var pourDepth: CGFloat
    var ripplePosition: CGFloat
    var rippleAmplitude: CGFloat
    @AnimatableIgnored var tilt: CGFloat
    @AnimatableIgnored var slosh: CGFloat = 0
    @AnimatableIgnored var thickness: CGFloat
    @AnimatableIgnored var inset: CGFloat = GlassMetrics.strokeWidth

    func path(in rect: CGRect) -> Path {
        WaterSurfaceGeometry(
            metrics: GlassMetrics(in: rect, inset: inset), level: level, tilt: tilt,
            slosh: slosh, pourDepth: pourDepth, ripplePosition: ripplePosition,
            rippleAmplitude: rippleAmplitude, thickness: thickness
        ).path
    }
}

public struct WaterFill: View {
    public var level: CGFloat
    public var tilt: CGFloat
    public var slosh: CGFloat
    public var pourDepth: CGFloat
    public var ripplePosition: CGFloat
    public var rippleAmplitude: CGFloat

    public init(
        level: CGFloat,
        tilt: CGFloat,
        slosh: CGFloat = 0,
        pourDepth: CGFloat = 0,
        ripplePosition: CGFloat = 0,
        rippleAmplitude: CGFloat = 0
    ) {
        self.level = level
        self.tilt = tilt
        self.slosh = slosh
        self.pourDepth = pourDepth
        self.ripplePosition = ripplePosition
        self.rippleAmplitude = rippleAmplitude
    }

    public var body: some View {
        ZStack {
            WaterFillShape(
                level: level,
                pourDepth: pourDepth,
                ripplePosition: ripplePosition,
                rippleAmplitude: rippleAmplitude,
                tilt: tilt,
                slosh: slosh,
                thickness: 3
            )
            .fill(RippleColor.waterAqua.opacity(0.50))
            WaterFillShape(
                level: level,
                pourDepth: pourDepth,
                ripplePosition: ripplePosition,
                rippleAmplitude: rippleAmplitude,
                tilt: tilt,
                slosh: slosh,
                thickness: 0
            )
            .fill(RippleColor.waterAqua.opacity(0.88))
        }
        .clipShape(GlassShape(inset: GlassMetrics.strokeWidth))
        .accessibilityHidden(true)
    }
}

#Preview("Slosh · Light") {
    WaterFill(level: 0.3, tilt: -.pi / 4, slosh: 0.06)
        .overlay { GlassShape().stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth) }
        .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
        .background(RippleColor.waterFoam)
}

#Preview("Slosh · Dark XXXL") {
    WaterFill(level: 0.3, tilt: -.pi / 3, slosh: -0.04)
        .overlay { GlassShape().stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth) }
        .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
        .background(RippleColor.waterFoam)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Water · Reduce Motion") {
    WaterFill(level: 0.3, tilt: 0)
        .overlay { GlassShape().stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth) }
        .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
        .background(RippleColor.waterFoam)
}
