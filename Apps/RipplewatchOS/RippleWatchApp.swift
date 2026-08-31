import RippleData
import RippleFeatures
import SwiftUI

@main
struct RippleWatchApp: App {
    private let container: RippleContainer

    init() {
        container = RippleBootstrap.start()
    }

    var body: some Scene {
        WindowGroup {
            WatchTodayView(useCases: container.useCases)
                .environment(\.rippleUseCases, container.useCases)
        }
    }
}
