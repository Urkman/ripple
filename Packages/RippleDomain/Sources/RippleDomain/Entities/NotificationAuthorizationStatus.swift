import Foundation

public enum NotificationAuthorizationStatus: String, Sendable, Hashable, Codable, CaseIterable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    public var isAllowed: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        }
    }
}
