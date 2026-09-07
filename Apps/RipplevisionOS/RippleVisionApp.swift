import RippleData
import RippleFeatures
import RippleUI
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
        .windowResizability(.contentMinSize)
        .defaultSize(
            width: RippleLayout.visionWindowIdealWidth,
            height: RippleLayout.visionWindowIdealHeight
        )
    }
}
