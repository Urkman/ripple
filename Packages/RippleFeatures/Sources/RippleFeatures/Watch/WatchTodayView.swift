import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchTodayView: View {
    @State private var model: TodayViewModel
    @State private var crownAmount: Double = 250
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(useCases: UseCases) {
        _model = State(initialValue: TodayViewModel(useCases: useCases))
    }

    public var body: some View {
        let formatter = VolumeFormatter.current
        VStack(spacing: 8) {
            RippleHeroView(
                consumedMl: model.snapshot.consumed.value,
                goalMl: model.snapshot.goal.value,
                addedMl: model.addedMl,
                phase: model.motion,
                reduceMotion: reduceMotion,
                amountText: formatter.valueString(milliliters: model.snapshot.consumed.value, unit: model.snapshot.unit),
                unitText: model.snapshot.unit.symbol,
                percentText: formatter.percentString(model.snapshot.percent),
                accessibilitySummary: formatter.heroAccessibility(
                    consumedMl: model.snapshot.consumed.value,
                    goalMl: model.snapshot.goal.value,
                    remainingMl: model.snapshot.remaining.value,
                    percent: model.snapshot.percent
                )
            )
            Button {
                Task {
                    await model.add(milliliters: Int(crownAmount))
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .accessibilityLabel(L10n.addAmount(formatter.string(milliliters: Int(crownAmount), unit: .milliliters)))
            Text(formatter.string(milliliters: Int(crownAmount), unit: model.snapshot.unit))
                .font(.caption.monospacedDigit())
                .focusable(true)
                .digitalCrownRotation(
                    $crownAmount,
                    from: 50,
                    through: 1000,
                    by: model.snapshot.unit == .fluidOunces ? 30 : 50,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
            ForEach(Array(model.snapshot.entries.suffix(3))) { intake in
                Text("\(formatter.string(milliliters: intake.amountMl, unit: model.snapshot.unit)) · \(intake.date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .task { await model.refresh() }
    }
}
#endif
