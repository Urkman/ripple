#if os(iOS) || os(macOS) || os(visionOS)
import RippleDomain
import RippleUI
import SwiftUI

struct EditIntakeSheet: View {
    let intake: Intake
    let containers: [Container]
    let unit: VolumeUnit
    var onSave: (Int, Date, UUID?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amount: Int
    @State private var date: Date
    @State private var containerId: UUID?

    init(
        intake: Intake,
        containers: [Container],
        unit: VolumeUnit,
        onSave: @escaping (Int, Date, UUID?) -> Void
    ) {
        self.intake = intake
        self.containers = containers
        self.unit = unit
        self.onSave = onSave
        _amount = State(initialValue: intake.amountMl)
        _date = State(initialValue: intake.date)
        _containerId = State(initialValue: intake.containerId)
    }

    var body: some View {
        NavigationStack {
            Form {
                AmountStepper(
                    milliliters: $amount,
                    formatted: VolumeFormatter.current.string(milliliters: amount, unit: unit)
                )
                DatePicker(L10n.text("Time"), selection: $date)
                Picker(L10n.text("Container"), selection: $containerId) {
                    Text(L10n.text("Unknown")).tag(Optional<UUID>.none)
                    ForEach(containers) { container in
                        Text(container.name).tag(Optional(container.id))
                    }
                }
            }
            .navigationTitle(L10n.text("Edit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel"), action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Save"), action: save)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        onSave(amount, date, containerId)
        dismiss()
    }
}
#endif
