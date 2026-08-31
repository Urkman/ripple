import ActivityKit
import RippleData
import RippleDomain
import RippleIntentsCore
import RippleUI
import SwiftUI
import WidgetKit

struct RippleLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RippleActivityAttributes.self) { context in
            lockScreen(context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(RippleColor.waterAqua)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(percent(context))%")
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(remaining(context))
                        Spacer()
                        Button(intent: LogWaterIntent(milliliters: context.state.defaultAddMl, source: .liveActivity)) {
                            Text("+\(context.state.defaultAddMl)")
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "drop.fill")
            } compactTrailing: {
                Text("\(percent(context))%")
                    .monospacedDigit()
            } minimal: {
                Text("\(percent(context))")
                    .monospacedDigit()
            }
        }
    }

    @ViewBuilder
    private func lockScreen(_ context: ActivityViewContext<RippleActivityAttributes>) -> some View {
        HStack {
            RippleHeroView(
                consumedMl: context.state.consumedMl,
                goalMl: context.state.goalMl,
                phase: .idle,
                reduceMotion: false,
                animatesPour: false,
                showsPour: false,
                amountText: VolumeFormatter.current.valueString(milliliters: context.state.consumedMl, unit: .milliliters),
                unitText: VolumeUnit.milliliters.symbol,
                percentText: "\(percent(context))\u{00A0}%",
                accessibilitySummary: VolumeFormatter.current.heroAccessibility(
                    consumedMl: context.state.consumedMl,
                    goalMl: context.state.goalMl,
                    remainingMl: max(context.state.goalMl - context.state.consumedMl, 0),
                    percent: Double(percent(context)) / 100
                )
            )
            .frame(width: 72, height: 100)
            VStack(alignment: .leading) {
                Text("\(context.state.consumedMl) ml")
                    .font(.title2.monospacedDigit().weight(.semibold))
                Text(remaining(context))
                    .font(.caption)
            }
            Spacer()
            Button(intent: LogWaterIntent(milliliters: context.state.defaultAddMl, source: .liveActivity)) {
                Text("+\(context.state.defaultAddMl)")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .activityBackgroundTint(RippleColor.waterFoam)
    }

    private func percent(_ context: ActivityViewContext<RippleActivityAttributes>) -> Int {
        guard context.state.goalMl > 0 else { return 0 }
        return Int((Double(context.state.consumedMl) / Double(context.state.goalMl) * 100).rounded())
    }

    private func remaining(_ context: ActivityViewContext<RippleActivityAttributes>) -> String {
        let left = max(context.state.goalMl - context.state.consumedMl, 0)
        return VolumeFormatter.current.remainingPhrase(milliliters: left, unit: VolumeUnit(rawValue: context.state.unitRaw) ?? .milliliters)
    }
}
