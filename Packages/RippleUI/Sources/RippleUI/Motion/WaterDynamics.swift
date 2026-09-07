import Foundation

/// A driven, damped response. Constant gravity supplies no ongoing wave energy.
struct WaterDynamics: Sendable {
    private(set) var tilt: CGFloat = 0
    private(set) var slosh: CGFloat = 0
    private var angularVelocity: CGFloat = 0
    private var sloshVelocity: CGFloat = 0
    private var previousTarget: CGFloat?

    mutating func reset() { self = WaterDynamics() }

    /// A new screen orientation changes coordinates, not the water's momentum.
    mutating func rotateReference(by angle: CGFloat) {
        tilt += angle
        previousTarget = previousTarget.map { $0 + angle }
    }

    mutating func update(target: CGFloat, elapsed: TimeInterval) {
        guard target.isFinite, elapsed.isFinite, elapsed > 0 else { return }
        let oldTarget = previousTarget ?? target
        let delta = Self.angleDifference(target, oldTarget)
        let acceptedTarget = abs(delta) >= RippleMotion.motionDeadband ? target : oldTarget
        if acceptedTarget != oldTarget {
            sloshVelocity += min(max(delta, -0.5), 0.5) * RippleMotion.sloshImpulse
        }
        previousTarget = acceptedTarget
        var remaining = min(elapsed, RippleMotion.motionMaxElapsed)
        while remaining > 0 {
            let dt = CGFloat(min(remaining, RippleMotion.motionIntegrationStep))
            let difference = Self.angleDifference(acceptedTarget, tilt)
            let frequency = RippleMotion.tiltFrequency
            angularVelocity += (frequency * frequency * difference
                - 2 * RippleMotion.tiltDamping * frequency * angularVelocity) * dt
            tilt += angularVelocity * dt
            let waveFrequency = RippleMotion.sloshFrequency
            sloshVelocity += (-waveFrequency * waveFrequency * slosh
                - 2 * RippleMotion.sloshDamping * waveFrequency * sloshVelocity) * dt
            slosh += sloshVelocity * dt
            if abs(slosh) > RippleMotion.sloshLimit {
                slosh = slosh < 0 ? -RippleMotion.sloshLimit : RippleMotion.sloshLimit
                sloshVelocity = 0
            }
            remaining -= Double(dt)
        }
        if abs(Self.angleDifference(acceptedTarget, tilt)) < RippleMotion.motionDeadband,
           abs(angularVelocity) < RippleMotion.motionDeadband {
            tilt = acceptedTarget
            angularVelocity = 0
        }
        if abs(slosh) < RippleMotion.sloshRestThreshold,
           abs(sloshVelocity) < RippleMotion.sloshRestThreshold {
            slosh = 0
            sloshVelocity = 0
        }
    }

    static func angleDifference(_ target: CGFloat, _ current: CGFloat) -> CGFloat {
        atan2(sin(target - current), cos(target - current))
    }
}
