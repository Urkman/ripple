import RippleDomain
import UserNotifications

public struct NotificationAuthorizer: NotificationAuthorizing {
    public init() {}

    public func status() async -> NotificationAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return Self.map(settings.authorizationStatus)
    }

    public func requestAuthorization() async -> NotificationAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let current = await center.notificationSettings().authorizationStatus
        guard current == .notDetermined else {
            return Self.map(current)
        }

        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        let updated = await center.notificationSettings().authorizationStatus
        return Self.map(updated)
    }

    private static func map(
        _ status: UNAuthorizationStatus
    ) -> NotificationAuthorizationStatus {
        switch status {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized:
            .authorized
        case .provisional:
            .provisional
        case .ephemeral:
            .ephemeral
        @unknown default:
            .denied
        }
    }
}
