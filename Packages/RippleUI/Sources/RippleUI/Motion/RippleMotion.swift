import SwiftUI

public enum RippleMotion {
    public static let durationQuick: TimeInterval = 0.28
    public static let durationHero: TimeInterval = 0.90
    public static let durationConfirm: TimeInterval = 1.30
    public static let confirmFade: TimeInterval = 0.30
    public static let undoDuration: TimeInterval = 0.45
    public static let reduceMotionCrossfade: TimeInterval = 0.20
    public static let afterglowDuration: TimeInterval = 1.30

    public static let watchMotionUpdateInterval: TimeInterval = 1.0 / 30.0
    public static let watchMotionAccelerationThreshold: Double = 0.12
    public static let watchMotionRotationThreshold: Double = 1.0
    public static let watchMotionCooldown: TimeInterval = 0.24
    public static let watchWaveAmplitude: CGFloat = 5
    public static let watchWaveReflectionAmplitude: CGFloat = 1.8
    public static let watchWaveOutPosition: CGFloat = 0.46
    public static let watchWaveReflectionPosition: CGFloat = 0.24
    public static let watchWaveSettlePosition: CGFloat = 0.12

    public static let pourLeadIn: TimeInterval = 0.14
    public static let pourFadeOut: TimeInterval = 0.14
    public static let pourClockStep: TimeInterval = 1.0 / 60.0
    public static let pourDepthFadeOut: TimeInterval = 0.16
    public static let pourStartAboveGlass: CGFloat = 32
    public static let pourExitScale: CGFloat = 0.35

    public static let rippleOutboundDuration: TimeInterval = 0.38
    public static let rippleReflectionDuration: TimeInterval = 0.28
    public static let rippleTurnDuration: TimeInterval = 0.06
    public static let rippleReturnDuration: TimeInterval = 0.22
    public static let rippleSettleDuration: TimeInterval = 0.24
    public static let rippleReflectionRatio: CGFloat = 0.36
    static let rippleReturnDecay: CGFloat = 0.55
    static let rippleStartPosition: CGFloat = 0.06
    static let rippleOutboundPosition: CGFloat = 0.46
    static let rippleReflectionPosition: CGFloat = 0.24
    static let rippleSettlePosition: CGFloat = 0.12

    public static let maxTiltDegrees: CGFloat = 16
    public static let tiltGravityCap: CGFloat = 0.55
    public static let tiltLowPass: CGFloat = 0.18
    public static let faceUpGravityZ: Double = 0.92
    public static let shallowLevel: CGFloat = 0.15
    public static let shallowAmplitudeCap: CGFloat = 4
    public static let maxVisualLevel: CGFloat = 1.05
    public static let heroWidth: CGFloat = 200
    public static let heroHeight: CGFloat = 280

    public static let amountMinMl: CGFloat = 50
    public static let amountMaxMl: CGFloat = 750
    public static let pourMinWidth: CGFloat = 7
    public static let pourMaxWidth: CGFloat = 12
    public static let pourMinDuration: TimeInterval = 0.40
    public static let pourMaxDuration: TimeInterval = 0.70
    public static let pourMinDepth: CGFloat = 5
    public static let pourMaxDepth: CGFloat = 9
    public static let rippleMinAmplitude: CGFloat = 4
    public static let rippleMaxAmplitude: CGFloat = 7

    static let contactCenterWidthRatio: CGFloat = 0.10
    static let contactShoulderPositionRatio: CGFloat = 0.18
    static let contactShoulderWidthRatio: CGFloat = 0.07
    static let contactShoulderStrength: CGFloat = 0.30
    static let rippleCrestWidthRatio: CGFloat = 0.055
    static let rippleTrailingDistanceRatio: CGFloat = 0.10
    static let rippleTrailingStrength: CGFloat = 0.42

    public static var springSnappy: Animation {
        .spring(response: 0.28, dampingFraction: 0.85)
    }

    public static var springLiquid: Animation {
        .spring(response: 0.55, dampingFraction: 0.72)
    }

    public static func amountT(for addedMl: Int) -> CGFloat {
        let t = (CGFloat(addedMl) - amountMinMl) / (amountMaxMl - amountMinMl)
        return min(1, max(0, t))
    }

    public static func pourWidth(for addedMl: Int) -> CGFloat {
        pourMinWidth + (pourMaxWidth - pourMinWidth) * amountT(for: addedMl)
    }

    public static func pourDuration(for addedMl: Int) -> TimeInterval {
        pourMinDuration
            + (pourMaxDuration - pourMinDuration) * Double(amountT(for: addedMl))
    }

    static func levelRiseDuration(for addedMl: Int) -> TimeInterval {
        pourDuration(for: addedMl) + pourFadeOut
    }

    static func pourProgress(
        elapsed: TimeInterval,
        duration: TimeInterval
    ) -> CGFloat {
        guard duration > 0 else { return elapsed > 0 ? 1 : 0 }
        return min(max(CGFloat(elapsed / duration), 0), 1)
    }

    static func pourLevel(
        start: CGFloat,
        target: CGFloat,
        progress: CGFloat
    ) -> CGFloat {
        let clampedProgress = min(max(progress, 0), 1)
        return start + (target - start) * clampedProgress
    }

    static func pourFadeProgress(
        progress: CGFloat,
        activeDuration: TimeInterval,
        totalDuration: TimeInterval
    ) -> CGFloat {
        guard totalDuration > activeDuration else {
            return progress >= 1 ? 1 : 0
        }
        let clampedProgress = min(max(progress, 0), 1)
        let activeFraction = CGFloat(activeDuration / totalDuration)
        guard clampedProgress > activeFraction else { return 0 }
        return min(
            max(
                (clampedProgress - activeFraction)
                    / (1 - activeFraction),
                0
            ),
            1
        )
    }

    public static func pourDepth(for addedMl: Int) -> CGFloat {
        pourMinDepth + (pourMaxDepth - pourMinDepth) * amountT(for: addedMl)
    }

    public static func rippleAmplitude(for addedMl: Int) -> CGFloat {
        rippleMinAmplitude
            + (rippleMaxAmplitude - rippleMinAmplitude) * amountT(for: addedMl)
    }

    static func pourSurfaceOffset(
        x: CGFloat,
        centerX: CGFloat,
        surfaceWidth: CGFloat,
        depth: CGFloat
    ) -> CGFloat {
        guard surfaceWidth > 0, depth > 0 else { return 0 }
        let normalizedX = (x - centerX) / surfaceWidth
        let center = gaussian(normalizedX / contactCenterWidthRatio)
        let leftShoulder = gaussian(
            (normalizedX + contactShoulderPositionRatio) / contactShoulderWidthRatio
        )
        let rightShoulder = gaussian(
            (normalizedX - contactShoulderPositionRatio) / contactShoulderWidthRatio
        )
        return depth * (
            center - contactShoulderStrength * (leftShoulder + rightShoulder)
        )
    }

    static func travellingSurfaceOffset(
        x: CGFloat,
        centerX: CGFloat,
        surfaceWidth: CGFloat,
        position: CGFloat,
        amplitude: CGFloat
    ) -> CGFloat {
        guard surfaceWidth > 0, amplitude != 0 else { return 0 }
        let radialDistance = abs(x - centerX) / surfaceWidth
        let clampedPosition = min(max(position, 0), 0.50)
        let crest = gaussian(
            (radialDistance - clampedPosition) / rippleCrestWidthRatio
        )
        let trailingPosition = max(
            clampedPosition - rippleTrailingDistanceRatio,
            0
        )
        let trailing = gaussian(
            (radialDistance - trailingPosition) / rippleCrestWidthRatio
        )
        return amplitude * (-crest + rippleTrailingStrength * trailing)
    }

    private static func gaussian(_ value: CGFloat) -> CGFloat {
        exp(-0.5 * value * value)
    }

    public static func fillLevel(consumedMl: Int, goalMl: Int) -> CGFloat {
        guard goalMl > 0 else { return 0 }
        return min(CGFloat(consumedMl) / CGFloat(goalMl), maxVisualLevel)
    }

    public static func waveAmplitude(requested: CGFloat, level: CGFloat) -> CGFloat {
        if level < shallowLevel {
            return min(requested, shallowAmplitudeCap)
        }
        return requested
    }

    public static var maxTiltRadians: CGFloat {
        maxTiltDegrees * .pi / 180
    }

    public static func tiltTarget(gravityX: Double, gravityZ: Double) -> CGFloat {
        if abs(gravityZ) > faceUpGravityZ { return 0 }
        let raw = min(max(CGFloat(gravityX), -tiltGravityCap), tiltGravityCap)
        return (raw / tiltGravityCap) * maxTiltRadians
    }

    public static func lowPass(current: CGFloat, target: CGFloat) -> CGFloat {
        current + (target - current) * tiltLowPass
    }
}

public enum RippleMotionPhase: Equatable, Sendable {
    case idle
    case stream(deltaMl: Int)
    case pour(deltaMl: Int)
    case ripple(deltaMl: Int)
    case settle(deltaMl: Int)
    case afterglow(deltaMl: Int)
    case undo(deltaMl: Int)

    public var deltaMl: Int {
        switch self {
        case .idle:
            0
        case .stream(let delta),
             .pour(let delta),
             .ripple(let delta),
             .settle(let delta),
             .afterglow(let delta),
             .undo(let delta):
            delta
        }
    }

    public var isAnimating: Bool {
        self != .idle
    }

    public var usesAddAmplitude: Bool {
        switch self {
        case .stream, .pour, .ripple:
            true
        default:
            false
        }
    }

    public var showsPour: Bool {
        switch self {
        case .stream, .pour:
            true
        default:
            false
        }
    }

    public var isUndo: Bool {
        if case .undo = self { return true }
        return false
    }
}
