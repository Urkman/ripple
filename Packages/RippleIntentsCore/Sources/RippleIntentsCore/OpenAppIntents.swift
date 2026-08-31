import AppIntents
import Foundation

public struct OpenTodayIntent: AppIntent {
    public static let title: LocalizedStringResource = "Open Today"
    public static let openAppWhenRun = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        RippleNavigation.pending = .today
        return .result()
    }
}

public struct OpenHistoryIntent: AppIntent {
    public static let title: LocalizedStringResource = "Open History"
    public static let openAppWhenRun = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        RippleNavigation.pending = .history
        return .result()
    }
}
