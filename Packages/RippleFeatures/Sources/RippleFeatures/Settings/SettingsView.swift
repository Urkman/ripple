import RippleDomain
import RippleUI
import SwiftUI

public struct SettingsView: View {
    @Bindable var model: SettingsViewModel
    @Environment(\.locale) private var locale
    @Environment(\.rippleIPadLayout) private var usesIPadLayout

    public init(model: SettingsViewModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RippleSpace.xl) {
                profileCard
                goalCard
                containersCard
                remindersCard
                healthCard
                syncCard
                exportCard
                aboutCard
            }
            .padding(.horizontal, RippleSpace.lg)
            .padding(.vertical, RippleSpace.lg)
            .frame(maxWidth: RippleLayout.iPadLandscapeContentMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(RippleColor.waterFoam.ignoresSafeArea())
        .navigationTitle(usesIPadLayout ? "" : L10n.text("Settings"))
        .rippleNavigationBarVisibility(hidden: usesIPadLayout)
        .rippleNavigationBarBackground(RippleColor.waterFoam)
        .task { await model.refresh() }
    }

    private var profileCard: some View {
        GlassCard(title: L10n.text("Profile")) {
            VStack(spacing: 0) {
                GlassCardRow(L10n.text("Units")) {
                    Picker(L10n.text("Units"), selection: $model.profile.preferredUnit) {
                        Text(verbatim: "ml").tag(VolumeUnit.milliliters)
                        Text(verbatim: "fl oz").tag(VolumeUnit.fluidOunces)
                    }
                    .labelsHidden()
                    .ripplePickerStyle()
                    .onChange(of: model.profile.preferredUnit) { _, _ in
                        Task { await model.saveProfile() }
                    }
                }

                GlassCardRow(L10n.text("Haptics")) {
                    Toggle(L10n.text("Haptics"), isOn: $model.profile.hapticsEnabled)
                        .labelsHidden()
                        .onChange(of: model.profile.hapticsEnabled) { _, _ in
                            Task { await model.saveProfile() }
                        }
                }

                GlassCardRow(L10n.text("Activity"), showsDivider: false) {
                    Picker(L10n.text("Activity"), selection: $model.profile.activityLevel) {
                        Text(L10n.text("Sedentary")).tag(ActivityLevel.sedentary)
                        Text(L10n.text("Moderate")).tag(ActivityLevel.moderate)
                        Text(L10n.text("High")).tag(ActivityLevel.high)
                    }
                    .labelsHidden()
                    .ripplePickerStyle()
                    .onChange(of: model.profile.activityLevel) { _, _ in
                        Task { await model.saveProfile() }
                    }
                }
            }
        }
    }

    private var goalCard: some View {
        GlassCard(title: L10n.text("Daily goal")) {
            VStack(alignment: .leading, spacing: 0) {
                GlassCardRow(L10n.text("Mode")) {
                    Picker(L10n.text("Mode"), selection: $model.goal.mode) {
                        Text(L10n.text("Manual")).tag(GoalMode.manual)
                        Text(L10n.text("Calculated")).tag(GoalMode.calculated)
                    }
                    .labelsHidden()
                    .ripplePickerStyle()
                    .onChange(of: model.goal.mode) { _, _ in
                        Task { await model.saveGoal() }
                    }
                }

                GlassCardRow(L10n.text("Goal"), showsDivider: false) {
                    Stepper(
                        volumeFormatter.string(milliliters: model.goal.manualGoalMl, unit: model.profile.preferredUnit),
                        value: $model.goal.manualGoalMl,
                        in: 250...6000,
                        step: 50
                    )
                    .labelsHidden()
                    .accessibilityLabel(L10n.text("Daily goal"))
                    .onChange(of: model.goal.manualGoalMl) { _, _ in
                        Task { await model.saveGoal() }
                    }
                }

                Text(L10n.text("This is not medical advice."))
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, RippleSpace.sm)
            }
        }
    }

    private var containersCard: some View {
        GlassCard(title: L10n.text("Containers")) {
            VStack(spacing: 0) {
                ForEach(model.containers) { container in
                    containerRow(
                        container,
                        showsDivider: container.id != model.containers.last?.id
                    )
                }

                Button(action: addContainer) {
                    Label(L10n.text("Add container"), systemImage: "plus")
                        .font(RippleFont.body)
                        .foregroundStyle(RippleColor.waterLagoon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, RippleSpace.md)
            }
        }
    }

    private var remindersCard: some View {
        GlassCard(title: L10n.text("Reminders")) {
            VStack(spacing: 0) {
                GlassCardRow(L10n.text("Reminders")) {
                    Toggle(L10n.text("Reminders"), isOn: $model.reminder.enabled)
                        .labelsHidden()
                        .onChange(of: model.reminder.enabled) { _, _ in
                            Task { await model.saveProfile() }
                        }
                }

                GlassCardRow(L10n.text("After last sip"), showsDivider: false) {
                    Stepper(
                        L10n.minutes(model.reminder.afterLastSipMinutes),
                        value: $model.reminder.afterLastSipMinutes,
                        in: 30...240,
                        step: 15
                    )
                    .labelsHidden()
                    .accessibilityLabel(L10n.text("After last sip"))
                    .onChange(of: model.reminder.afterLastSipMinutes) { _, _ in
                        Task { await model.saveProfile() }
                    }
                }
            }
        }
    }

    private var healthCard: some View {
        GlassCard(title: L10n.text("Health")) {
            VStack(spacing: 0) {
                GlassCardRow(L10n.text("Write water")) {
                    Text(model.health.waterWrite ? L10n.text("On") : L10n.text("Off"))
                        .font(RippleFont.body)
                        .foregroundStyle(.secondary)
                }

                Button(action: requestHealthWrite) {
                    Label(L10n.text("Allow Health write"), systemImage: "heart.text.square")
                        .font(RippleFont.body)
                        .foregroundStyle(RippleColor.waterLagoon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, RippleSpace.md)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(RippleColor.waterDeep.opacity(0.10))
                        .frame(height: 1)
                }

                GlassCardRow(L10n.text("Read workouts for goal"), showsDivider: false) {
                    Toggle(L10n.text("Read workouts for goal"), isOn: $model.profile.healthReadWorkoutsEnabled)
                        .labelsHidden()
                        .onChange(of: model.profile.healthReadWorkoutsEnabled) { _, newValue in
                            if newValue {
                                Task { await model.requestWorkouts() }
                            } else {
                                Task { await model.saveProfile() }
                            }
                        }
                }
            }
        }
    }

    private var syncCard: some View {
        GlassCard(title: L10n.text("Sync")) {
            SyncStatusView(
                title: L10n.text("iCloud"),
                detail: syncDetail,
                systemImage: "icloud"
            )
        }
    }

    private var exportCard: some View {
        GlassCard(title: L10n.text("Export")) {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: prepareExport) {
                    Label(L10n.text("Prepare export"), systemImage: "arrow.down.doc")
                        .font(RippleFont.body)
                        .foregroundStyle(RippleColor.waterLagoon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, RippleSpace.md)

                #if os(iOS) || os(macOS) || os(visionOS)
                if let payload = model.exportPayload {
                    Rectangle()
                        .fill(RippleColor.waterDeep.opacity(0.10))
                        .frame(height: 1)
                    ShareLink(
                        item: JSONFile(data: payload.json, name: payload.suggestedJSONName),
                        preview: SharePreview(payload.suggestedJSONName)
                    ) {
                        Label(L10n.text("Share JSON"), systemImage: "square.and.arrow.up")
                            .font(RippleFont.body)
                            .foregroundStyle(RippleColor.waterLagoon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, RippleSpace.md)
                    ShareLink(
                        item: CSVFile(data: payload.csv, name: payload.suggestedCSVName),
                        preview: SharePreview(payload.suggestedCSVName)
                    ) {
                        Label(L10n.text("Share CSV"), systemImage: "tablecells")
                            .font(RippleFont.body)
                            .foregroundStyle(RippleColor.waterLagoon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, RippleSpace.md)
                }
                #endif
            }
        }
    }

    private var aboutCard: some View {
        GlassCard(title: L10n.text("About")) {
            VStack(alignment: .leading, spacing: RippleSpace.md) {
                GlassCardRow("Ripple", showsDivider: false) {
                    Text(verbatim: "1.0")
                        .font(RippleFont.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Text(L10n.text("MIT License. Open source water tracker."))
                    .font(RippleFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var volumeFormatter: VolumeFormatter {
        VolumeFormatter(locale: locale)
    }

    private func containerRow(_ container: Container, showsDivider: Bool) -> some View {
        HStack(spacing: RippleSpace.md) {
            Image(systemName: container.symbolName)
                .foregroundStyle(RippleColor.waterDeep)
                .frame(width: RippleSpace.xl)
            Text(container.name)
                .font(RippleFont.body)
                .foregroundStyle(RippleColor.waterDeep)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(volumeFormatter.string(milliliters: container.amountMl, unit: model.profile.preferredUnit))
                .font(RippleFont.body.monospacedDigit())
                .foregroundStyle(.secondary)
            if container.isDefault {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(RippleColor.waterLagoon)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, RippleSpace.md)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(RippleColor.waterDeep.opacity(0.10))
                    .frame(height: 1)
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

    private func addContainer() {
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

    private func requestHealthWrite() {
        Task { await model.requestHealthWrite() }
    }

    private func prepareExport() {
        Task { await model.export() }
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
