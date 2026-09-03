import Foundation

public protocol NotificationAuthorizing: Sendable {
    func status() async -> NotificationAuthorizationStatus
    func requestAuthorization() async -> NotificationAuthorizationStatus
}
