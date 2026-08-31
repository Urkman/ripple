import SwiftUI

@Animatable
struct WaterFillShape: Shape {
    var level: CGFloat
    var pourDepth: CGFloat
    var ripplePosition: CGFloat
    var rippleAmplitude: CGFloat
    @AnimatableIgnored var tilt: CGFloat
    @AnimatableIgnored var thickness: CGFloat
    @AnimatableIgnored var inset: CGFloat = GlassMetrics.strokeWidth

    func path(in rect: CGRect) -> Path {
        guard level > 0 else { return Path() }

        let metrics = GlassMetrics(in: rect, inset: inset)
        let levelY = min(metrics.y(forLevel: level) + thickness, metrics.bottomY)
        let surface = metrics.clampedSurface(levelY: levelY, tilt: tilt)
        let depth = RippleMotion.waveAmplitude(requested: pourDepth, level: level)
        let rippleMagnitude = RippleMotion.waveAmplitude(
            requested: abs(rippleAmplitude),
            level: level
        )
        let signedRippleAmplitude = rippleAmplitude < 0
            ? -rippleMagnitude
            : rippleMagnitude
        let width = max(surface.right.x - surface.left.x, 1)
        let isDisturbed = depth > 0.05 || abs(signedRippleAmplitude) > 0.05
        let steps = isDisturbed ? max(Int(width / 3), 12) : 1

        var path = Path()
        for index in 0...steps {
            let t = CGFloat(index) / CGFloat(steps)
            let x = surface.left.x + width * t
            let baseY = surface.left.y + (surface.right.y - surface.left.y) * t
            let contactOffset = RippleMotion.pourSurfaceOffset(
                x: x,
                centerX: metrics.centerX,
                surfaceWidth: width,
                depth: depth
            )
            let rippleOffset = RippleMotion.travellingSurfaceOffset(
                x: x,
                centerX: metrics.centerX,
                surfaceWidth: width,
                position: ripplePosition,
                amplitude: signedRippleAmplitude
            )
            let y = baseY + contactOffset + rippleOffset
            let point = CGPoint(
                x: x,
                y: min(max(y, metrics.rimBottomY), metrics.bottomY)
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.addLine(
            to: CGPoint(x: metrics.xMax(atY: metrics.bottomY), y: metrics.bottomY)
        )
        path.addLine(
            to: CGPoint(x: metrics.xMin(atY: metrics.bottomY), y: metrics.bottomY)
        )
        path.closeSubpath()
        return path
    }
}

public struct WaterFill: View {
    public var level: CGFloat
    public var tilt: CGFloat
    public var pourDepth: CGFloat
    public var ripplePosition: CGFloat
    public var rippleAmplitude: CGFloat

    public init(
        level: CGFloat,
        tilt: CGFloat,
        pourDepth: CGFloat = 0,
        ripplePosition: CGFloat = 0,
        rippleAmplitude: CGFloat = 0
    ) {
        self.level = level
        self.tilt = tilt
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
                thickness: 3
            )
            .fill(RippleColor.waterAqua.opacity(0.50))
            WaterFillShape(
                level: level,
                pourDepth: pourDepth,
                ripplePosition: ripplePosition,
                rippleAmplitude: rippleAmplitude,
                tilt: tilt,
                thickness: 0
            )
            .fill(RippleColor.waterAqua.opacity(0.88))
        }
        .clipShape(GlassShape(inset: GlassMetrics.strokeWidth))
        .accessibilityHidden(true)
    }
}
