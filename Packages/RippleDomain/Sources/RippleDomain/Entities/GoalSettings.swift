import Foundation

public enum GoalMode: String, Sendable, Codable, CaseIterable, Equatable {
    case manual
    case calculated
}

public struct GoalSettings: Sendable, Hashable, Codable, Equatable {
    public var mode: GoalMode
    public var manualGoalMl: Int
    public var updatedAt: Date

    public init(
        mode: GoalMode = .manual,
        manualGoalMl: Int = 2000,
        updatedAt: Date = Date()
    ) {
        self.mode = mode
        self.manualGoalMl = manualGoalMl
        self.updatedAt = updatedAt
    }

    public static let `default` = GoalSettings()
}
