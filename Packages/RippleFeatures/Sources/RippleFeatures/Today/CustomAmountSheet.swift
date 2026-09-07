import Foundation
import RippleDomain
import RippleUI
import SwiftUI

public struct CustomAmountSheet: View {
    private static let amountRange = 50...2000

    let model: TodayViewModel
    let unit: VolumeUnit

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @FocusState private var amountFieldFocused: Bool
    @State private var amountMl: Int
    @State private var amountText: String
    @State private var validationMessage: String?

    public init(
        model: TodayViewModel,
        initialAmountMl: Int,
        initialAmountText: String,
        unit: VolumeUnit
    ) {
        self.model = model
        self.unit = unit
        _amountMl = State(initialValue: initialAmountMl)
        _amountText = State(initialValue: initialAmountText)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: RippleSpace.xl) {
                VStack(spacing: RippleSpace.sm) {
                    TextField(L10n.text("Amount"), text: $amountText)
                        .font(RippleFont.display)
                        .multilineTextAlignment(.center)
                        .focused($amountFieldFocused)
                        .onChange(of: amountText) { _, _ in
                            updateAmountFromText()
                        }
                        .onSubmit(add)
                        .accessibilityLabel(L10n.text("Amount"))
                        .accessibilityValue("\(amountText) \(unit.symbol)")

                    Text(unit.symbol)
                        .font(RippleFont.callout)
                        .foregroundStyle(.secondary)
                }

                AmountStepper(
                    milliliters: $amountMl,
                    range: Self.amountRange,
                    formatted: formatter.string(milliliters: amountMl, unit: unit)
                )
                .onChange(of: amountMl) { _, newAmount in
                    amountText = formatter.valueString(milliliters: newAmount, unit: unit)
                    validationMessage = nil
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(RippleFont.caption)
                        .foregroundStyle(RippleColor.danger)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)

                LogButton(L10n.text("Add"), action: add)
                    .accessibilityLabel(
                        L10n.addAmount(
                            formatter.string(milliliters: amountMl, unit: unit)
                        )
                    )
            }
            .padding(RippleSpace.xl)
            .navigationTitle(L10n.text("Custom amount"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel"), action: dismiss.callAsFunction)
                }
            }
        }
        .presentationDetents([.medium])
        .task {
            amountFieldFocused = true
        }
    }

    private var formatter: VolumeFormatter {
        VolumeFormatter(locale: locale)
    }

    private func updateAmountFromText() {
        guard let parsedAmount = parsedAmount else { return }
        amountMl = parsedAmount
        validationMessage = nil
    }

    private var parsedAmount: Int? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .decimal
        numberFormatter.generatesDecimalNumbers = true

        let normalizedText = amountText.filter { !$0.isWhitespace }
        guard let number = numberFormatter.number(from: normalizedText) else { return nil }
        let milliliters = UnitConverter.milliliters(amount: number.doubleValue, unit: unit)
        guard Self.amountRange.contains(milliliters) else { return nil }
        return milliliters
    }

    private func add() {
        guard let amount = parsedAmount else {
            validationMessage = L10n.text("Enter a valid amount")
            return
        }

        Task { @MainActor in
            await model.add(milliliters: amount)
            dismiss()
        }
    }
}

#Preview("Custom amount · Light") {
    CustomAmountSheet(
        model: TodayViewModel(useCases: RippleRuntime.preview, snapshot: .empty()),
        initialAmountMl: 250,
        initialAmountText: "250",
        unit: .milliliters
    )
}

#Preview("Custom amount · Dark · XXXL · Reduce Motion") {
    CustomAmountSheet(
        model: TodayViewModel(useCases: RippleRuntime.preview, snapshot: .empty()),
        initialAmountMl: 250,
        initialAmountText: "250",
        unit: .milliliters
    )
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.xxxLarge)
}
