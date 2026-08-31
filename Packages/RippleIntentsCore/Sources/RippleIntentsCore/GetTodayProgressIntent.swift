import AppIntents
import Foundation
import RippleDomain

public struct GetTodayProgressIntent: AppIntent {
    public static let title: LocalizedStringResource = "Today's Water Progress"
    public static let openAppWhenRun = false

    public init() {}

    public func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let snapshot = try await RippleRuntime.current.observeToday.snapshot(for: Date())
        let formatter = VolumeFormatter()
        let remaining = formatter.string(milliliters: snapshot.remaining.value, unit: snapshot.unit)
        let percent = Int((snapshot.percent * 100).rounded())
        let goal = formatter.string(milliliters: snapshot.goal.value, unit: snapshot.unit)
        let spoken = "\(remaining) left. \(percent) percent of \(goal)."
        return .result(value: spoken, dialog: IntentDialog("\(spoken)"))
    }
}
