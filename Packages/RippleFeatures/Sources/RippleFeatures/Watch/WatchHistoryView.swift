import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchHistoryView: View {
    let model: WatchHistoryViewModel
    let useCases: UseCases

    @Environment(\.locale) private var locale

    public init(model: WatchHistoryViewModel, useCases: UseCases) {
        self.model = model
        self.useCases = useCases
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if model.days.isEmpty {
                        Text(L10n.text("No entries"))
                            .font(RippleFont.callout)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 120)
                    }

                    ForEach(model.days) { day in
                        NavigationLink(value: day.date) {
                            WatchDayRow(
                                title: weekday(for: day.date),
                                subtitle: shortDate(for: day.date),
                                amountText: formatter.string(
                                    milliliters: day.consumed.value,
                                    unit: model.unit
                                ),
                                progress: progress(for: day),
                                statusText: accessibilityValue(for: day)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, RippleWatchLayout.pageHorizontalPadding)

                        if day.id != model.days.last?.id {
                            Divider()
                                .padding(.leading, RippleWatchLayout.pageHorizontalPadding)
                        }
                    }
                }
                .padding(.vertical, RippleSpace.sm)
            }
            .background(RippleColor.surface.ignoresSafeArea())
            .navigationTitle(L10n.text("History"))
            .navigationDestination(for: Date.self) { day in
                WatchDayDetailView(useCases: useCases, day: day)
            }
        }
    }

    private var formatter: VolumeFormatter {
        VolumeFormatter(locale: locale)
    }

    private func weekday(for date: Date) -> String {
        date.formatted(
            .dateTime
                .weekday(.abbreviated)
                .locale(locale)
        )
    }

    private func shortDate(for date: Date) -> String {
        date.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .locale(locale)
        )
    }

    private func progress(for day: DayTotal) -> Double {
        min(
            1,
            max(
                0,
                Double(day.consumed.value) / Double(max(day.goal.value, 1))
            )
        )
    }

    private func accessibilityValue(for day: DayTotal) -> String {
        let amount = formatter.string(milliliters: day.consumed.value, unit: model.unit)
        let goal = formatter.string(milliliters: day.goal.value, unit: model.unit)
        let status = day.consumed.value >= day.goal.value
            ? L10n.text("Goal reached")
            : formatter.percentString(progress(for: day))
        return "\(amount) · \(L10n.text("Goal")) \(goal) · \(status)"
    }
}
#endif
