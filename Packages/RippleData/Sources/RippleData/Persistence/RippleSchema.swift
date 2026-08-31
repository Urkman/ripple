import Foundation
import SwiftData

public enum RippleSchema {
    public static var models: [any PersistentModel.Type] {
        [
            IntakeRecord.self,
            ContainerRecord.self,
            GoalSettingsRecord.self,
            ProfileRecord.self,
            ReminderRuleRecord.self,
        ]
    }

    public static var schema: Schema {
        Schema(models)
    }
}
