import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchDayDetailView: View {
    @State private var model: WatchDayDetailViewModel
    @Environment(\.locale) private var locale

    public init(model: WatchDayDetailViewModel) {
        _model = State(initialValue: model)
    }

    public init(useCases: UseCases, day: Date) {
        self.init(model: WatchDayDetailViewModel(useCases: useCases, day: day))
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)

        ScrollView {
            VStack(alignment: .leading, spacing: RippleSpace.md) {
                daySummary(formatter: formatter)

                Divider()

                Text(L10n.text("Entries"))
                    .font(RippleFont.title)

                if model.entries.isEmpty {
                    Text(L10n.text("No entries"))
                        .font(RippleFont.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    LazyVStack(spacing: RippleSpace.xs) {
                        ForEach(model.entries) { intake in
                            WatchIntakeDetailRow(
                                intake: intake,
                                amountText: formatter.string(
                                    milliliters: intake.amountMl,
                                    unit: model.snapshot.unit
                                ),
                                containerName: model.containerName(for: intake),
                                sourceText: L10n.source(intake.source),
                                timeText: time(for: intake.date)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, RippleWatchLayout.pageHorizontalPadding)
            .padding(.vertical, RippleSpace.md)
        }
        .background(RippleColor.surface.ignoresSafeArea())
        .navigationTitle(longDate(for: model.day))
        .task {
            await model.refresh()
        }
    }

    private func daySummary(formatter: VolumeFormatter) -> some View {
        VStack(alignment: .leading, spacing: RippleSpace.xs) {
            Text(formatter.string(
                milliliters: model.snapshot.consumed.value,
                unit: model.snapshot.unit
            ))
            .font(RippleFont.display)
            .minimumScaleFactor(0.55)
            .lineLimit(1)

            Text(
                L10n.text("Goal") + " " + formatter.string(
                    milliliters: model.snapshot.goal.value,
                    unit: model.snapshot.unit
                ) + " · " + formatter.percentString(model.snapshot.percent)
            )
            .font(RippleFont.callout.monospacedDigit())
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(longDate(for: model.day))
        .accessibilityValue(
            formatter.heroAccessibility(
                consumedMl: model.snapshot.consumed.value,
                goalMl: model.snapshot.goal.value,
                remainingMl: model.snapshot.remaining.value,
                percent: model.snapshot.percent,
                unit: model.snapshot.unit
            )
        )
    }

    private func longDate(for date: Date) -> String {
        date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .year()
                .locale(locale)
        )
    }

    private func time(for date: Date) -> String {
        date.formatted(
            .dateTime
                .hour()
                .minute()
                .locale(locale)
        )
    }
}

private struct WatchIntakeDetailRow: View {
    let intake: Intake
    let amountText: String
    let containerName: String?
    let sourceText: String
    let timeText: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
            VStack(alignment: .leading, spacing: RippleSpace.grid) {
                Text(timeText)
                    .font(RippleFont.callout.monospacedDigit())

                Text(detailText)
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: RippleSpace.xs)

            Text(amountText)
                .font(RippleFont.callout.monospacedDigit())
                .lineLimit(1)
        }
        .padding(.vertical, RippleSpace.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(timeText)
        .accessibilityValue(detailText + " · " + amountText)
    }

    private var detailText: String {
        [containerName, sourceText]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}
#endif
