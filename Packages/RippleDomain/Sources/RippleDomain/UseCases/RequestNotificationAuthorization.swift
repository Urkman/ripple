import Foundation

public struct RequestNotificationAuthorization: Sendable {
    private let authorizing: any NotificationAuthorizing

    public init(authorizing: any NotificationAuthorizing) {
        self.authorizing = authorizing
    }

    public func status() async -> NotificationAuthorizationStatus {
        await authorizing.status()
    }

    public func run() async -> NotificationAuthorizationStatus {
        await authorizing.requestAuthorization()
    }
}
