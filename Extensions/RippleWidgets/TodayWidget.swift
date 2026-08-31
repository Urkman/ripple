import RippleData
import RippleDomain
import RippleIntentsCore
import RippleUI
import SwiftUI
import WidgetKit

struct TodayEntry: TimelineEntry, Sendable {
    let date: Date
    let snapshot: TodaySnapshot
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), snapshot: .empty())
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (TodayEntry) -> Void) {
        Task {
            completion(await load())
        }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<TodayEntry>) -> Void) {
        Task {
            let entry = await load()
            let midnight = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(hour: 0, minute: 0),
                matchingPolicy: .nextTime
            ) ?? Date().addingTimeInterval(3600)
            completion(Timeline(entries: [entry], policy: .after(midnight)))
        }
    }

    private func load() async -> TodayEntry {
        _ = RippleBootstrap.start()
        let snapshot = (try? await RippleRuntime.current.observeToday.snapshot(for: Date())) ?? .empty()
        return TodayEntry(date: Date(), snapshot: snapshot)
    }
}

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "de.stefansturm.ripple.today", provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(RippleColor.waterFoam, for: .widget)
        }
        .configurationDisplayName("Ripple")
        .description("Today's hydration")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TodayWidgetView: View {
    var entry: TodayEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let snapshot = entry.snapshot
        let formatter = VolumeFormatter.current
        let percent = formatter.percentString(snapshot.percent)
        switch family {
        case .systemSmall:
            VStack {
                widgetGlass(snapshot, formatter: formatter)
                    .frame(maxHeight: 120)
                Text(percent)
                    .font(.headline.monospacedDigit())
                Button(intent: LogWaterIntent(milliliters: snapshot.defaultAddMl, source: .widget)) {
                    Text("+\(snapshot.defaultAddMl)")
                }
            }
        case .systemMedium, .systemLarge:
            HStack {
                widgetGlass(snapshot, formatter: formatter)
                    .frame(maxWidth: 120)
                VStack(alignment: .leading) {
                    Text(formatter.string(milliliters: snapshot.consumed.value, unit: snapshot.unit))
                        .font(.title.monospacedDigit().weight(.semibold))
                    Text(percent)
                    HStack {
                        Button(intent: LogWaterIntent(milliliters: 250, source: .widget)) { Text("+250") }
                        Button(intent: LogWaterIntent(milliliters: snapshot.defaultAddMl, source: .widget)) {
                            Text("+\(snapshot.defaultAddMl)")
                        }
                        Button(intent: LogWaterIntent(milliliters: 500, source: .widget)) { Text("+500") }
                    }
                    .buttonStyle(.plain)
                }
            }
        default:
            Text(percent)
        }
    }

    private func widgetGlass(_ snapshot: TodaySnapshot, formatter: VolumeFormatter) -> some View {
        RippleHeroView(
            consumedMl: snapshot.consumed.value,
            goalMl: snapshot.goal.value,
            phase: .idle,
            reduceMotion: reduceMotion,
            animatesPour: false,
            showsPour: false,
            amountText: formatter.valueString(milliliters: snapshot.consumed.value, unit: snapshot.unit),
            unitText: snapshot.unit.symbol,
            percentText: formatter.percentString(snapshot.percent),
            accessibilitySummary: formatter.heroAccessibility(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value,
                remainingMl: snapshot.remaining.value,
                percent: snapshot.percent
            )
        )
    }
}
