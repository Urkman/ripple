import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchCustomAmountView: View {
    let model: WatchTodayViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    public init(model: WatchTodayViewModel) {
        self.model = model
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let selection = model.crownSelection

        VStack(spacing: RippleSpace.sm) {
            Text(L10n.text("Amount"))
                .font(RippleFont.caption)
                .foregroundStyle(.secondary)

            WatchQuickAmountRow(
                options: amountOptions(formatter: formatter),
                selectedID: selectedOptionID,
                onSelect: selectAmount
            )

            Text(L10n.turnDigitalCrown)
                .font(RippleFont.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: RippleWatchLayout.amountSheetCrownHintWidth)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.text("Amount"))
                .accessibilityValue(
                    formatter.string(milliliters: model.selectedAmountMl, unit: selection.unit)
                )
                .accessibilityHint(L10n.turnDigitalCrown)

            if let errorMessage = model.errorMessage {
                Text(errorMessage)
                    .font(RippleFont.caption)
                    .foregroundStyle(RippleColor.danger)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)

            WatchLogButton(
                title: L10n.addAmount(
                    formatter.string(milliliters: model.selectedAmountMl, unit: selection.unit)
                ),
                isEnabled: !model.isLogging,
                action: add
            )
        }
        .padding(.horizontal, RippleWatchLayout.pageHorizontalPadding)
        .padding(.vertical, RippleWatchLayout.amountSheetVerticalPadding)
        .background(RippleColor.watchSurface.ignoresSafeArea())
        .focusable(true)
        .digitalCrownRotation(
            crownBinding,
            from: selection.crownLowerBound,
            through: selection.crownUpperBound,
            by: Double(WatchAmountSelection.stepMilliliters),
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .presentationDetents([.medium])
    }

    private func add() {
        Task { @MainActor in
            await model.addSelected()
            if model.errorMessage == nil {
                dismiss()
            }
        }
    }

    private var selectedOptionID: String? {
        guard let containerID = model.selectedContainerID else {
            return nil
        }
        return containerOptionID(containerID)
    }

    private func amountOptions(formatter: VolumeFormatter) -> [WatchAmountOption] {
        let predefined = model.quickContainers.map { container in
            WatchAmountOption(
                id: containerOptionID(container.id),
                title: formatter.valueString(
                    milliliters: container.amountMl,
                    unit: model.snapshot.unit
                ),
                subtitle: model.snapshot.unit.symbol,
                kind: .predefined(container.id),
                accessibilityLabel: container.name,
                accessibilityValue: formatter.string(
                    milliliters: container.amountMl,
                    unit: model.snapshot.unit
                )
            )
        }
        return predefined
    }

    private func selectAmount(_ option: WatchAmountOption) {
        guard case .predefined(let id) = option.kind,
              let container = model.quickContainers.first(where: { $0.id == id }) else {
            return
        }
        model.select(container: container)
    }

    private var crownBinding: Binding<Double> {
        Binding(
            get: { Double(model.selectedAmountMl) },
            set: { model.updateCrown($0) }
        )
    }

    private func containerOptionID(_ id: UUID) -> String {
        "container-\(id.uuidString)"
    }
}

#Preview("Watch Custom Amount") {
    let model = WatchTodayViewModel(useCases: RippleRuntime.preview)
    model.openAmountSheet()
    return WatchCustomAmountView(model: model)
}

#Preview("Watch Custom Amount · Dark · XXXL") {
    let model = WatchTodayViewModel(useCases: RippleRuntime.preview)
    model.openAmountSheet()
    return WatchCustomAmountView(model: model)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
