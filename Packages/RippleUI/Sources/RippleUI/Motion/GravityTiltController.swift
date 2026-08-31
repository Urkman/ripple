import Foundation
import Observation

#if os(iOS) && !targetEnvironment(simulator)
import CoreMotion
#endif

@MainActor
@Observable
public final class GravityTiltController {
    public private(set) var tilt: CGFloat = 0

    @ObservationIgnored private var running = false
    #if os(iOS) && !targetEnvironment(simulator)
    @ObservationIgnored private var manager: CMMotionManager?
    #endif

    public init() {}

    public func start() {
        #if os(iOS) && !targetEnvironment(simulator)
        guard !running else { return }
        let motion = CMMotionManager()
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 30.0
        manager = motion
        running = true
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let gravity = data?.gravity else { return }
            let target = RippleMotion.tiltTarget(gravityX: gravity.x, gravityZ: gravity.z)
            Task { @MainActor in
                guard let self else { return }
                self.tilt = RippleMotion.lowPass(current: self.tilt, target: target)
            }
        }
        #endif
    }

    public func stop() {
        #if os(iOS) && !targetEnvironment(simulator)
        manager?.stopDeviceMotionUpdates()
        manager = nil
        #endif
        running = false
        tilt = 0
    }
}
