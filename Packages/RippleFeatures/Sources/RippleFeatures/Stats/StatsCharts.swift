#if os(iOS) || os(macOS) || os(visionOS)
import Charts
import RippleDomain
import RippleUI
import SwiftUI

struct GoalVersusActualChart: View {
    let points: [StatsViewModel.VolumeBarPoint]
    let unitSymbol: String
    let kind: StatsViewModel.Kind
    @State private var selected: Date?

    var body: some View {
        Chart {
            ForEach(points) { point in
                BarMark(
                    x: xValue(point.date),
                    y: .value(unitSymbol, point.consumed)
                )
                .foregroundStyle(RippleColor.waterAqua)
                .position(by: .value(L10n.text("Actual"), L10n.text("Actual")))
                .accessibilityLabel(point.date.formatted(date: .abbreviated, time: .omitted))
                .accessibilityValue("\(Int(point.consumed.rounded())) \(unitSymbol)")

                BarMark(
                    x: xValue(point.date),
                    y: .value(unitSymbol, point.goal)
                )
                .foregroundStyle(RippleColor.waterLagoon.opacity(0.4))
                .position(by: .value(L10n.text("Goal"), L10n.text("Goal")))
                .accessibilityHidden(true)
            }

            if let selected, let point = match(selected) {
                RuleMark(x: xValue(point.date))
                    .foregroundStyle(RippleColor.waterDeep.opacity(0.3))
                    .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .padScale)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.date.formatted(annotationStyle))
                            Text("\(Int(point.consumed.rounded())) \(unitSymbol) · \(Int((point.percent * 100).rounded())) %")
                        }
                        .font(RippleFont.caption.monospacedDigit())
                        .padding(RippleSpace.sm)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous))
                    }
            }
        }
        .chartXSelection(value: $selected)
        .chartYScale(domain: .automatic(includesZero: true))
        .chartXAxis {
            switch kind {
            case .week:
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            case .month:
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            case .year:
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
        }
        .chartLegend(.hidden)
        .frame(minHeight: RippleChart.height)
    }

    private var annotationStyle: Date.FormatStyle {
        switch kind {
        case .year:
            .dateTime.month(.abbreviated).year()
        case .week, .month:
            .dateTime.month(.abbreviated).day()
        }
    }

    private func xValue(_ date: Date) -> PlottableValue<Date> {
        switch kind {
        case .year:
            .value(L10n.text("Month"), date, unit: .month)
        case .week, .month:
            .value(L10n.text("Day"), date, unit: .day)
        }
    }

    private func match(_ date: Date) -> StatsViewModel.VolumeBarPoint? {
        let calendar = Calendar.current
        let granularity: Calendar.Component = kind == .year ? .month : .day
        return points.first { calendar.isDate($0.date, equalTo: date, toGranularity: granularity) }
            ?? points.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }
}

struct HitRateChart: View {
    let points: [StatsViewModel.HitRatePoint]
    let kind: StatsViewModel.Kind

    var body: some View {
        Chart(points) { point in
            LineMark(
                x: xValue(point.date),
                y: .value(L10n.text("Goal reached"), point.percent)
            )
            .foregroundStyle(RippleColor.waterLagoon)
            .interpolationMethod(.linear)
            PointMark(
                x: xValue(point.date),
                y: .value(L10n.text("Goal reached"), point.percent)
            )
            .foregroundStyle(RippleColor.waterAqua)
            .accessibilityLabel(point.date.formatted(date: .abbreviated, time: .omitted))
            .accessibilityValue("\(Int(point.percent.rounded())) %")
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            switch kind {
            case .week:
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            case .month:
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            case .year:
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
        }
        .frame(minHeight: RippleChart.height)
    }

    private func xValue(_ date: Date) -> PlottableValue<Date> {
        switch kind {
        case .year:
            .value(L10n.text("Month"), date, unit: .month)
        case .week, .month:
            .value(L10n.text("Day"), date, unit: .day)
        }
    }
}

struct DaypartChart: View {
    let points: [StatsViewModel.DaypartPoint]
    let unitSymbol: String

    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value(L10n.text("Time of day"), L10n.daypart(point.part)),
                y: .value(unitSymbol, point.plotValue)
            )
            .foregroundStyle(RippleColor.waterAqua)
            .accessibilityLabel(L10n.daypart(point.part))
            .accessibilityValue("\(Int(point.plotValue.rounded())) \(unitSymbol)")
        }
        .chartYScale(domain: .automatic(includesZero: true))
        .chartXScale(domain: Daypart.allCases.map { L10n.daypart($0) })
        .frame(minHeight: RippleChart.height)
    }
}

struct ContainerShareChart: View {
    let points: [StatsViewModel.ContainerSharePoint]
    let unitSymbol: String

    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value(unitSymbol, point.plotValue),
                y: .value(L10n.text("Container"), point.name)
            )
            .foregroundStyle(RippleColor.waterLagoon)
            .accessibilityLabel(point.name)
            .accessibilityValue("\(Int(point.plotValue.rounded())) \(unitSymbol)")
        }
        .chartYScale(domain: points.map(\.name))
        .chartXScale(domain: .automatic(includesZero: true))
        .frame(minHeight: RippleChart.height)
    }
}
#endif
