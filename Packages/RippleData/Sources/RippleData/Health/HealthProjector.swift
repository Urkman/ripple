import Foundation
import RippleDomain

#if canImport(HealthKit) && (os(iOS) || os(watchOS))
import HealthKit
#endif

public actor HealthProjector: HealthProjecting {
    public init() {}

    public func project(intake: Intake) async {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.project(intake: intake)
        #endif
    }

    public func retract(intakeID: UUID) async {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.retract(intakeID: intakeID)
        #endif
    }
}

public struct HealthAuthorizer: HealthAuthorizing {
    public init() {}

    public func status() async -> HealthAuthorizationStatus {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.status()
        #else
        HealthAuthorizationStatus()
        #endif
    }

    public func requestWaterWrite() async -> Bool {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.requestWaterWrite()
        #else
        false
        #endif
    }

    public func requestWorkoutRead() async -> Bool {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.requestWorkoutRead()
        #else
        false
        #endif
    }
}

public struct WorkoutReader: WorkoutReading {
    public init() {}

    public func moderateMinutes(on day: Date) async -> Int {
        #if canImport(HealthKit) && (os(iOS) || os(watchOS))
        await HealthKitClient.shared.moderateMinutes(on: day)
        #else
        0
        #endif
    }
}
