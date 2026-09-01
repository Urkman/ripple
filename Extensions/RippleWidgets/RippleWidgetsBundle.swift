import RippleData
import SwiftUI
import WidgetKit

enum RippleWidgetsRuntime {
    static let container = RippleBootstrap.start()

    static func makeReadContainer() -> RippleContainer {
        _ = container
        return RippleContainer.make(shared: container.shared)
    }
}

@main
struct RippleWidgetsBundle: WidgetBundle {
    init() {
        _ = RippleWidgetsRuntime.container
    }

    var body: some Widget {
        // Keep the pre-family-split kind registered so existing placements do
        // not become orphaned when the extension is updated.
        TodayWidget(
            kind: RippleWidgetKind.legacyToday,
            families: [.systemSmall, .systemMedium, .systemLarge]
        )
        SmallTodayWidgetConfiguration()
        TodayWidget(
            kind: RippleWidgetKind.todayMedium,
            family: .systemMedium
        )
        TodayWidget(
            kind: RippleWidgetKind.todayLarge,
            family: .systemLarge
        )
        LockScreenWidgets()
        LogWaterControl()
    }
}
