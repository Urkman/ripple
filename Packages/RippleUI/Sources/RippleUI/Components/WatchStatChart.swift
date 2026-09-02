import Charts
import SwiftUI

public struct WatchStatChartPoint: Identifiable, Equatable, Sendable {
    public let date: Date
    public let consumed: Double
    public let goal: Double

    public var id: Date { date }

    public init(date: Date, consumed: Double, goal: Double) {
        self.date = date
        self.consumed = consumed
        self.goal = goal
    }
}

public struct WatchStatChart: View {
    public var points: [WatchStatChartPoint]
    public var emptyMessage: String
    public var accessibilitySummary: String

    public init(
        points: [WatchStatChartPoint],
        emptyMessage: String,
        accessibilitySummary: String
    ) {
        self.points = points
        self.emptyMessage = emptyMessage
        self.accessibilitySummary = accessibilitySummary
    }

    public var body: some View {
        if points.isEmpty {
            Text(emptyMessage)
                .font(RippleFont.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: RippleWatchLayout.chartHeight)
        } else {
            let goal = points.map(\.goal).filter { $0 > 0 }.max() ?? 0

            Chart {
                ForEach(points) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Consumed", point.consumed)
                    )
                    .foregroundStyle(RippleColor.watchAqua)
                }

                if goal > 0 {
                    RuleMark(y: .value("Goal", goal))
                        .foregroundStyle(RippleColor.watchLagoon.opacity(0.55))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel()
                }
            }
            .frame(height: RippleWatchLayout.chartHeight)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
        }
    }
}

#Preview("Watch Stats Chart") {
    let start = Date()
    let points = (0..<7).compactMap { offset -> WatchStatChartPoint? in
        guard let date = Calendar.current.date(byAdding: .day, value: offset, to: start) else {
            return nil
        }
        return WatchStatChartPoint(date: date, consumed: Double(offset * 250), goal: 2_000)
    }

    WatchStatChart(
        points: points,
        emptyMessage: "No data for this period.",
        accessibilitySummary: "Current week, seven days"
    )
    .padding()
}

#Preview("Watch Stats Chart · Empty · Dark · XXXL") {
    WatchStatChart(
        points: [],
        emptyMessage: "No data for this period.",
        accessibilitySummary: "Current week, no data"
    )
    .padding()
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility3)
}
