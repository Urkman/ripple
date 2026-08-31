import SwiftUI

public struct AmountStepper: View {
    @Binding public var milliliters: Int
    public var step: Int
    public var range: ClosedRange<Int>
    public var formatted: String

    public init(
        milliliters: Binding<Int>,
        step: Int = 50,
        range: ClosedRange<Int> = 50...2000,
        formatted: String
    ) {
        self._milliliters = milliliters
        self.step = step
        self.range = range
        self.formatted = formatted
    }

    public var body: some View {
        HStack {
            Button {
                milliliters = max(range.lowerBound, milliliters - step)
            } label: {
                Image(systemName: "minus.circle.fill")
            }
            .accessibilityLabel("Decrease")

            Text(formatted)
                .font(.title2.monospacedDigit().weight(.semibold))
                .frame(minWidth: 120)
                .contentTransition(.numericText())
                .animation(RippleMotion.springSnappy, value: milliliters)

            Button {
                milliliters = min(range.upperBound, milliliters + step)
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .accessibilityLabel("Increase")
        }
        .foregroundStyle(RippleColor.waterLagoon)
        .font(.title)
    }
}
