import Foundation
import RippleDomain

enum L10n {
    static func text(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    static func addAmount(_ formatted: String) -> String {
        String(localized: "Add \(formatted)", bundle: .module)
    }

    static var custom: String { text("Custom") }

    static var turnDigitalCrown: String { text("Turn the Digital Crown") }

    static func goalDays(hitDays: Int, elapsedDays: Int) -> String {
        String(localized: "\(hitDays) / \(elapsedDays) days", bundle: .module)
    }

    static func onboardingProgress(page: Int) -> String {
        String(localized: "\(page) of 6", bundle: .module)
    }

    static func confirmation(amount: String) -> String {
        String(localized: "+\(amount) · nice Ripple.", bundle: .module)
    }

    static func lastEntry(time: String, container: String?) -> String {
        if let container, !container.isEmpty {
            return String(localized: "Last \(time) · \(container)", bundle: .module)
        }
        return String(localized: "Last \(time)", bundle: .module)
    }

    static var inTheFlow: String { text("Today you're in the flow.") }
    static var stillQuiet: String { text("Still quiet — first sip?") }

    static func source(_ source: IntakeSource) -> String {
        switch source {
        case .app, .control, .notification:
            text("App")
        case .intent:
            text("Siri")
        case .widget:
            text("Widget")
        case .watch:
            text("Watch")
        case .health:
            text("Health")
        }
    }

    static func daypart(_ part: Daypart) -> String {
        switch part {
        case .morning: text("Morning")
        case .midday: text("Midday")
        case .afternoon: text("Afternoon")
        case .evening: text("Evening")
        }
    }

    static func emptyDays(_ count: Int) -> String {
        String(localized: "\(count) days without entries", bundle: .module)
    }

    static func minutes(_ count: Int) -> String {
        String(localized: "\(count) min", bundle: .module)
    }

    static func streak(_ count: Int) -> String {
        String(localized: "Longest goal streak: \(count)", bundle: .module)
    }
}
