import RippleData
import RippleFeatures
import SwiftUI

@main
struct RippleTVApp: App {
    private let container: RippleContainer

    init() {
        container = RippleBootstrap.start()
    }

    var body: some Scene {
        WindowGroup {
            TVRootView(useCases: container.useCases)
                .environment(\.rippleUseCases, container.useCases)
        }
    }
}
