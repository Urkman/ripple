import RippleData
import RippleDomain
import RippleFeatures
import RippleIntentsCore
import RippleUI
import SwiftUI
import UserNotifications

@main
struct RippleiOSApp: App {
    @State private var container: RippleContainer
    @State private var notificationDelegate = NotificationDelegate()

    init() {
        let started = RippleBootstrap.start()
        _container = State(initialValue: started)
        let delegate = NotificationDelegate()
        UNUserNotificationCenter.current().delegate = delegate
        _notificationDelegate = State(initialValue: delegate)
    }

    var body: some Scene {
        WindowGroup {
            RootView(useCases: container.useCases)
                .environment(\.rippleUseCases, container.useCases)
                .onOpenURL { _ in }
                .onAppear { consumePendingRoute() }
        }
    }

    private func consumePendingRoute() {
        _ = RippleNavigation.pending
        RippleNavigation.pending = nil
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.actionIdentifier == ReminderScheduler.logAction else { return }
        let useCases = RippleRuntime.current
        let snapshot = try? await useCases.observeToday.snapshot(for: Date())
        let amount = snapshot?.defaultAddMl ?? 250
        _ = try? await useCases.logIntake.run(amount: Milliliters(amount), source: .notification)
    }
}
