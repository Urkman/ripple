import RippleData
import RippleDomain
import RippleIntentsCore
import RippleUI
import SwiftUI
import WidgetKit

struct WatchEntry: TimelineEntry, Sendable {
    let date: Date
    let snapshot: TodaySnapshot
}

enum RippleWatchWidgetsRuntime {
    static let container = RippleBootstrap.start()

    static func makeReadContainer() -> RippleContainer {
        _ = container
        return RippleContainer.make(shared: container.shared)
    }
}

@main
struct WatchWidgetsBundle: WidgetBundle {
    init() {
        _ = RippleWatchWidgetsRuntime.container
    }

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
        let container = RippleWatchWidgetsRuntime.makeReadContainer()
        let snapshot = (try? await container.useCases.observeToday.snapshot(for: Date()))
            ?? .empty()
        return WatchEntry(date: Date(), snapshot: snapshot)
    }
}

struct WatchComplicationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: RippleWidgetKind.watch, provider: WatchProvider()) { entry in
            WatchComplicationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Ripple")
        .description("Today's remaining water")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WatchComplicationView: View {
    let entry: WatchEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.locale) private var locale

    var body: some View {
        let snapshot = entry.snapshot
        let formatter = VolumeFormatter(locale: locale)

        switch family {
        case .accessoryCircular:
            WatchCircularView(snapshot: snapshot, formatter: formatter)
        case .accessoryRectangular:
            WatchRectangularView(snapshot: snapshot, formatter: formatter)
        case .accessoryInline:
            WatchInlineView(snapshot: snapshot, formatter: formatter)
        default:
            Text(verbatim: formatter.percentString(snapshot.percent))
                .monospacedDigit()
        }
    }
}

private struct WatchCircularView: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: snapshot.defaultAddMl)) {
            ZStack {
                WidgetGlass(consumedMl: snapshot.consumed.value, goalMl: snapshot.goal.value)
                    .frame(width: RippleWidgetMetrics.accessoryCircularGlassWidth)

                Text(verbatim: formatter.percentString(snapshot.percent))
                    .font(RippleFont.caption.monospacedDigit())
                    .widgetAccentable()
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: watchAccessibilityLabel(
            snapshot: snapshot,
            formatter: formatter
        )))
    }
}

private struct WatchRectangularView: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: snapshot.defaultAddMl)) {
            HStack(spacing: RippleSpace.sm) {
                WidgetGlass(consumedMl: snapshot.consumed.value, goalMl: snapshot.goal.value)
                    .frame(width: RippleWidgetMetrics.accessoryRectangularGlassWidth)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Ripple")
                        .font(RippleFont.caption)
                    Text(verbatim: formatter.remainingPhrase(
                        milliliters: snapshot.remaining.value,
                        unit: snapshot.unit
                    ))
                    .font(RippleFont.caption.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(RippleWidgetMetrics.accessoryMinimumScaleFactor)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: watchAccessibilityLabel(
            snapshot: snapshot,
            formatter: formatter
        )))
    }
}

private struct WatchInlineView: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: snapshot.defaultAddMl)) {
            Text(verbatim: formatter.percentString(snapshot.percent) + " · " + formatter.remainingPhrase(
                milliliters: snapshot.remaining.value,
                unit: snapshot.unit
            ))
            .monospacedDigit()
            .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: watchAccessibilityLabel(
            snapshot: snapshot,
            formatter: formatter
        )))
    }
}

private func watchAccessibilityLabel(
    snapshot: TodaySnapshot,
    formatter: VolumeFormatter
) -> String {
    formatter.heroAccessibility(
        consumedMl: snapshot.consumed.value,
        goalMl: snapshot.goal.value,
        remainingMl: snapshot.remaining.value,
        percent: snapshot.percent,
        unit: snapshot.unit
    ) + " +" + formatter.string(
        milliliters: snapshot.defaultAddMl,
        unit: snapshot.unit
    )
}
