import RippleDomain
import RippleFeatures
import RippleUI
import SwiftUI

public struct VisionRootView: View {
    @State private var model: TodayViewModel
    @State private var history: HistoryViewModel
    @State private var stats: StatsViewModel
    @State private var settings: SettingsViewModel
    @State private var selectedSection: VisionSection = .today
    @State private var showsCustomAmount = false
    @State private var availableWindowWidth: CGFloat = 0
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase

    private enum VisionSection: String, CaseIterable, Identifiable {
        case today
        case history
        case stats
        case settings

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .today: "drop.fill"
            case .history: "calendar"
            case .stats: "chart.bar.xaxis"
            case .settings: "gearshape"
            }
        }
    }

    public init(useCases: UseCases) {
        _model = State(initialValue: TodayViewModel(useCases: useCases))
        _history = State(initialValue: HistoryViewModel(useCases: useCases))
        _stats = State(initialValue: StatsViewModel(useCases: useCases))
        _settings = State(initialValue: SettingsViewModel(useCases: useCases))
    }

    public var body: some View {
        let snapshot = model.snapshot
        let formatter = VolumeFormatter(locale: locale)

        selectedContent
            .frame(
                minWidth: RippleLayout.visionWindowMinWidth,
                minHeight: RippleLayout.visionWindowMinHeight
            )
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { width in
                availableWindowWidth = width
            }
            .ornament(attachmentAnchor: .scene(.leading)) {
                VisionNavigationOrnament(
                    items: navigationItems,
                    onSelect: select(item:)
                )
            }
            .ornament(attachmentAnchor: .scene(.bottom)) {
                VisionLogOrnament(
                    items: quickAddItems(snapshot: snapshot, formatter: formatter),
                    customTitle: L10n.text("Custom amount"),
                    customAccessibilityLabel: L10n.text("Custom amount"),
                    maxWidth: logOrnamentMaxWidth,
                    onSelect: add(item:),
                    onCustom: showCustomAmount
                )
            }
            .tint(RippleColor.waterLagoon)
            .sheet(isPresented: $showsCustomAmount, onDismiss: refreshAfterCustomAmount) {
                customAmountSheet
            }
            .task(id: scenePhase) {
                guard scenePhase == .active else { return }
                await model.refresh()
            }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .today:
            VisionTodaySurface(model: model)
        case .history:
            HistoryCalendarView(model: history, todayModel: model)
        case .stats:
            StatsView(model: stats)
        case .settings:
            NavigationStack {
                SettingsView(model: settings)
            }
        }
    }

    private var navigationItems: [VisionNavigationItem] {
        VisionSection.allCases.map { section in
            VisionNavigationItem(
                id: section.id,
                title: title(for: section),
                systemImage: section.systemImage,
                isSelected: section == selectedSection
            )
        }
    }

    private func title(for section: VisionSection) -> String {
        switch section {
        case .today: L10n.text("Today")
        case .history: L10n.text("History")
        case .stats: L10n.text("Stats")
        case .settings: L10n.text("Settings")
        }
    }

    private func select(item: VisionNavigationItem) {
        guard let section = VisionSection(rawValue: item.id) else { return }
        selectedSection = section
    }

    private func add(item: QuickAddItem) {
        guard let container = model.snapshot.containers.first(where: { $0.id == item.id }) else {
            return
        }
        Task {
            await model.add(container: container)
            await refreshVisibleSection()
        }
    }

    private func refreshVisibleSection() async {
        switch selectedSection {
        case .history:
            await history.refresh()
        case .stats:
            await stats.refresh()
        case .today, .settings:
            break
        }
    }

    private func showCustomAmount() {
        showsCustomAmount = true
    }

    private var logOrnamentMaxWidth: CGFloat? {
        guard availableWindowWidth > 0 else { return nil }
        return max(
            availableWindowWidth - (RippleSpace.lg * 2),
            RippleLayout.visionOrnamentTargetMinSize
        )
    }

    private func refreshAfterCustomAmount() {
        Task { await refreshVisibleSection() }
    }

    private var customAmountSheet: some View {
        let snapshot = model.snapshot
        let formatter = VolumeFormatter(locale: locale)
        return CustomAmountSheet(
            model: model,
            initialAmountMl: snapshot.defaultAddMl,
            initialAmountText: formatter.valueString(
                milliliters: snapshot.defaultAddMl,
                unit: snapshot.unit
            ),
            unit: snapshot.unit
        )
    }

    private func quickAddItems(
        snapshot: TodaySnapshot,
        formatter: VolumeFormatter
    ) -> [QuickAddItem] {
        snapshot.containers.prefix(3).map {
            QuickAddItem(
                id: $0.id,
                name: $0.name,
                amount: formatter.string(milliliters: $0.amountMl, unit: snapshot.unit),
                symbolName: $0.symbolName
            )
        }
    }
}

private struct VisionTodaySurface: View {
    let model: TodayViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.locale) private var locale

    var body: some View {
        let snapshot = model.snapshot
        let presentedSnapshot = model.presentedSnapshot
        let formatter = VolumeFormatter(locale: locale)

        VStack(spacing: 0) {
            VisionHeroSection(
                consumedMl: snapshot.consumed.value,
                goalMl: snapshot.goal.value,
                addedMl: model.addedMl,
                phase: model.motion,
                reduceMotion: reduceMotion,
                amountText: formatter.valueString(
                    milliliters: snapshot.consumed.value,
                    unit: snapshot.unit
                ),
                unitText: snapshot.unit.symbol,
                percentText: formatter.percentString(snapshot.percent),
                accessibilitySummary: formatter.heroAccessibility(
                    consumedMl: snapshot.consumed.value,
                    goalMl: snapshot.goal.value,
                    remainingMl: snapshot.remaining.value,
                    percent: snapshot.percent,
                    unit: snapshot.unit
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)

            VisionStatusSection(
                remainingText: formatter.remainingPhrase(
                    milliliters: presentedSnapshot.remaining.value,
                    unit: presentedSnapshot.unit
                ),
                goalText: L10n.text("Goal") + " " + formatter.string(
                    milliliters: presentedSnapshot.goal.value,
                    unit: presentedSnapshot.unit
                )
            )
            .padding(.bottom, RippleSpace.sm)
        }
        .padding(.horizontal, RippleSpace.xl)
        .padding(.top, RippleSpace.xl)
        .padding(.bottom, RippleSpace.xl)
        .frame(
            minWidth: RippleLayout.visionWindowMinWidth,
            idealWidth: RippleLayout.visionWindowIdealWidth,
            maxWidth: .infinity,
            minHeight: RippleLayout.visionWindowMinHeight,
            idealHeight: RippleLayout.visionWindowIdealHeight,
            maxHeight: .infinity
        )
        .overlay(alignment: .bottom) {
            RippleToastHost(
                message: model.confirmation,
                reduceMotion: reduceMotion
            )
            .padding(.horizontal, RippleSpace.xl)
            .padding(.bottom, RippleSpace.xxl)
        }
    }
}

private struct VisionHeroSection: View {
    let consumedMl: Int
    let goalMl: Int
    let addedMl: Int?
    let phase: RippleMotionPhase
    let reduceMotion: Bool
    let amountText: String
    let unitText: String
    let percentText: String
    let accessibilitySummary: String

    var body: some View {
        RippleHeroView(
            consumedMl: consumedMl,
            goalMl: goalMl,
            addedMl: addedMl,
            phase: phase,
            reduceMotion: reduceMotion,
            expandsToFit: false,
            tilt: 0,
            amountText: amountText,
            unitText: unitText,
            percentText: percentText,
            accessibilitySummary: accessibilitySummary
        )
        .frame(
            width: RippleLayout.visionHeroWidth,
            height: RippleLayout.visionHeroHeight
        )
    }
}

private struct VisionStatusSection: View {
    let remainingText: String
    let goalText: String

    var body: some View {
        RemainingLabel(
            remainingText: remainingText,
            goalText: goalText
        )
    }
}

#Preview("Vision Today · Light") {
    VisionRootView(useCases: RippleRuntime.preview)
}

#Preview("Vision Today · Dark · XXXL") {
    VisionRootView(useCases: RippleRuntime.preview)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
