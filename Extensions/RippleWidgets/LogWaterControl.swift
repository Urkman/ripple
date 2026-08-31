import RippleIntentsCore
import SwiftUI
import WidgetKit

struct LogWaterControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "de.stefansturm.ripple.control") {
            ControlWidgetButton(action: LogDefaultWaterIntent()) {
                Label("Ripple", systemImage: "drop.fill")
            }
        }
        .displayName("Ripple")
        .description("Log the default amount")
    }
}
