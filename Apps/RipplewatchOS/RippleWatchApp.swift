import Foundation
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
            rootView
                .environment(\.rippleUseCases, container.useCases)
                .preferredColorScheme(.dark)
                .environment(\.colorScheme, .dark)
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if demoDataRequested {
            WatchDemoDataGateView(useCases: container.useCases) {
                normalRootView
            }
        } else {
            normalRootView
        }
        #else
        normalRootView
        #endif
    }

    private var normalRootView: some View {
        #if DEBUG
        WatchRootView(
            useCases: container.useCases,
            initialPage: requestedWatchPage
        )
        #else
        WatchRootView(useCases: container.useCases)
        #endif
    }

    #if DEBUG
    private var demoDataRequested: Bool {
        ProcessInfo.processInfo.arguments.contains("-ripple-demo-data")
    }

    private var requestedWatchPage: Int {
        let prefix = "-ripple-watch-page="
        guard let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(prefix) }) else {
            return 0
        }

        switch argument.dropFirst(prefix.count) {
        case "history":
            return 1
        case "stats":
            return 2
        default:
            return 0
        }
    }
    #endif
}
