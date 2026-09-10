import RippleDomain
import RippleUI
import SwiftUI

public struct SettingsView: View {
    @Bindable var model: SettingsViewModel
    @Environment(\.locale) private var locale
    @Environment(\.rippleIPadLayout) private var usesIPadLayout
    @State private var containerEditor: Container?
    @State private var isReminderEditorPresented = false

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
        .sheet(item: $containerEditor) { container in
            ContainerEditorSheet(
                container: container,
                title: model.containers.contains(where: { $0.id == container.id })
                    ? L10n.text("Edit")
                    : L10n.text("Add container"),
                preferredUnit: model.profile.preferredUnit,
                isCurrentDefault: container.isDefault,
                onSave: { updatedContainer in
                    Task { await model.saveContainer(updatedContainer) }
                }
            )
        }
        .sheet(isPresented: $isReminderEditorPresented) {
            ReminderEditorSheet(
                reminder: model.reminder,
                onSave: { updatedReminder in
                    Task { await model.saveReminder(updatedReminder) }
                }
            )
        }
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
                containerRows

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

    @ViewBuilder
    private var containerRows: some View {
        #if os(tvOS)
        ForEach(model.containers) { container in
            containerRow(
                container,
                showsDivider: container.id != model.containers.last?.id
            )
        }
        #else
        reorderableContainerRows
        #endif
    }

    #if !os(tvOS)
    private var reorderableContainerRows: some View {
        VStack(spacing: 0) {
            ForEach(model.containers) { container in
                containerRow(
                    container,
                    showsDivider: container.id != model.containers.last?.id
                )
            }
            .reorderable()
        }
        .reorderContainer(for: Container.self) { difference in
            var reordered = model.containers
            difference.apply(to: &reordered)
            model.reorderContainers(reordered)
        }
    }
    #endif

    private var remindersCard: some View {
        GlassCard(title: L10n.text("Reminders")) {
            Button {
                isReminderEditorPresented = true
            } label: {
                HStack(spacing: RippleSpace.md) {
                    VStack(alignment: .leading, spacing: RippleSpace.xs) {
                        Text(model.reminder.enabled ? L10n.text("On") : L10n.text("Off"))
                            .font(RippleFont.body)
                            .foregroundStyle(RippleColor.waterDeep)
                        Text(
                            "\(L10n.text("After last sip")): \(L10n.minutes(model.reminder.afterLastSipMinutes))"
                        )
                        .font(RippleFont.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "pencil")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, RippleSpace.md)
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
        HStack(spacing: RippleSpace.sm) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.tertiary)
                .frame(
                    width: RippleLayout.minimumControlDimension,
                    height: RippleLayout.minimumControlDimension
                )
                .accessibilityHidden(true)

            Button {
                containerEditor = container
            } label: {
                HStack(spacing: RippleSpace.md) {
                    Image(systemName: container.symbolName)
                        .foregroundStyle(RippleColor.waterDeep)
                        .frame(width: RippleSpace.xl)
                    Text(container.name)
                        .font(RippleFont.body)
                        .foregroundStyle(RippleColor.waterDeep)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(
                        volumeFormatter.string(
                            milliliters: container.amountMl,
                            unit: model.profile.preferredUnit
                        )
                    )
                    .font(RippleFont.body.monospacedDigit())
                    .foregroundStyle(.secondary)
                    if container.isDefault {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RippleColor.waterLagoon)
                            .accessibilityLabel(L10n.text("Default container"))
                    }
                    Image(systemName: "pencil")
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, RippleSpace.md)
        .contentShape(Rectangle())
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
        containerEditor = Container(
            name: L10n.text("Glass"),
            amountMl: 250,
            isDefault: !model.containers.contains(where: \.isDefault),
            sort: (model.containers.map(\.sort).max() ?? -1) + 1,
            symbolName: "cup.and.saucer.fill"
        )
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

#if !os(tvOS)
private extension ReorderDifference where CollectionID == ReorderableSingleCollectionIdentifier {
    func apply<C>(to collection: inout C)
        where C: RangeReplaceableCollection,
              C.Element: Identifiable,
              C.Element.ID == ItemID
    {
        let moving = Set(sources)
        guard !moving.isEmpty else { return }

        var moved: [C.Element] = []
        moved.reserveCapacity(moving.count)
        collection.removeAll { element in
            guard moving.contains(element.id) else { return false }
            moved.append(element)
            return true
        }

        switch destination.position {
        case .before(let id):
            let index = collection.firstIndex { $0.id == id } ?? collection.endIndex
            collection.insert(contentsOf: moved, at: index)
        case .end:
            collection.append(contentsOf: moved)
        }
    }
}
#endif

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

private struct ContainerEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var draft: Container

    private let title: String
    private let preferredUnit: VolumeUnit
    private let isCurrentDefault: Bool
    private let onSave: (Container) -> Void

    init(
        container: Container,
        title: String,
        preferredUnit: VolumeUnit,
        isCurrentDefault: Bool,
        onSave: @escaping (Container) -> Void
    ) {
        _draft = State(initialValue: container)
        self.title = title
        self.preferredUnit = preferredUnit
        self.isCurrentDefault = isCurrentDefault
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RippleSpace.lg) {
                    TextField(L10n.text("Container"), text: $draft.name)
                        .font(RippleFont.body)
                        .padding(.horizontal, RippleSpace.md)
                        .padding(.vertical, RippleSpace.sm)
                        .rippleGlass(cornerRadius: RippleRadius.control)

                    ContainerSymbolPicker(
                        label: L10n.text("Icon"),
                        selection: $draft.symbolName,
                        options: symbolOptions
                    )

                    VStack(alignment: .leading, spacing: RippleSpace.sm) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(L10n.text("Amount"))
                                .font(RippleFont.body)
                                .foregroundStyle(RippleColor.waterDeep)
                            Spacer(minLength: RippleSpace.sm)
                            Text(
                                volumeFormatter.string(
                                    milliliters: draft.amountMl,
                                    unit: preferredUnit
                                )
                            )
                            .font(RippleFont.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                        }

                        Slider(value: amountBinding, in: 50...2_000, step: 10)
                            .tint(RippleColor.waterLagoon)
                            .accessibilityLabel(L10n.text("Amount"))
                            .accessibilityValue(
                                volumeFormatter.string(
                                    milliliters: draft.amountMl,
                                    unit: preferredUnit
                                )
                            )
                    }

                    Toggle(L10n.text("Default container"), isOn: defaultBinding)
                        .tint(RippleColor.waterLagoon)
                        .disabled(isCurrentDefault)
                }
                .padding(.horizontal, RippleSpace.lg)
                .padding(.vertical, RippleSpace.lg)
            }
            .background(RippleColor.waterFoam)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Save")) {
                        var updatedContainer = draft
                        updatedContainer.name = updatedContainer.name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        onSave(updatedContainer)
                        dismiss()
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(RippleColor.waterFoam)
    }

    private var volumeFormatter: VolumeFormatter {
        VolumeFormatter(locale: locale)
    }

    private var amountBinding: Binding<Double> {
        Binding(
            get: { Double(draft.amountMl) },
            set: { draft.amountMl = Int($0.rounded()) }
        )
    }

    private var defaultBinding: Binding<Bool> {
        Binding(
            get: { draft.isDefault },
            set: { draft.isDefault = $0 }
        )
    }

    private var symbolOptions: [ContainerSymbolOption] {
        [
            ContainerSymbolOption(
                symbolName: "cup.and.saucer.fill",
                title: L10n.text("Glass")
            ),
            ContainerSymbolOption(
                symbolName: "mug.fill",
                title: L10n.text("Cup")
            ),
            ContainerSymbolOption(
                symbolName: "waterbottle.fill",
                title: L10n.text("Bottle")
            ),
            ContainerSymbolOption(
                symbolName: "takeoutbag.and.cup.and.straw.fill",
                title: L10n.text("Travel cup")
            ),
            ContainerSymbolOption(
                symbolName: "wineglass.fill",
                title: L10n.text("Wine glass")
            ),
        ]
    }
}

private struct ReminderEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ReminderRule

    private let onSave: (ReminderRule) -> Void

    init(reminder: ReminderRule, onSave: @escaping (ReminderRule) -> Void) {
        _draft = State(initialValue: reminder)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Toggle(L10n.text("Reminders"), isOn: $draft.enabled)

                HStack {
                    Text(L10n.text("After last sip"))
                    Spacer(minLength: RippleSpace.sm)
                    Stepper(
                        L10n.minutes(draft.afterLastSipMinutes),
                        value: $draft.afterLastSipMinutes,
                        in: 30...240,
                        step: 15
                    )
                    .labelsHidden()
                    .accessibilityLabel(L10n.text("After last sip"))
                }
            }
            .navigationTitle(L10n.text("Reminders"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.text("Cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("Save")) {
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview("Container editor · Light") {
    ContainerEditorSheet(
        container: Container(
            name: "Glass",
            amountMl: 250,
            isDefault: true,
            symbolName: "cup.and.saucer.fill"
        ),
        title: L10n.text("Edit"),
        preferredUnit: .milliliters,
        isCurrentDefault: true,
        onSave: { _ in }
    )
}

#Preview("Container editor · Dark · XXXL") {
    ContainerEditorSheet(
        container: Container(
            name: "Glass",
            amountMl: 250,
            isDefault: true,
            symbolName: "cup.and.saucer.fill"
        ),
        title: L10n.text("Edit"),
        preferredUnit: .milliliters,
        isCurrentDefault: true,
        onSave: { _ in }
    )
    .environment(\.colorScheme, .dark)
    .environment(\.dynamicTypeSize, .xxxLarge)
}

#Preview("Reminder editor · Light") {
    ReminderEditorSheet(reminder: .default) { _ in }
}

#Preview("Reminder editor · Dark · XXXL") {
    ReminderEditorSheet(reminder: .default) { _ in }
        .environment(\.colorScheme, .dark)
        .environment(\.dynamicTypeSize, .xxxLarge)
}
