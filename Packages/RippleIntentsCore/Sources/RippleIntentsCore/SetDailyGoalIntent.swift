import AppIntents
import Foundation
import RippleDomain

public struct SetDailyGoalIntent: AppIntent {
    public static let title: LocalizedStringResource = "Set Daily Goal"
    public static let openAppWhenRun = false

    @Parameter(title: "Goal in milliliters")
    public var milliliters: Int

    public init() {
        self.milliliters = 2000
    }

    public init(milliliters: Int) {
        self.milliliters = milliliters
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        try await RippleRuntime.current.updateGoal.run(mode: .manual, manualGoalMl: milliliters)
        let formatter = VolumeFormatter()
        let text = formatter.string(milliliters: milliliters, unit: .milliliters)
        return .result(dialog: "Goal set to \(text).")
    }
}
