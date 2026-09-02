import Foundation
import Observation

#if os(watchOS) && !targetEnvironment(simulator)
import CoreMotion
#endif

@MainActor
@Observable
public final class WristMotionController {
    public private(set) var trigger = 0

    @ObservationIgnored private var isRunning = false

    #if os(watchOS) && !targetEnvironment(simulator)
    @ObservationIgnored private var manager: CMMotionManager?
    @ObservationIgnored private var lastTriggerTimestamp: TimeInterval?
    #endif

    public init() {}

    public func start() {
        #if os(watchOS) && !targetEnvironment(simulator)
        guard !isRunning else { return }

        let motion = CMMotionManager()
        guard motion.isDeviceMotionAvailable else { return }

        motion.deviceMotionUpdateInterval = RippleMotion.watchMotionUpdateInterval
        manager = motion
        isRunning = true

        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }

            let acceleration = data.userAcceleration
            let accelerationMagnitude = sqrt(
                acceleration.x * acceleration.x
                    + acceleration.y * acceleration.y
                    + acceleration.z * acceleration.z
            )
            let rotation = data.rotationRate
            let rotationMagnitude = sqrt(
                rotation.x * rotation.x
                    + rotation.y * rotation.y
                    + rotation.z * rotation.z
            )
            let timestamp = data.timestamp

            Task { @MainActor [weak self] in
                self?.recordMotion(
                    accelerationMagnitude: accelerationMagnitude,
                    rotationMagnitude: rotationMagnitude,
                    timestamp: timestamp
                )
            }
        }
        #endif
    }

    public func stop() {
        #if os(watchOS) && !targetEnvironment(simulator)
        manager?.stopDeviceMotionUpdates()
        manager = nil
        lastTriggerTimestamp = nil
        #endif
        isRunning = false
    }

    #if os(watchOS) && !targetEnvironment(simulator)
    private func recordMotion(
        accelerationMagnitude: Double,
        rotationMagnitude: Double,
        timestamp: TimeInterval
    ) {
        guard isRunning else { return }
        guard accelerationMagnitude >= RippleMotion.watchMotionAccelerationThreshold
                || rotationMagnitude >= RippleMotion.watchMotionRotationThreshold else {
            return
        }

        if let lastTriggerTimestamp,
           timestamp - lastTriggerTimestamp < RippleMotion.watchMotionCooldown {
            return
        }

        lastTriggerTimestamp = timestamp
        trigger &+= 1
    }
    #endif
}
