import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchTodayView: View {
    @State private var model: WatchTodayViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale

    public init(model: WatchTodayViewModel) {
        _model = State(initialValue: model)
    }

    public init(useCases: UseCases) {
        self.init(model: WatchTodayViewModel(useCases: useCases))
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let snapshot = model.snapshot
        let foreground = foregroundColor(for: model.waterLevel)

        ZStack(alignment: .top) {
            WatchWaterBackdrop(level: model.waterLevel)
                .animation(levelAnimation, value: model.waterLevel)

            VStack(spacing: 0) {
                header(snapshot: snapshot, formatter: formatter, foreground: foreground)

                Spacer(minLength: RippleSpace.sm)

                dailyReadout(
                    snapshot: snapshot,
                    formatter: formatter,
                    foreground: foreground
                )
                .frame(maxWidth: .infinity)

                Spacer(minLength: RippleSpace.sm)

                bottomDock(
                    snapshot: snapshot,
                    formatter: formatter,
                    foreground: foreground
                )
            }
            .padding(.horizontal, RippleWatchLayout.todayDockPadding)
            .padding(.top, RippleWatchLayout.todayDockPadding)
            .padding(.bottom, RippleWatchLayout.todayDockPadding)
        }
        .background(RippleColor.surface.ignoresSafeArea())
        .sheet(isPresented: customSheetBinding) {
            WatchCustomAmountView(model: model)
        }
        .sensoryFeedback(.success, trigger: model.confirmation)
    }

    private var levelAnimation: Animation {
        if reduceMotion {
            return .easeInOut(duration: RippleMotion.reduceMotionCrossfade)
        }
        return RippleMotion.springLiquid
    }

    private var customSheetBinding: Binding<Bool> {
        Binding(
            get: { model.isCustomPresented },
            set: { isPresented in
                if !isPresented {
                    model.cancelCustom()
                }
            }
        )
    }

    private func foregroundColor(for level: CGFloat) -> Color {
        if colorScheme == .dark, level > 0.70 {
            return RippleColor.surface
        }
        return RippleColor.waterDeep
    }

    private func header(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        foreground: Color
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: RippleSpace.sm) {
            Text(L10n.text("Today"))
                .font(RippleFont.caption.weight(.semibold))

            Spacer(minLength: RippleSpace.sm)

            Text(
                L10n.text("Goal") + " " + formatter.string(
                    milliliters: snapshot.goal.value,
                    unit: snapshot.unit
                )
            )
            .font(RippleFont.caption.monospacedDigit())
            .lineLimit(1)
        }
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
            Text(formatter.valueString(milliliters: snapshot.consumed.value, unit: snapshot.unit))
                .font(RippleFont.display)
                .minimumScaleFactor(0.55)
                .lineLimit(1)

            Text(snapshot.unit.symbol)
                .font(RippleFont.callout.weight(.semibold))

            Text(
                formatter.remainingPhrase(
                    milliliters: snapshot.remaining.value,
                    unit: snapshot.unit
                )
            )
            .font(RippleFont.callout)
            .lineLimit(1)
            .minimumScaleFactor(0.75)

            Text(formatter.percentString(snapshot.percent))
                .font(RippleFont.caption.monospacedDigit())
                .opacity(0.82)
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
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter,
        foreground: Color
    ) -> some View {
        VStack(spacing: RippleSpace.xs) {
            WatchQuickAmountRow(
                options: amountOptions(snapshot: snapshot, formatter: formatter),
                selectedID: selectedOptionID,
                onSelect: selectAmount
            )

            WatchLogButton(
                title: L10n.addAmount(
                    formatter.string(
                        milliliters: model.selectedAmountMl,
                        unit: snapshot.unit
                    )
                ),
                isEnabled: !model.isLogging,
                action: addSelectedAmount
            )

            if let confirmation = model.confirmation {
                Text(confirmation)
                    .font(RippleFont.caption)
                    .foregroundStyle(RippleColor.success)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .transition(.opacity)
                    .accessibilityAddTraits(.updatesFrequently)
            }

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
                .fill(RippleColor.surface.opacity(0.90))
        )
        .overlay {
            RoundedRectangle(cornerRadius: RippleRadius.card, style: .continuous)
                .stroke(foreground.opacity(0.12), lineWidth: 1)
        }
        .animation(.easeInOut(duration: RippleMotion.confirmFade), value: model.confirmation)
        .accessibilityElement(children: .contain)
    }

    private var selectedOptionID: String? {
        guard let containerID = model.selectedContainerID else {
            return model.isCustomPresented ? "custom" : nil
        }
        return containerOptionID(containerID)
    }

    private func amountOptions(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter
    ) -> [WatchAmountOption] {
        let predefined = model.quickContainers.map { container in
            WatchAmountOption(
                id: containerOptionID(container.id),
                title: container.name,
                subtitle: formatter.string(
                    milliliters: container.amountMl,
                    unit: snapshot.unit
                ),
                kind: .predefined(container.id)
            )
        }
        let custom = WatchAmountOption(
            id: "custom",
            title: L10n.custom,
            subtitle: "+",
            kind: .custom
        )
        return predefined + [custom]
    }

    private func selectAmount(_ option: WatchAmountOption) {
        switch option.kind {
        case .predefined(let id):
            guard let container = model.quickContainers.first(where: { $0.id == id }) else { return }
            model.select(container: container)
        case .custom:
            model.openCustom()
        }
    }

    private func addSelectedAmount() {
        Task { await model.addSelected() }
    }

    private func containerOptionID(_ id: UUID) -> String {
        "container-\(id.uuidString)"
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
