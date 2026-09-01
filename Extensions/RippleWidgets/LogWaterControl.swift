import RippleData
import RippleIntentsCore
import SwiftUI
import WidgetKit

struct LogWaterControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: RippleWidgetKind.control) {
            ControlWidgetButton(action: LogDefaultWaterIntent()) {
                Label("Ripple", systemImage: "plus")
            }
        }
        .displayName("Ripple")
        .description("Log the default amount")
    }
}
