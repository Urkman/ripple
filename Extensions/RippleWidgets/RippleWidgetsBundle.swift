import SwiftUI
import WidgetKit

@main
struct RippleWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        LockScreenWidgets()
        LogWaterControl()
        RippleLiveActivityWidget()
    }
}
