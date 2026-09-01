import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchCustomAmountView: View {
    let model: WatchTodayViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var crownValue: Double

    public init(model: WatchTodayViewModel) {
        self.model = model
        _crownValue = State(initialValue: model.customSelection.crownValue)
    }

    public var body: some View {
        let formatter = VolumeFormatter(locale: locale)
        let selection = model.customSelection

        VStack(spacing: RippleSpace.md) {
            VStack(spacing: RippleSpace.xs) {
                Text(L10n.text("Custom amount"))
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)

                Text(formatter.valueString(milliliters: selection.milliliters, unit: selection.unit))
                    .font(RippleFont.display)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)

                Text(selection.unit.symbol)
                    .font(RippleFont.callout.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.text("Amount"))
            .accessibilityValue(
                formatter.string(milliliters: selection.milliliters, unit: selection.unit)
            )

            Text(L10n.text("Turn the Digital Crown"))
                .font(RippleFont.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

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
                    formatter.string(milliliters: selection.milliliters, unit: selection.unit)
                ),
                isEnabled: !model.isLogging,
                action: add
            )

            Button(L10n.text("Cancel"), action: cancel)
                .font(RippleFont.callout)
                .frame(maxWidth: .infinity, minHeight: RippleWatchLayout.controlHeight)
                .foregroundStyle(RippleColor.waterDeep)
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.text("Cancel"))
        }
        .padding(.horizontal, RippleWatchLayout.pageHorizontalPadding)
        .padding(.vertical, RippleSpace.md)
        .focusable(true)
        .digitalCrownRotation(
            $crownValue,
            from: selection.crownLowerBound,
            through: selection.crownUpperBound,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            model.updateCustomCrown(newValue)
        }
        .onAppear {
            crownValue = model.customSelection.crownValue
        }
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

    private func cancel() {
        model.cancelCustom()
        dismiss()
    }
}

#Preview("Watch Custom Amount") {
    let model = WatchTodayViewModel(useCases: RippleRuntime.preview)
    model.openCustom()
    return WatchCustomAmountView(model: model)
}

#Preview("Watch Custom Amount · Dark · XXXL") {
    let model = WatchTodayViewModel(useCases: RippleRuntime.preview)
    model.openCustom()
    return WatchCustomAmountView(model: model)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
