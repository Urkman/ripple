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
    @State private var selectedContainerID: UUID?
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
            ScrollView {
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

                    Slider(
                        value: amountBinding,
                        in: Double(Self.amountRange.lowerBound)...Double(Self.amountRange.upperBound),
                        step: 10
                    )
                    .tint(RippleColor.waterLagoon)
                    .accessibilityLabel(L10n.text("Amount"))
                    .accessibilityValue(
                        formatter.string(milliliters: amountMl, unit: unit)
                    )

                    containerSelection

                    if let validationMessage {
                        Text(validationMessage)
                            .font(RippleFont.caption)
                            .foregroundStyle(RippleColor.danger)
                            .multilineTextAlignment(.center)
                    }

                    LogButton(L10n.text("Add"), action: add)
                        .accessibilityLabel(
                            L10n.addAmount(
                                formatter.string(milliliters: amountMl, unit: unit)
                            )
                        )
                }
                .padding(RippleSpace.xl)
            }
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

    private var amountBinding: Binding<Double> {
        Binding(
            get: { Double(amountMl) },
            set: { newValue in
                amountMl = Int(newValue.rounded())
                amountText = formatter.valueString(milliliters: amountMl, unit: unit)
                selectedContainerID = nil
                validationMessage = nil
            }
        )
    }

    @ViewBuilder
    private var containerSelection: some View {
        if !model.snapshot.containers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RippleSpace.sm) {
                    ForEach(model.snapshot.containers) { container in
                        ContainerChip(
                            name: container.name,
                            amount: formatter.string(
                                milliliters: container.amountMl,
                                unit: unit
                            ),
                            symbolName: container.symbolName,
                            isSelected: selectedContainerID == container.id
                        ) {
                            select(container)
                        }
                        .frame(minWidth: RippleLayout.customAmountContainerChipMinimumWidth)
                    }
                }
                .padding(.vertical, RippleSpace.xs)
            }
            .accessibilityLabel(L10n.text("Containers"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func updateAmountFromText() {
        if let selectedContainerID,
           let selectedContainer = model.snapshot.containers.first(where: {
               $0.id == selectedContainerID
           }),
           amountText == formatter.valueString(
               milliliters: selectedContainer.amountMl,
               unit: unit
           ) {
            amountMl = selectedContainer.amountMl
            validationMessage = nil
            return
        }

        guard let parsedAmount = parsedAmount else { return }
        amountMl = parsedAmount
        selectedContainerID = nil
        validationMessage = nil
    }

    private func select(_ container: Container) {
        selectedContainerID = container.id
        amountMl = container.amountMl
        amountText = formatter.valueString(milliliters: container.amountMl, unit: unit)
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
        let selectedContainer = selectedContainerID.flatMap { selectedID in
            model.snapshot.containers.first(where: { $0.id == selectedID })
        }
        let amount: Int

        if let selectedContainer,
           amountText == formatter.valueString(
               milliliters: selectedContainer.amountMl,
               unit: unit
           ) {
            amount = selectedContainer.amountMl
        } else if let parsedAmount {
            amount = parsedAmount
        } else {
            validationMessage = L10n.text("Enter a valid amount")
            return
        }

        Task { @MainActor in
            if let selectedContainer, selectedContainer.amountMl == amount {
                await model.add(container: selectedContainer)
            } else {
                await model.add(milliliters: amount)
            }
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
