import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchTodayView: View {
    @State private var model: WatchTodayViewModel
    @State private var wristMotion: WristMotionController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale

    public init(model: WatchTodayViewModel) {
        _model = State(initialValue: model)
        _wristMotion = State(initialValue: WristMotionController())
    }

    public init(useCases: UseCases) {
        self.init(model: WatchTodayViewModel(useCases: useCases))
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        let foreground = foregroundColor(for: model.waterLevel)

        ZStack(alignment: .top) {
            WatchWaterBackdrop(
                level: model.waterLevel,
                motionTrigger: wristMotion.trigger,
                motionEnabled: !reduceMotion
            )
                .animation(levelAnimation, value: model.waterLevel)

            VStack(spacing: 0) {
                header(snapshot: snapshot, formatter: formatter, foreground: foreground)

                Spacer(minLength: 0)

                dailyReadout(
                    snapshot: snapshot,
                    formatter: formatter,
                    foreground: foreground
                )
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                bottomDock(
                    foreground: foreground
                )
            }
            .padding(.horizontal, RippleWatchLayout.todayDockPadding)
            .padding(.top, RippleWatchLayout.todayTopInset)
            .padding(.bottom, RippleWatchLayout.todayBottomInset)
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .background(RippleColor.watchSurface.ignoresSafeArea())
        .sheet(isPresented: amountSheetBinding) {
            WatchCustomAmountView(model: model)
        }
        .onAppear {
            updateWristMotion(isReduceMotionEnabled: reduceMotion)
        }
        .onDisappear {
            wristMotion.stop()
        }
        .onChange(of: reduceMotion) { _, isReduceMotionEnabled in
            updateWristMotion(isReduceMotionEnabled: isReduceMotionEnabled)
        }
        .sensoryFeedback(.success, trigger: model.successFeedback)
    }

    private var levelAnimation: Animation {
        if reduceMotion {
            return .easeInOut(duration: RippleMotion.reduceMotionCrossfade)
        }
        return RippleMotion.springLiquid
    }

    private var amountSheetBinding: Binding<Bool> {
        Binding(
            get: { model.isAmountSheetPresented },
            set: { isPresented in
                if !isPresented {
                    model.dismissAmountSheet()
                }
            }
        )
    }

    private func foregroundColor(for level: CGFloat) -> Color {
        if level > 0.70 {
            return RippleColor.watchSurface
        }
        return RippleColor.watchText
    }

    private func header(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        foreground: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: RippleWatchLayout.todayContentSpacing) {
            Text(L10n.text("Today"))
                .font(RippleFont.caption.weight(.semibold))

            Text(
                L10n.text("Goal") + " " + formatter.string(
                    milliliters: snapshot.goal.value,
                    unit: snapshot.unit
                )
            )
            .font(RippleFont.caption.monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(foreground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.text("Today"))
        .accessibilityValue(
            L10n.text("Goal") + " " + formatter.string(
                milliliters: snapshot.goal.value,
                unit: snapshot.unit
            )
        )
    }

    private func dailyReadout(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        foreground: Color
    ) -> some View {
        VStack(spacing: RippleSpace.xs) {
            Text(formatter.string(milliliters: snapshot.consumed.value, unit: snapshot.unit))
                .font(RippleFont.display)
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .allowsTightening(true)

            HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
                Text(
                    formatter.remainingPhrase(
                        milliliters: snapshot.remaining.value,
                        unit: snapshot.unit
                    )
                )
                .font(RippleFont.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

                Text(formatter.percentString(snapshot.percent))
                    .font(RippleFont.caption.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .opacity(0.82)
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(foreground)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.text("Today"))
        .accessibilityValue(
            formatter.heroAccessibility(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value,
                remainingMl: snapshot.remaining.value,
                percent: snapshot.percent,
                unit: snapshot.unit
            )
        )
    }

    private func bottomDock(
        foreground: Color
    ) -> some View {
        VStack(spacing: RippleSpace.xs) {
            WatchLogButton(
                title: "+",
                isEnabled: !model.isLogging,
                action: openAmountSheet,
                font: RippleFont.title.monospacedDigit(),
                accessibilityLabel: L10n.text("Add")
            )

            if let errorMessage = model.errorMessage {
                Text(errorMessage)
                    .font(RippleFont.caption)
                    .foregroundStyle(RippleColor.danger)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .padding(RippleWatchLayout.todayDockPadding)
        .background(
            RoundedRectangle(cornerRadius: RippleRadius.card, style: .continuous)
                .fill(RippleColor.watchSurface.opacity(0.90))
        )
        .overlay {
            RoundedRectangle(cornerRadius: RippleRadius.card, style: .continuous)
                .stroke(foreground.opacity(0.12), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private func openAmountSheet() {
        model.openAmountSheet()
    }

    private func updateWristMotion(isReduceMotionEnabled: Bool) {
        if isReduceMotionEnabled {
            wristMotion.stop()
        } else {
            wristMotion.start()
        }
    }
}

#Preview("Watch Today") {
    WatchTodayView(model: WatchTodayViewModel(useCases: RippleRuntime.preview))
}

#Preview("Watch Today · Dark · XXXL · Reduce Motion") {
    WatchTodayView(model: WatchTodayViewModel(useCases: RippleRuntime.preview))
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
