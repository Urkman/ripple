import RippleData
import RippleFeatures
import SwiftUI

@main
struct RippleVisionApp: App {
    private let container: RippleContainer

    init() {
        container = RippleBootstrap.start()
    }

    var body: some Scene {
        WindowGroup {
            VisionRootView(useCases: container.useCases)
                .environment(\.rippleUseCases, container.useCases)
        }
    }
}
