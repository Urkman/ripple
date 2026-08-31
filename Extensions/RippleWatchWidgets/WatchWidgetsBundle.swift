import RippleData
import RippleDomain
import RippleUI
import SwiftUI
import WidgetKit

struct WatchEntry: TimelineEntry, Sendable {
    let date: Date
    let snapshot: TodaySnapshot
}

@main
struct WatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WatchComplicationWidget()
    }
}

struct WatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchEntry {
        WatchEntry(date: Date(), snapshot: .empty())
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (WatchEntry) -> Void) {
        Task {
            completion(await load())
        }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<WatchEntry>) -> Void) {
        Task {
            let entry = await load()
            completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30 * 60))))
        }
    }

    private func load() async -> WatchEntry {
        _ = RippleBootstrap.start()
        let snapshot = (try? await RippleRuntime.current.observeToday.snapshot(for: Date())) ?? .empty()
        return WatchEntry(date: Date(), snapshot: snapshot)
    }
}

struct WatchComplicationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "de.stefansturm.ripple.watch", provider: WatchProvider()) { entry in
            WatchComplicationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Ripple")
        .description("Today's remaining water")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WatchComplicationView: View {
    var entry: WatchEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let snapshot = entry.snapshot
        let percent = Int((min(snapshot.percent, 1) * 100).rounded())
        switch family {
        case .accessoryCircular:
            Gauge(value: min(snapshot.percent, 1)) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(percent)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Ripple")
                Text(VolumeFormatter.current.remainingPhrase(milliliters: snapshot.remaining.value, unit: snapshot.unit))
            }
        default:
            Text("\(percent)%")
        }
    }
}
