import Foundation

public struct CalculateGoal: Sendable {
    public init() {}

    public func run(profile: Profile, workoutMinutes: Int) -> Milliliters {
        let base: Int
        if let kg = profile.bodyMassKg, kg > 0 {
            let raw = kg * 33
            base = Self.roundToFifty(raw)
        } else {
            base = 2000
        }

        let activityBonus: Int
        if profile.healthReadWorkoutsEnabled, workoutMinutes > 0 {
            activityBonus = (workoutMinutes / 30) * 350
        } else {
            activityBonus = profile.activityLevel.bonusMilliliters
        }

        return Milliliters(max(base + activityBonus, 250))
    }

    public func historicalFallback(profile: Profile, settings: GoalSettings) -> Milliliters {
        if settings.mode == .calculated {
            return run(profile: profile, workoutMinutes: 0)
        }
        return Milliliters(max(settings.manualGoalMl, 1))
    }

    public static func roundToFifty(_ value: Double) -> Int {
        Int((value / 50.0).rounded() * 50)
    }
}
