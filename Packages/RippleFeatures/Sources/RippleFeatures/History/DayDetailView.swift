#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

public struct DayDetailView: View {
    @State private var model: DayDetailViewModel
    @Environment(\.locale) private var locale

    public init(day: Date, useCases: UseCases) {
        _model = State(initialValue: DayDetailViewModel(useCases: useCases, day: day))
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        List {
            Section {
                VStack(alignment: .leading, spacing: RippleSpace.sm) {
                    Text(snapshot.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(RippleFont.title)
                        .foregroundStyle(RippleColor.waterDeep)
                    Text(formatter.string(milliliters: snapshot.consumed.value, unit: snapshot.unit))
                        .font(RippleFont.display)
                        .foregroundStyle(RippleColor.waterDeep)
                    Text("\(L10n.text("Goal")) \(formatter.string(milliliters: snapshot.goal.value, unit: snapshot.unit))")
                        .font(RippleFont.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Text(formatter.percentString(snapshot.percent))
                        .font(RippleFont.title.monospacedDigit())
                    Text(caption(formatter: formatter, snapshot: snapshot))
                        .font(RippleFont.callout.monospacedDigit())
                        .foregroundStyle(RippleColor.waterLagoon)
                }
                .listRowBackground(Color.clear)
            }

            Section {
                if snapshot.entries.isEmpty {
                    VStack(alignment: .leading, spacing: RippleSpace.md) {
                        Text(L10n.text("No entries"))
                            .font(RippleFont.body)
                            .foregroundStyle(.secondary)
                        if model.isToday {
                            Button(addTitle(formatter: formatter), action: addDefault)
                        }
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
            }
        }
        .scrollContentBackground(.hidden)
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .navigationTitle(L10n.text("History"))
        .rippleInlineNavigationTitle()
        .toolbar {
            if model.isToday {
                ToolbarItem(placement: .primaryAction) {
                    Button(addTitle(formatter: formatter), systemImage: "plus", action: addDefault)
                }
            }
        }
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
        .task { await model.refresh() }
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

    private func addDefault() {
        Task { await model.addDefault() }
    }

    private func undoDelete() {
        Task { await model.undoDelete() }
    }

    private func delete(_ intake: Intake) {
        Task { await model.delete(intake) }
    }

    private func addTitle(formatter: VolumeFormatter) -> String {
        "+ \(formatter.string(milliliters: model.snapshot.defaultAddMl, unit: model.snapshot.unit))"
    }

    private func caption(formatter: VolumeFormatter, snapshot: TodaySnapshot) -> String {
        if snapshot.isGoalMet {
            return L10n.text("Goal reached")
        }
        return formatter.remainingPhrase(milliliters: snapshot.remaining.value, unit: snapshot.unit)
    }
}
#endif
