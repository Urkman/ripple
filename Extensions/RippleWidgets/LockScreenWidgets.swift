import RippleDomain
import RippleIntentsCore
import RippleUI
import SwiftUI
import WidgetKit

struct LockScreenWidgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "de.stefansturm.ripple.lock", provider: TodayProvider()) { entry in
            LockScreenView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Ripple Lock Screen")
        .description("Remaining water")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenView: View {
    var entry: TodayEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let snapshot = entry.snapshot
        let percent = Int((snapshot.percent * 100).rounded())
        let formatter = VolumeFormatter.current
        switch family {
        case .accessoryCircular:
            Gauge(value: min(snapshot.percent, 1)) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(percent)")
            }
            .gaugeStyle(.accessoryCircular)
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Label("Ripple", systemImage: "drop.fill")
                Text(formatter.remainingPhrase(milliliters: snapshot.remaining.value, unit: snapshot.unit))
                    .font(.headline.monospacedDigit())
            }
        case .accessoryInline:
            Text("\(Image(systemName: "drop.fill")) \(formatter.remainingPhrase(milliliters: snapshot.remaining.value, unit: snapshot.unit))")
        default:
            Text("\(percent)%")
                .font(.largeTitle.monospacedDigit())
        }
    }
}
