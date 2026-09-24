import Foundation
import RippleDomain

public enum SettingsRoute: Sendable, Hashable, Identifiable {
    case container(Container)
    case reminders

    public var id: String {
        switch self {
        case .container(let container):
            "container-\(container.id.uuidString)"
        case .reminders:
            "reminders"
        }
    }
}
