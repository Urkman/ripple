import Foundation

public struct Profile: Sendable, Hashable, Codable, Equatable {
    public var preferredUnit: VolumeUnit
    public var bodyMassKg: Double?
    public var activityLevel: ActivityLevel
    public var wakeTime: ClockTime
    public var sleepTime: ClockTime
    public var remindersEnabled: Bool
    public var healthReadWorkoutsEnabled: Bool
    public var healthWriteEnabled: Bool
    public var hapticsEnabled: Bool
    public var onboardingCompleted: Bool
    public var updatedAt: Date

    public init(
        preferredUnit: VolumeUnit = .milliliters,
        bodyMassKg: Double? = nil,
        activityLevel: ActivityLevel = .sedentary,
        wakeTime: ClockTime = .defaultWake,
        sleepTime: ClockTime = .defaultSleep,
        remindersEnabled: Bool = true,
        healthReadWorkoutsEnabled: Bool = false,
        healthWriteEnabled: Bool = false,
        hapticsEnabled: Bool = true,
        onboardingCompleted: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.preferredUnit = preferredUnit
        self.bodyMassKg = bodyMassKg
        self.activityLevel = activityLevel
        self.wakeTime = wakeTime
        self.sleepTime = sleepTime
        self.remindersEnabled = remindersEnabled
        self.healthReadWorkoutsEnabled = healthReadWorkoutsEnabled
        self.healthWriteEnabled = healthWriteEnabled
        self.hapticsEnabled = hapticsEnabled
        self.onboardingCompleted = onboardingCompleted
        self.updatedAt = updatedAt
    }

    public static func fresh(locale: Locale = .current) -> Profile {
        let usesMetric = locale.measurementSystem == .metric
        return Profile(preferredUnit: usesMetric ? .milliliters : .fluidOunces)
    }
}
