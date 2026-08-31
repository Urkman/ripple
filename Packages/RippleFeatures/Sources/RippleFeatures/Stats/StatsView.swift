#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

public struct StatsView: View {
    @Bindable var model: StatsViewModel
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(model: StatsViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RippleSpace.xl) {
                    periodPicker
                    summaryRow
                    if model.snapshot.hasData {
                        chartBlock(title: L10n.text("Actual vs goal")) {
                            GoalVersusActualChart(
                                points: model.volumeBars,
                                unitSymbol: model.unit.symbol,
                                kind: model.kind
                            )
                        }
                        chartBlock(title: L10n.text("Hit rate")) {
                            HitRateChart(points: model.hitRatePoints, kind: model.kind)
                        }
                        chartBlock(title: L10n.text("Time of day")) {
                            DaypartChart(points: model.daypartPoints, unitSymbol: model.unit.symbol)
                        }
                        chartBlock(title: L10n.text("Containers")) {
                            ContainerShareChart(points: model.containerPoints, unitSymbol: model.unit.symbol)
                        }
                    } else {
                        Text(L10n.text("No data for this period."))
                            .font(RippleFont.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, RippleSpace.xl)
                    }
                    highlights
                }
                .padding(.horizontal, RippleSpace.lg)
                .padding(.bottom, RippleSpace.xl)
            }
            .background(RippleColor.waterFoam.ignoresSafeArea())
            .navigationTitle(L10n.text("Stats"))
            .task { await model.refresh() }
            .onChange(of: model.kind) {
                Task { await model.refresh() }
            }
            .onChange(of: model.anchor) {
                Task { await model.refresh() }
            }
        }
    }

    private var periodPicker: some View {
        VStack(spacing: RippleSpace.md) {
            Picker(L10n.text("Range"), selection: $model.kind) {
                Text(L10n.text("Week")).tag(StatsViewModel.Kind.week)
                Text(L10n.text("Month")).tag(StatsViewModel.Kind.month)
                Text(L10n.text("Year")).tag(StatsViewModel.Kind.year)
            }
            .pickerStyle(.segmented)

            HStack {
                Button(L10n.text("Previous period"), systemImage: "chevron.left", action: previousPeriod)
                    .labelStyle(.iconOnly)
                Spacer()
                Text(model.periodTitle)
                    .font(RippleFont.title.monospacedDigit())
                    .foregroundStyle(RippleColor.waterDeep)
                Spacer()
                Button(L10n.text("Next period"), systemImage: "chevron.right", action: nextPeriod)
                    .labelStyle(.iconOnly)
            }
        }
    }

    private var summaryRow: some View {
        let formatter = VolumeFormatter(locale: locale)
        let elapsed = model.elapsedCount
        let hitDays = model.hitDayCount
        return HStack(spacing: RippleSpace.sm) {
            summaryTile(
                title: L10n.text("Avg / day"),
                value: formatter.valueString(milliliters: model.averageMl, unit: model.unit),
                unit: model.unit.symbol
            )
            summaryTile(
                title: L10n.text("Goal reached"),
                value: elapsed == 0 ? "0" : "\(hitDays)/\(elapsed)",
                unit: nil
            )
            summaryTile(
                title: L10n.text("Total"),
                value: formatter.valueString(milliliters: model.snapshot.totalMl, unit: model.unit),
                unit: model.unit.symbol
            )
        }
    }

    private func summaryTile(title: String, value: String, unit: String?) -> some View {
        VStack(alignment: .leading, spacing: RippleSpace.xs) {
            Text(title)
                .font(RippleFont.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: RippleSpace.xs) {
                Text(value)
                    .font(RippleFont.title.monospacedDigit())
                    .foregroundStyle(RippleColor.waterDeep)
                if let unit {
                    Text(unit)
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(RippleSpace.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous))
    }

    private func chartBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: RippleSpace.sm) {
            Text(title)
                .font(RippleFont.title)
                .foregroundStyle(RippleColor.waterDeep)
            content()
        }
    }

    private var highlights: some View {
        let formatter = VolumeFormatter(locale: locale)
        return VStack(alignment: .leading, spacing: RippleSpace.sm) {
            Text(L10n.text("Highlights"))
                .font(RippleFont.title)
                .foregroundStyle(RippleColor.waterDeep)
            if let best = model.snapshot.bestDay {
                Text("\(L10n.text("Best day")) · \(best.date.formatted(.dateTime.month(.abbreviated).day())) · \(formatter.string(milliliters: best.consumedMl, unit: model.unit))")
                    .font(RippleFont.body.monospacedDigit())
            }
            if let weakest = model.weakestDay {
                Text("\(L10n.text("Weakest day")) · \(weakest.date.formatted(.dateTime.month(.abbreviated).day())) · \(formatter.string(milliliters: weakest.consumedMl, unit: model.unit))")
                    .font(RippleFont.body.monospacedDigit())
            }
            Text(L10n.emptyDays(model.emptyDayCount))
                .font(RippleFont.body.monospacedDigit())
            if model.snapshot.currentHitRun >= 2 {
                Text(L10n.streak(model.snapshot.currentHitRun))
                    .font(RippleFont.body.monospacedDigit())
            }
        }
    }

    private func previousPeriod() {
        shift(-1)
    }

    private func nextPeriod() {
        shift(1)
    }

    private func shift(_ delta: Int) {
        if reduceMotion {
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                model.shift(delta)
            }
        } else {
            withAnimation(.easeInOut(duration: RippleMotion.reduceMotionCrossfade)) {
                model.shift(delta)
            }
        }
    }
}
#endif
