import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchStatsView: View {
    let model: WatchStatsViewModel

    @Environment(\.locale) private var locale

    public init(model: WatchStatsViewModel) {
        self.model = model
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)

        ScrollView {
            VStack(alignment: .leading, spacing: RippleSpace.md) {
                HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
                    Text(L10n.text("Stats"))
                        .font(RippleFont.title)

                    Spacer(minLength: RippleSpace.xs)

                    Text(L10n.text("Week"))
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                }

                Text(weekRange)
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: RippleSpace.xs) {
                    summaryMetric(
                        label: L10n.text("Avg / day"),
                        value: formatter.string(
                            milliliters: model.averageMl,
                            unit: model.unit
                        )
                    )
                    summaryMetric(
                        label: L10n.text("Goal"),
                        value: L10n.goalDays(
                            hitDays: model.hitDayCount,
                            elapsedDays: model.elapsedDayCount
                        )
                    )
                    summaryMetric(
                        label: L10n.text("Total"),
                        value: formatter.string(
                            milliliters: model.snapshot.totalMl,
                            unit: model.unit
                        )
                    )
                }

                WatchStatChart(
                    points: chartPoints,
                    emptyMessage: L10n.text("No data for this period."),
                    accessibilitySummary: chartAccessibilitySummary(formatter: formatter)
                )

                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .font(RippleFont.caption)
                        .foregroundStyle(RippleColor.danger)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, RippleWatchLayout.pageHorizontalPadding)
            .padding(.vertical, RippleSpace.md)
        }
        .background(RippleColor.surface.ignoresSafeArea())
    }

    private var chartPoints: [WatchStatChartPoint] {
        model.chartPoints.map { point in
            WatchStatChartPoint(
                date: point.date,
                consumed: UnitConverter.convert(point.consumedMl, to: model.unit),
                goal: UnitConverter.convert(point.goalMl, to: model.unit)
            )
        }
    }

    private var weekRange: String {
        let calendar = Calendar.current
        let endDay = calendar.date(byAdding: .day, value: -1, to: model.snapshot.range.end)
            ?? model.snapshot.range.end
        return "\(shortDate(model.snapshot.range.start)) – \(shortDate(endDay))"
    }

    private func shortDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .locale(locale)
        )
    }

    private func summaryMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: RippleSpace.grid) {
            Text(label)
                .font(RippleFont.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(value)
                .font(RippleFont.callout.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(RippleSpace.sm)
        .background(
            RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous)
                .fill(RippleColor.waterFoam.opacity(0.55))
        )
        .accessibilityElement(children: .combine)
    }

    private func chartAccessibilitySummary(formatter: VolumeFormatter) -> String {
        L10n.text("Week chart") + " · " + L10n.text("Total") + " " + formatter.string(
            milliliters: model.snapshot.totalMl,
            unit: model.unit
        )
    }
}

#Preview("Watch Stats") {
    WatchStatsView(model: WatchStatsViewModel(useCases: RippleRuntime.preview))
}

#Preview("Watch Stats · Dark · XXXL") {
    WatchStatsView(model: WatchStatsViewModel(useCases: RippleRuntime.preview))
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
