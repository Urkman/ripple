import Foundation
import SwiftData

@Model
public final class GoalSettingsRecord {
    public var modeRaw: String = "manual"
    public var manualGoalMl: Int = 2000
    public var updatedAt: Date = Date(timeIntervalSince1970: 0)

    public init(
        modeRaw: String = "manual",
        manualGoalMl: Int = 2000,
        updatedAt: Date = Date(timeIntervalSince1970: 0)
    ) {
        self.modeRaw = modeRaw
        self.manualGoalMl = manualGoalMl
        self.updatedAt = updatedAt
    }
}
