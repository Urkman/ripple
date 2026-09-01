import RippleData
import RippleDomain
import RippleIntentsCore
import RippleUI
import OSLog
import SwiftUI
import WidgetKit

struct TodayEntry: TimelineEntry, Sendable {
    let date: Date
    let snapshot: TodaySnapshot
}

struct TodayProvider: TimelineProvider {
    private static let logger = Logger(
        subsystem: "de.stefansturm.ripple",
        category: "widget-timeline"
    )

    let kind: String

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
        let container = RippleWidgetsRuntime.makeReadContainer()
        let now = Date()

        do {
            let snapshot = try await container.useCases.observeToday.snapshot(for: now)
            Self.logger.info(
                "Generated entry kind=\(kind, privacy: .public) consumedMl=\(snapshot.consumed.value, privacy: .public) goalMl=\(snapshot.goal.value, privacy: .public)"
            )
            return TodayEntry(date: now, snapshot: snapshot)
        } catch {
            Self.logger.error(
                "Failed entry kind=\(kind, privacy: .public) error=\(error.localizedDescription, privacy: .public)"
            )
            return TodayEntry(date: now, snapshot: .empty())
        }
    }
}

struct TodayWidget: Widget {
    let kind: String
    let families: [WidgetFamily]

    init() {
        kind = RippleWidgetKind.todaySmall
        families = [.systemSmall]
    }

    init(kind: String, family: WidgetFamily) {
        self.kind = kind
        families = [family]
    }

    init(kind: String, families: [WidgetFamily]) {
        self.kind = kind
        self.families = families
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider(kind: kind)) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(RippleColor.waterFoam, for: .widget)
        }
        .configurationDisplayName("Ripple")
        .description("Today's hydration")
        .supportedFamilies(families)
        .contentMarginsDisabled()
    }
}

/// The small widget has its own configuration and content root. Keeping the
/// family-specific configuration separate prevents WidgetKit from treating a
/// small interaction as a render of the shared, family-switched legacy view.
struct SmallTodayWidgetConfiguration: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: RippleWidgetKind.todaySmall,
            provider: TodayProvider(kind: RippleWidgetKind.todaySmall)
        ) { entry in
            SmallTodayWidgetContent(entry: entry)
                .containerBackground(RippleColor.waterFoam, for: .widget)
        }
        .configurationDisplayName("Ripple")
        .description("Today's hydration")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct TodayWidgetView: View {
    let entry: TodayEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.locale) private var locale

    var body: some View {
        let snapshot = entry.snapshot
        let formatter = VolumeFormatter(locale: locale)

        switch family {
        case .systemSmall:
            SmallTodayWidgetLayout(snapshot: snapshot, formatter: formatter)
        case .systemMedium:
            MediumTodayWidget(snapshot: snapshot, formatter: formatter)
        case .systemLarge:
            LargeTodayWidget(snapshot: snapshot, formatter: formatter)
        default:
            SmallTodayWidgetLayout(snapshot: snapshot, formatter: formatter)
        }
    }
}

private struct SmallTodayWidgetContent: View {
    let entry: TodayEntry

    @Environment(\.locale) private var locale

    var body: some View {
        SmallTodayWidgetLayout(
            snapshot: entry.snapshot,
            formatter: VolumeFormatter(locale: locale)
        )
    }
}

private struct SmallTodayWidgetLayout: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.xs) {
            HStack(alignment: .center, spacing: RippleSpace.sm) {
                WidgetGlass(consumedMl: snapshot.consumed.value, goalMl: snapshot.goal.value)
                    .frame(width: RippleWidgetMetrics.smallGlassWidth)

                WidgetReadout(
                    snapshot: snapshot,
                    formatter: formatter,
                    density: .compact
                )
            }

            WidgetAddButton(
                amountMl: snapshot.defaultAddMl,
                title: addTitle(for: snapshot.defaultAddMl),
                accessibilityLabel: addTitle(for: snapshot.defaultAddMl)
            )
            .controlSize(.small)
            .frame(maxWidth: .infinity)
        }
        .padding(RippleSpace.sm)
    }

    private func addTitle(for amount: Int) -> String {
        "+" + formatter.string(milliliters: amount, unit: snapshot.unit)
    }
}

private struct MediumTodayWidget: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        HStack(alignment: .center, spacing: RippleSpace.md) {
            WidgetGlass(consumedMl: snapshot.consumed.value, goalMl: snapshot.goal.value)
                .frame(width: RippleWidgetMetrics.mediumGlassWidth)

            VStack(alignment: .leading, spacing: RippleSpace.sm) {
                WidgetReadout(snapshot: snapshot, formatter: formatter)
                WidgetQuickAddRow(
                    amounts: widgetQuickAddAmounts(snapshot: snapshot),
                    unit: snapshot.unit,
                    formatter: formatter
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(RippleSpace.md)
    }
}

private struct LargeTodayWidget: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.lg) {
            HStack(alignment: .center, spacing: RippleSpace.lg) {
                WidgetGlass(consumedMl: snapshot.consumed.value, goalMl: snapshot.goal.value)
                    .frame(width: RippleWidgetMetrics.largeGlassWidth)

                WidgetReadout(snapshot: snapshot, formatter: formatter)
            }

            WidgetQuickAddRow(
                amounts: widgetQuickAddAmounts(snapshot: snapshot),
                unit: snapshot.unit,
                formatter: formatter
            )
        }
        .padding(RippleSpace.lg)
    }
}

private struct WidgetReadout: View {
    enum Density {
        case compact
        case regular
    }

    let consumedText: String
    let percentText: String
    let remainingText: String
    let accessibilitySummary: String
    let density: Density

    init(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        density: Density = .regular
    ) {
        consumedText = formatter.string(
            milliliters: snapshot.consumed.value,
            unit: snapshot.unit
        )
        percentText = formatter.percentString(snapshot.percent)
        remainingText = formatter.remainingPhrase(
            milliliters: snapshot.remaining.value,
            unit: snapshot.unit
        )
        accessibilitySummary = formatter.heroAccessibility(
            consumedMl: snapshot.consumed.value,
            goalMl: snapshot.goal.value,
            remainingMl: snapshot.remaining.value,
            percent: snapshot.percent,
            unit: snapshot.unit
        )
        self.density = density
    }

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.xs) {
            Text(consumedText)
                .font(density == .compact ? RippleFont.callout : RippleFont.title)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(RippleWidgetMetrics.readoutMinimumScaleFactor)

            Text(percentText)
                .font(RippleFont.callout)
                .monospacedDigit()
                .lineLimit(1)

            if density == .regular {
                Text(remainingText)
                    .font(RippleFont.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(RippleWidgetMetrics.remainingMinimumScaleFactor)
                    .foregroundStyle(RippleColor.waterDeep.opacity(0.72))
            }
        }
        .foregroundStyle(RippleColor.waterDeep)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(verbatim: accessibilitySummary))
    }
}

private struct WidgetQuickAddRow: View {
    let amounts: [Int]
    let unit: VolumeUnit
    let formatter: VolumeFormatter

    var body: some View {
        HStack(spacing: RippleSpace.xs) {
            ForEach(amounts, id: \.self) { amount in
                let title = "+" + formatter.string(milliliters: amount, unit: unit)
                WidgetAddButton(
                    amountMl: amount,
                    title: title,
                    accessibilityLabel: title
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct WidgetAddButton: View {
    let amountMl: Int
    let title: String
    let accessibilityLabel: String

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: amountMl)) {
            Text(verbatim: title)
                .font(RippleFont.caption)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(RippleWidgetMetrics.readoutMinimumScaleFactor)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(RippleColor.waterLagoon)
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
    }
}

private func widgetQuickAddAmounts(snapshot: TodaySnapshot) -> [Int] {
    let configuredAmounts = snapshot.containers.prefix(3).map(\.amountMl)
    let candidates = configuredAmounts
        + [snapshot.defaultAddMl]
        + UnitConverter.quickAddPresets(for: snapshot.unit)

    return candidates.reduce(into: [Int]()) { result, amount in
        guard amount > 0, !result.contains(amount) else { return }
        result.append(amount)
    }
}
