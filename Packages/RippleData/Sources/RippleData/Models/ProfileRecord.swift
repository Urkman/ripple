import Foundation
import SwiftData

@Model
public final class ProfileRecord {
    public var preferredUnitRaw: String = "milliliters"
    public var bodyMassKg: Double?
    public var activityLevelRaw: String = "sedentary"
    public var wakeHour: Int = 7
    public var wakeMinute: Int = 0
    public var sleepHour: Int = 22
    public var sleepMinute: Int = 0
    public var remindersEnabled: Bool = true
    public var healthReadWorkoutsEnabled: Bool = false
    public var healthWriteEnabled: Bool = false
    public var hapticsEnabled: Bool = true
    public var onboardingCompleted: Bool = false
    public var updatedAt: Date = Date()

    public init() {}
}
