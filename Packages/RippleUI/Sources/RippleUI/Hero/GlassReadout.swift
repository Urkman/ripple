import SwiftUI

struct GlassReadout: View {
    let amountText: String
    let unitText: String
    let percentText: String
    let numberEpoch: Int
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            GlassShape(inset: GlassMetrics.strokeWidth)
                .fill(
                    LinearGradient(
                        colors: [
                            RippleColor.glassHighlight.opacity(0.10),
                            RippleColor.glassHighlight.opacity(0.025),
                            RippleColor.glassHighlight.opacity(0.07),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay {
                    GlassShape(inset: GlassMetrics.strokeWidth)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    RippleColor.glassHighlight.opacity(0.42),
                                    RippleColor.glassHighlight.opacity(0.08),
                                    RippleColor.glassHighlight.opacity(0.26),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                }
                .clipShape(GlassShape(inset: GlassMetrics.strokeWidth))

            VStack(spacing: 0) {
                GlassReadoutPlate {
                    HStack(alignment: .firstTextBaseline, spacing: RippleSpace.xs) {
                        Text(amountText)
                            .font(RippleFont.display)
                            .minimumScaleFactor(0.55)
                            .lineLimit(1)
                            .contentTransition(.numericText())
                            .id(numberEpoch)
                        Text(unitText)
                            .font(.title3.weight(.medium))
                    }
                }
                .padding(.top, RippleSpace.xxl + RippleSpace.xs)

                Spacer(minLength: 0)

                GlassReadoutPlate {
                    Text(percentText)
                        .font(.title2.monospacedDigit())
                        .contentTransition(.numericText())
                        .id("pct-\(numberEpoch)")
                }
                .padding(.bottom, RippleSpace.xxl + RippleSpace.md)
            }
            .padding(.horizontal, RippleSpace.xl + RippleSpace.xs)
        }
        .foregroundStyle(RippleColor.waterDeep)
        .allowsHitTesting(false)
        .animation(
            reduceMotion
                ? .easeInOut(duration: RippleMotion.reduceMotionCrossfade)
                : RippleMotion.springLiquid,
            value: numberEpoch
        )
    }
}

private struct GlassReadoutPlate<Content: View>: View {
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(.horizontal, RippleSpace.md)
            .padding(.vertical, RippleSpace.xs)
            .background(
                RoundedRectangle(
                    cornerRadius: RippleRadius.control,
                    style: .continuous
                )
                .fill(RippleColor.glassHighlight.opacity(0.08))
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: RippleRadius.control,
                    style: .continuous
                )
                .stroke(
                    RippleColor.glassHighlight.opacity(0.24),
                    lineWidth: 1
                )
            }
            .rippleGlass(cornerRadius: RippleRadius.control)
    }
}

#Preview("Glass readout · Light") {
    GlassReadout(
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        numberEpoch: 0,
        reduceMotion: false
    )
    .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("Glass readout · Dark") {
    GlassReadout(
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        numberEpoch: 0,
        reduceMotion: false
    )
    .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
    .padding()
    .background(RippleColor.surface)
    .preferredColorScheme(.dark)
}

#Preview("Glass readout · XXXL") {
    GlassReadout(
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        numberEpoch: 0,
        reduceMotion: false
    )
    .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
    .dynamicTypeSize(.accessibility3)
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("Glass readout · Reduce Motion") {
    GlassReadout(
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        numberEpoch: 0,
        reduceMotion: true
    )
    .frame(width: RippleMotion.heroWidth, height: RippleMotion.heroHeight)
    .padding()
    .background(RippleColor.waterFoam)
}
