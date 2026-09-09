#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

public struct DayDetailView: View {
    @State private var model: DayDetailViewModel
    private let refreshID: Int
    private let onAdd: (() -> Void)?
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.rippleHistorySplit) private var usesSplit

    public init(
        day: Date,
        useCases: UseCases,
        refreshID: Int = 0,
        onAdd: (() -> Void)? = nil
    ) {
        _model = State(initialValue: DayDetailViewModel(useCases: useCases, day: day))
        self.refreshID = refreshID
        self.onAdd = onAdd
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        let goalText = L10n.text("Goal") + " " + formatter.string(
            milliliters: snapshot.goal.value,
            unit: snapshot.unit
        )
        List {
            Section {
                DayDetailSummaryView(
                    date: snapshot.date,
                    consumedMl: snapshot.consumed.value,
                    goalMl: snapshot.goal.value,
                    amountText: formatter.valueString(
                        milliliters: snapshot.consumed.value,
                        unit: snapshot.unit
                    ),
                    unitText: snapshot.unit.symbol,
                    percentText: formatter.percentString(snapshot.percent),
                    goalText: goalText,
                    captionText: caption(formatter: formatter, snapshot: snapshot),
                    accessibilitySummary: formatter.heroAccessibility(
                        consumedMl: snapshot.consumed.value,
                        goalMl: snapshot.goal.value,
                        remainingMl: snapshot.remaining.value,
                        percent: snapshot.percent,
                        unit: snapshot.unit
                    ),
                    reduceMotion: reduceMotion
                )
                .listRowBackground(Color.clear)
            }

            Section {
                if snapshot.entries.isEmpty {
                    VStack(alignment: .leading, spacing: RippleSpace.md) {
                        Text(L10n.text("No entries"))
                            .font(RippleFont.body)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(snapshot.entries) { intake in
                        Button {
                            model.editing = intake
                        } label: {
                            IntakeRow(
                                amount: formatter.string(milliliters: intake.amountMl, unit: snapshot.unit),
                                time: intake.date.formatted(date: .omitted, time: .shortened),
                                source: L10n.source(intake.source),
                                container: model.containerName(for: intake)
                            )
                        }
                        .foregroundStyle(.primary)
                        .swipeActions {
                            Button(L10n.text("Delete"), systemImage: "trash", role: .destructive) {
                                delete(intake)
                            }
                        }
                    }
                }
            } header: {
                entriesHeader
            }
        }
        .scrollContentBackground(.hidden)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .navigationTitle(usesSplit ? "" : L10n.text("History"))
        .rippleInlineNavigationTitle()
        .rippleNavigationBarBackground(RippleColor.waterFoam)
        .safeAreaInset(edge: .bottom) {
            if model.undoIntakeID != nil {
                HStack {
                    Text(L10n.text("Deleted"))
                        .font(RippleFont.body)
                    Spacer()
                    Button(L10n.text("Undo"), action: undoDelete)
                }
                .padding(RippleSpace.lg)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: RippleRadius.control, style: .continuous))
                .padding(.horizontal, RippleSpace.lg)
                .padding(.bottom, RippleSpace.sm)
            }
        }
        .task(id: refreshID) { await model.refresh() }
        .sheet(item: $model.editing) { intake in
            EditIntakeSheet(
                intake: intake,
                containers: snapshot.containers,
                unit: snapshot.unit
            ) { amount, date, containerId in
                Task { await model.saveEdit(amountMl: amount, date: date, containerId: containerId) }
            }
        }
    }

    private var entriesHeader: some View {
        HStack {
            Text(L10n.text("Entries"))
                .font(RippleFont.title)
                .foregroundStyle(RippleColor.waterDeep)

            Spacer()

            if model.isToday, let onAdd {
                Button(L10n.text("Custom amount"), systemImage: "plus", action: onAdd)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel(L10n.text("Custom amount"))
            }
        }
        .textCase(nil)
    }

    private func undoDelete() {
        Task { await model.undoDelete() }
    }

    private func delete(_ intake: Intake) {
        Task { await model.delete(intake) }
    }

    private func caption(formatter: VolumeFormatter, snapshot: TodaySnapshot) -> String {
        if snapshot.isGoalMet {
            return L10n.text("Goal reached")
        }
        return formatter.remainingPhrase(milliliters: snapshot.remaining.value, unit: snapshot.unit)
    }
}

private struct DayDetailSummaryView: View {
    let date: Date
    let consumedMl: Int
    let goalMl: Int
    let amountText: String
    let unitText: String
    let percentText: String
    let goalText: String
    let captionText: String
    let accessibilitySummary: String
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: RippleSpace.sm) {
            Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(RippleFont.title)
                .foregroundStyle(RippleColor.waterDeep)

            RippleHeroView(
                consumedMl: consumedMl,
                goalMl: goalMl,
                phase: .idle,
                reduceMotion: reduceMotion,
                animatesPour: false,
                showsPour: false,
                expandsToFit: false,
                tilt: 0,
                slosh: 0,
                amountText: amountText,
                unitText: unitText,
                percentText: percentText,
                accessibilitySummary: accessibilitySummary
            )
            .frame(maxWidth: .infinity)

            Text(goalText)
                .font(RippleFont.body.monospacedDigit())
                .foregroundStyle(.secondary)
            Text(captionText)
                .font(RippleFont.callout.monospacedDigit())
                .foregroundStyle(RippleColor.waterLagoon)
        }
    }
}

#Preview("Day detail summary · Light") {
    DayDetailSummaryView(
        date: .now,
        consumedMl: 1_250,
        goalMl: 2_000,
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        goalText: "Goal 2\u{202F}000 ml",
        captionText: "750 ml left",
        accessibilitySummary: "1 250 milliliters of 2 000. 62 percent. 750 milliliters left.",
        reduceMotion: false
    )
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("Day detail summary · Dark") {
    DayDetailSummaryView(
        date: .now,
        consumedMl: 1_250,
        goalMl: 2_000,
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        goalText: "Goal 2\u{202F}000 ml",
        captionText: "750 ml left",
        accessibilitySummary: "1 250 milliliters of 2 000. 62 percent. 750 milliliters left.",
        reduceMotion: false
    )
    .padding()
    .background(RippleColor.surface)
    .preferredColorScheme(.dark)
}

#Preview("Day detail summary · XXXL") {
    DayDetailSummaryView(
        date: .now,
        consumedMl: 1_250,
        goalMl: 2_000,
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        goalText: "Goal 2\u{202F}000 ml",
        captionText: "750 ml left",
        accessibilitySummary: "1 250 milliliters of 2 000. 62 percent. 750 milliliters left.",
        reduceMotion: false
    )
    .padding()
    .background(RippleColor.waterFoam)
    .dynamicTypeSize(.accessibility3)
}

#Preview("Day detail summary · Reduce Motion") {
    DayDetailSummaryView(
        date: .now,
        consumedMl: 1_250,
        goalMl: 2_000,
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        goalText: "Goal 2\u{202F}000 ml",
        captionText: "750 ml left",
        accessibilitySummary: "1 250 milliliters of 2 000. 62 percent. 750 milliliters left.",
        reduceMotion: true
    )
    .padding()
    .background(RippleColor.waterFoam)
}
#endif
