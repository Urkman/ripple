import RippleDomain
import RippleUI
import SwiftUI

public struct SettingsView: View {
    @Bindable var model: SettingsViewModel

    public init(model: SettingsViewModel) {
        self.model = model
    }

    public var body: some View {
        Form {
            profileSection
            goalSection
            containersSection
            remindersSection
            healthSection
            syncSection
            exportSection
            aboutSection
        }
        .navigationTitle(L10n.text("Settings"))
        .task { await model.refresh() }
    }

    private var profileSection: some View {
        Section(L10n.text("Profile")) {
            Picker(L10n.text("Units"), selection: $model.profile.preferredUnit) {
                Text("ml").tag(VolumeUnit.milliliters)
                Text("fl oz").tag(VolumeUnit.fluidOunces)
            }
            .onChange(of: model.profile.preferredUnit) { _, _ in
                Task { await model.saveProfile() }
            }

            Toggle(L10n.text("Haptics"), isOn: $model.profile.hapticsEnabled)
                .onChange(of: model.profile.hapticsEnabled) { _, _ in
                    Task { await model.saveProfile() }
                }

            Picker(L10n.text("Activity"), selection: $model.profile.activityLevel) {
                Text(L10n.text("Sedentary")).tag(ActivityLevel.sedentary)
                Text(L10n.text("Moderate")).tag(ActivityLevel.moderate)
                Text(L10n.text("High")).tag(ActivityLevel.high)
            }
            .onChange(of: model.profile.activityLevel) { _, _ in
                Task { await model.saveProfile() }
            }
        }
    }

    private var goalSection: some View {
        Section(L10n.text("Daily goal")) {
            Picker(L10n.text("Mode"), selection: $model.goal.mode) {
                Text(L10n.text("Manual")).tag(GoalMode.manual)
                Text(L10n.text("Calculated")).tag(GoalMode.calculated)
            }
            .onChange(of: model.goal.mode) { _, _ in
                Task { await model.saveGoal() }
            }
            Stepper(
                VolumeFormatter.current.string(milliliters: model.goal.manualGoalMl, unit: model.profile.preferredUnit),
                value: $model.goal.manualGoalMl,
                in: 250...6000,
                step: 50
            )
            .onChange(of: model.goal.manualGoalMl) { _, _ in
                Task { await model.saveGoal() }
            }
            Text(L10n.text("This is not medical advice."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var containersSection: some View {
        Section(L10n.text("Containers")) {
            ForEach(model.containers) { container in
                HStack {
                    Image(systemName: container.symbolName)
                    Text(container.name)
                    Spacer()
                    Text(VolumeFormatter.current.string(milliliters: container.amountMl, unit: model.profile.preferredUnit))
                        .foregroundStyle(.secondary)
                    if container.isDefault {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RippleColor.waterLagoon)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task { await model.deleteContainer(container) }
                    } label: {
                        Label(L10n.text("Delete"), systemImage: "trash")
                    }
                }
            }
            Button(L10n.text("Add container")) {
                Task {
                    let next = Container(
                        name: L10n.text("Glass"),
                        amountMl: 250,
                        isDefault: model.containers.isEmpty,
                        sort: (model.containers.map(\.sort).max() ?? -1) + 1,
                        symbolName: "drop.fill"
                    )
                    await model.saveContainer(next)
                }
            }
        }
    }

    private var remindersSection: some View {
        Section(L10n.text("Reminders")) {
            Toggle(L10n.text("Reminders"), isOn: $model.reminder.enabled)
                .onChange(of: model.reminder.enabled) { _, _ in
                    Task { await model.saveProfile() }
                }
            Stepper(
                "\(model.reminder.afterLastSipMinutes) min",
                value: $model.reminder.afterLastSipMinutes,
                in: 30...240,
                step: 15
            )
            .onChange(of: model.reminder.afterLastSipMinutes) { _, _ in
                Task { await model.saveProfile() }
            }
        }
    }

    private var healthSection: some View {
        Section(L10n.text("Health")) {
            LabeledContent(L10n.text("Write water")) {
                Text(model.health.waterWrite ? L10n.text("On") : L10n.text("Off"))
            }
            Button(L10n.text("Allow Health write")) {
                Task { await model.requestHealthWrite() }
            }
            Toggle(L10n.text("Read workouts for goal"), isOn: $model.profile.healthReadWorkoutsEnabled)
                .onChange(of: model.profile.healthReadWorkoutsEnabled) { _, newValue in
                    if newValue {
                        Task { await model.requestWorkouts() }
                    } else {
                        Task { await model.saveProfile() }
                    }
                }
        }
    }

    private var syncSection: some View {
        Section(L10n.text("Sync")) {
            SyncStatusView(
                title: L10n.text("iCloud"),
                detail: syncDetail,
                systemImage: "icloud"
            )
        }
    }

    private var exportSection: some View {
        Section(L10n.text("Export")) {
            Button(L10n.text("Prepare export")) {
                Task { await model.export() }
            }
            #if os(iOS) || os(macOS) || os(visionOS)
            if let payload = model.exportPayload {
                ShareLink(
                    item: JSONFile(data: payload.json, name: payload.suggestedJSONName),
                    preview: SharePreview(payload.suggestedJSONName)
                ) {
                    Label(L10n.text("Share JSON"), systemImage: "square.and.arrow.up")
                }
                ShareLink(
                    item: CSVFile(data: payload.csv, name: payload.suggestedCSVName),
                    preview: SharePreview(payload.suggestedCSVName)
                ) {
                    Label(L10n.text("Share CSV"), systemImage: "tablecells")
                }
            }
            #endif
        }
    }

    private var aboutSection: some View {
        Section(L10n.text("About")) {
            LabeledContent("Ripple", value: "1.0")
            Text(L10n.text("MIT License. Open source water tracker."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var syncDetail: String {
        switch model.syncStatus {
        case .available: L10n.text("Account available")
        case .importing: L10n.text("Importing")
        case .failed(let message): message
        case .unavailable: L10n.text("Unavailable — local store")
        }
    }
}

private struct JSONFile: Transferable {
    var data: Data
    var name: String
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.data }
    }
}

private struct CSVFile: Transferable {
    var data: Data
    var name: String
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { $0.data }
    }
}
