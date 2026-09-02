import SwiftUI

@Animatable
public struct WatchWaterLevelShape: Shape {
    public var level: CGFloat
    public var wavePosition: CGFloat
    public var waveAmplitude: CGFloat

    public init(
        level: CGFloat,
        wavePosition: CGFloat = 0,
        waveAmplitude: CGFloat = 0
    ) {
        self.level = level
        self.wavePosition = wavePosition
        self.waveAmplitude = waveAmplitude
    }

    public func path(in rect: CGRect) -> Path {
        guard level > 0, rect.width > 0, rect.height > 0 else {
            return Path()
        }

        let cappedLevel = min(max(level, 0), RippleMotion.maxVisualLevel)
        let surfaceY = rect.maxY - rect.height * cappedLevel
        let sampleCount = RippleWatchLayout.waterSurfaceSampleCount
        var path = Path()

        for index in 0...sampleCount {
            let progress = CGFloat(index) / CGFloat(sampleCount)
            let x = rect.minX + rect.width * progress
            let y = min(
                surfaceY + surfaceWaveOffset(in: rect, x: x),
                rect.maxY
            )
            let point = CGPoint(x: x, y: y)

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    private func surfaceWaveOffset(in rect: CGRect, x: CGFloat) -> CGFloat {
        let amplitude = RippleMotion.waveAmplitude(
            requested: waveAmplitude,
            level: min(max(level, 0), RippleMotion.maxVisualLevel)
        )
        return RippleMotion.travellingSurfaceOffset(
            x: x,
            centerX: rect.midX,
            surfaceWidth: rect.width,
            position: wavePosition,
            amplitude: amplitude
        )
    }
}

@Animatable
public struct WatchWaterSurfaceShape: Shape {
    public var level: CGFloat
    public var wavePosition: CGFloat
    public var waveAmplitude: CGFloat

    public init(
        level: CGFloat,
        wavePosition: CGFloat = 0,
        waveAmplitude: CGFloat = 0
    ) {
        self.level = level
        self.wavePosition = wavePosition
        self.waveAmplitude = waveAmplitude
    }

    public func path(in rect: CGRect) -> Path {
        guard level > 0, rect.width > 0, rect.height > 0 else {
            return Path()
        }

        let cappedLevel = min(max(level, 0), RippleMotion.maxVisualLevel)
        let surfaceY = rect.maxY - rect.height * cappedLevel
        let sampleCount = RippleWatchLayout.waterSurfaceSampleCount
        var path = Path()

        for index in 0...sampleCount {
            let progress = CGFloat(index) / CGFloat(sampleCount)
            let x = rect.minX + rect.width * progress
            let y = min(
                surfaceY + surfaceWaveOffset(in: rect, x: x),
                rect.maxY
            )
            let point = CGPoint(x: x, y: y)

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func surfaceWaveOffset(in rect: CGRect, x: CGFloat) -> CGFloat {
        let amplitude = RippleMotion.waveAmplitude(
            requested: waveAmplitude,
            level: min(max(level, 0), RippleMotion.maxVisualLevel)
        )
        return RippleMotion.travellingSurfaceOffset(
            x: x,
            centerX: rect.midX,
            surfaceWidth: rect.width,
            position: wavePosition,
            amplitude: amplitude
        )
    }
}

private enum WatchWaterWavePhase: CaseIterable {
    case flat
    case outward
    case reflection
    case settled

    var position: CGFloat {
        switch self {
        case .flat:
            0
        case .outward:
            RippleMotion.watchWaveOutPosition
        case .reflection:
            RippleMotion.watchWaveReflectionPosition
        case .settled:
            RippleMotion.watchWaveSettlePosition
        }
    }

    var amplitude: CGFloat {
        switch self {
        case .flat, .settled:
            0
        case .outward:
            RippleMotion.watchWaveAmplitude
        case .reflection:
            RippleMotion.watchWaveReflectionAmplitude
        }
    }

    var animation: Animation {
        switch self {
        case .flat:
            .linear(duration: 0)
        case .outward:
            .easeOut(duration: RippleMotion.rippleOutboundDuration)
        case .reflection:
            .easeInOut(duration: RippleMotion.rippleReflectionDuration)
        case .settled:
            .easeOut(duration: RippleMotion.rippleSettleDuration)
        }
    }
}

public struct WatchWaterBackdrop: View {
    public var level: CGFloat
    public var motionTrigger: Int
    public var motionEnabled: Bool

    public init(
        level: CGFloat,
        motionTrigger: Int = 0,
        motionEnabled: Bool = true
    ) {
        self.level = level
        self.motionTrigger = motionTrigger
        self.motionEnabled = motionEnabled
    }

    public var body: some View {
        GeometryReader { proxy in
            if motionEnabled {
                PhaseAnimator(
                    WatchWaterWavePhase.allCases,
                    trigger: motionTrigger
                ) { phase in
                    waterLayer(level: level, phase: phase)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } animation: { phase in
                    phase.animation
                }
            } else {
                waterLayer(level: level, phase: .flat)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private func waterLayer(
        level: CGFloat,
        phase: WatchWaterWavePhase
    ) -> some View {
        ZStack {
            RippleColor.watchSurface

            WatchWaterLevelShape(
                level: level,
                wavePosition: phase.position,
                waveAmplitude: phase.amplitude
            )
            .fill(RippleColor.watchAqua.opacity(0.88))

            WatchWaterSurfaceShape(
                level: level,
                wavePosition: phase.position,
                waveAmplitude: phase.amplitude
            )
            .stroke(RippleColor.watchLagoon.opacity(0.92), lineWidth: 1)
        }
    }
}

#Preview("Watch Water") {
    WatchWaterBackdrop(level: 0.52)
        .frame(width: 184, height: 224)
}

#Preview("Watch Water · Wrist Motion") {
    WatchWaterBackdrop(level: 0.52, motionTrigger: 1)
        .frame(width: 184, height: 224)
}

#Preview("Watch Water · Dark · Reduce Motion") {
    WatchWaterBackdrop(level: 0.52, motionEnabled: false)
        .frame(width: 184, height: 224)
        .preferredColorScheme(.dark)
}
