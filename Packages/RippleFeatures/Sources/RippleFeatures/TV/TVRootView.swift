import RippleDomain
import RippleUI
import SwiftUI

#if os(tvOS)
public struct TVRootView: View {
    @State private var model: TodayViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(useCases: UseCases) {
        _model = State(initialValue: TodayViewModel(useCases: useCases))
    }

    public var body: some View {
        let formatter = VolumeFormatter.current
        VStack(spacing: 40) {
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
            HStack(spacing: 24) {
                ForEach([250, 500, 750], id: \.self) { amount in
                    Button("+ \(amount) ml") {
                        Task { await model.add(milliliters: amount) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(60)
        .background(RippleColor.surface)
        .task { await model.refresh() }
    }
}
#endif
