import Foundation
import Observation

#if os(iOS) && !targetEnvironment(simulator)
import CoreMotion
import UIKit
#endif

@MainActor
@Observable
public final class GravityTiltController {
    public private(set) var tilt: CGFloat = 0
    public private(set) var slosh: CGFloat = 0

    @ObservationIgnored private var running = false
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var dynamics = WaterDynamics()
    @ObservationIgnored private var lastTimestamp: TimeInterval?
    @ObservationIgnored private var referenceRotation: CGFloat?
    #if os(iOS) && !targetEnvironment(simulator)
    @ObservationIgnored private var manager: CMMotionManager?
    @ObservationIgnored weak var windowScene: UIWindowScene?
    #endif

    public init() {}

    public func start() {
        #if os(iOS) && !targetEnvironment(simulator)
        guard !running else { return }
        let motion = CMMotionManager()
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = RippleMotion.motionUpdateInterval
        manager = motion
        running = true
        generation &+= 1
        let session = generation
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }
            let x = data.gravity.x
            let y = data.gravity.y
            let z = data.gravity.z
            let timestamp = data.timestamp
            Task { @MainActor [weak self] in
                guard let self, self.running, self.generation == session else { return }
                let orientation = self.windowScene?.effectiveGeometry.interfaceOrientation
                let rotation: CGFloat
                switch orientation {
                case .landscapeLeft: rotation = -.pi / 2
                case .landscapeRight: rotation = .pi / 2
                case .portraitUpsideDown: rotation = .pi
                case .portrait: rotation = 0
                default: rotation = self.referenceRotation ?? 0
                }
                self.record(gravityX: x, gravityY: y, gravityZ: z,
                            timestamp: timestamp, referenceRotation: rotation)
            }
        }
        #endif
    }

    func record(gravityX: Double, gravityY: Double, gravityZ: Double,
                timestamp: TimeInterval, referenceRotation: CGFloat = 0) {
        if let previousRotation = self.referenceRotation {
            dynamics.rotateReference(by: WaterDynamics.angleDifference(referenceRotation, previousRotation))
        }
        self.referenceRotation = referenceRotation
        if abs(gravityZ) > RippleMotion.faceUpGravityZ {
            dynamics.reset()
            tilt = 0
            slosh = 0
            lastTimestamp = timestamp
            return
        }
        let elapsed = lastTimestamp.map { timestamp - $0 } ?? RippleMotion.motionUpdateInterval
        lastTimestamp = timestamp
        dynamics.update(target: RippleMotion.tiltTarget(
            gravityX: gravityX, gravityY: gravityY, gravityZ: gravityZ
        ) + referenceRotation, elapsed: elapsed)
        tilt = dynamics.tilt
        slosh = dynamics.slosh
    }

    public func stop() {
        running = false
        generation &+= 1
        #if os(iOS) && !targetEnvironment(simulator)
        manager?.stopDeviceMotionUpdates()
        manager = nil
        #endif
        dynamics.reset()
        referenceRotation = nil
        lastTimestamp = nil
        tilt = 0
        slosh = 0
    }
}
