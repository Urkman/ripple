import AppIntents
import Foundation
import RippleDomain

public struct UndoLastIntakeIntent: AppIntent {
    public static let title: LocalizedStringResource = "Undo Last Sip"
    public static let description = IntentDescription("Remove the last logged drink")
    public static let openAppWhenRun = false

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let undone = try await RippleRuntime.current.undoLastIntake.run()
        if let undone {
            let formatter = VolumeFormatter()
            let amount = formatter.string(milliliters: undone.amountMl, unit: .milliliters)
            return .result(dialog: "Took back \(amount).")
        }
        return .result(dialog: "Nothing to undo.")
    }
}
