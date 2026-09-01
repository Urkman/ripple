import RippleData
import RippleDomain
import RippleIntentsCore
import RippleUI
import SwiftUI
import WidgetKit

struct LockScreenWidgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: RippleWidgetKind.lockScreen,
            provider: TodayProvider(kind: RippleWidgetKind.lockScreen)
        ) { entry in
            LockScreenView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Ripple Lock Screen")
        .description("Remaining water")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenView: View {
    let entry: TodayEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.locale) private var locale

    var body: some View {
        let snapshot = entry.snapshot
        let formatter = VolumeFormatter(locale: locale)

        switch family {
        case .accessoryCircular:
            LockScreenCircularView(snapshot: snapshot, formatter: formatter)
        case .accessoryRectangular:
            LockScreenRectangularView(snapshot: snapshot, formatter: formatter)
        case .accessoryInline:
            LockScreenInlineView(snapshot: snapshot, formatter: formatter)
        default:
            Text(verbatim: formatter.percentString(snapshot.percent))
                .monospacedDigit()
        }
    }
}

private struct LockScreenCircularView: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: snapshot.defaultAddMl)) {
            VStack(spacing: 0) {
                Text(verbatim: formatter.percentString(snapshot.percent))
                    .font(.caption.monospacedDigit())
                    .widgetAccentable()
                Text(verbatim: "+" + formatter.valueString(
                    milliliters: snapshot.defaultAddMl,
                    unit: snapshot.unit
                ))
                    .font(RippleFont.caption.monospacedDigit())
                    .minimumScaleFactor(RippleWidgetMetrics.accessoryMinimumScaleFactor)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
    }

    private var accessibilityLabel: String {
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
}

private struct LockScreenRectangularView: View {
    let snapshot: TodaySnapshot
    let formatter: VolumeFormatter

    var body: some View {
        Button(intent: LogWidgetWaterIntent(milliliters: snapshot.defaultAddMl)) {
            VStack(alignment: .leading, spacing: RippleSpace.xs) {
                Text("Ripple")
                    .font(RippleFont.caption)

                HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
                    Text(verbatim: formatter.remainingPhrase(
                        milliliters: snapshot.remaining.value,
                        unit: snapshot.unit
                    ))
                    .font(RippleFont.callout)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(RippleWidgetMetrics.accessoryMinimumScaleFactor)

                    Spacer(minLength: 0)

                    Text(verbatim: "+" + formatter.valueString(
                        milliliters: snapshot.defaultAddMl,
                        unit: snapshot.unit
                    ))
                    .font(RippleFont.caption)
                    .monospacedDigit()
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
    }

    private var accessibilityLabel: String {
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
}

private struct LockScreenInlineView: View {
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
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
    }

    private var accessibilityLabel: String {
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
}
