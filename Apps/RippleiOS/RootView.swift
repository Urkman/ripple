import RippleDomain
import RippleFeatures
import RippleUI
import SwiftUI

public struct RootView: View {
    @Environment(\.rippleUseCases) private var useCases
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale
    @State private var today: TodayViewModel
    @State private var history: HistoryViewModel
    @State private var stats: StatsViewModel
    @State private var settings: SettingsViewModel
    @State private var onboarding: OnboardingViewModel
    @State private var navigation: RippleNavigationCoordinator
    @State private var showOnboarding = false

    public init(useCases: UseCases) {
        _today = State(initialValue: TodayViewModel(useCases: useCases))
        _history = State(initialValue: HistoryViewModel(useCases: useCases))
        _stats = State(initialValue: StatsViewModel(useCases: useCases))
        _settings = State(initialValue: SettingsViewModel(useCases: useCases))
        _onboarding = State(initialValue: OnboardingViewModel(useCases: useCases))
        _navigation = State(initialValue: RippleNavigationCoordinator())
    }

    public var body: some View {
        GeometryReader { proxy in
            let usableWidth = proxy.size.width
                - proxy.safeAreaInsets.leading
                - proxy.safeAreaInsets.trailing
            let expandedLayout = usableWidth >= RippleLayout.expandedLayoutMinimumWidth
            let historySplit = usableWidth >= RippleLayout.historySplitMinimumWidth
            Group {
                if showOnboarding {
                    OnboardingView(model: onboarding) {
                        showOnboarding = false
                        Task { await today.refresh() }
                    }
                } else {
                    iOSTabs(historySplit: historySplit)
                }
            }
            .task(id: scenePhase) {
                guard scenePhase == .active else { return }
                navigation.consumePendingRoute()
                let profile = try? await useCases.settingsRepository.profile()
                showOnboarding = !(profile?.onboardingCompleted ?? false)
                await today.refresh()
            }
            .environment(\.rippleExpandedLayout, expandedLayout)
            .tint(RippleColor.waterLagoon)
        }
    }

    private func iOSTabs(historySplit: Bool) -> some View {
        @Bindable var navigation = navigation

        return TabView(selection: $navigation.selectedSection) {
            Tab(L10n.text("Today"), systemImage: "drop.fill", value: .today) {
                NavigationStack {
                    TodayView(
                        model: today,
                        onPresentCustomAmount: { navigation.presentCustomAmount() }
                    )
                }
            }
            Tab(L10n.text("History"), systemImage: "calendar", value: .history) {
                if historySplit {
                    HistoryCalendarView(
                        model: history,
                        todayModel: today,
                        detailRefreshID: navigation.historyDetailRefreshID,
                        onPresentCustomAmount: { navigation.presentCustomAmount() }
                    )
                    .environment(\.rippleHistorySplit, historySplit)
                } else {
                    NavigationStack(path: $navigation.historyPath) {
                        HistoryCalendarView(
                            model: history,
                            todayModel: today,
                            detailRefreshID: navigation.historyDetailRefreshID,
                            onOpenDay: { date in
                                navigation.open(.historyDay(date))
                            },
                            onPresentCustomAmount: { navigation.presentCustomAmount() }
                        )
                        .environment(\.rippleHistorySplit, historySplit)
                        .navigationDestination(
                            for: RippleNavigationCoordinator.Destination.self
                        ) { destination in
                            switch destination {
                            case .historyDay(let date):
                                DayDetailView(
                                    day: date,
                                    useCases: useCases,
                                    refreshID: navigation.historyDetailRefreshID
                                )
                            }
                        }
                    }
                }
            }
            Tab(L10n.text("Stats"), systemImage: "chart.bar.xaxis", value: .stats) {
                StatsView(model: stats)
            }
            Tab(L10n.text("Settings"), systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView(
                        model: settings,
                        presentation: $navigation.settingsPresentation,
                        onPresent: { route in navigation.presentSettings(route) }
                    )
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .sheet(item: $navigation.presentedSheet, onDismiss: {
            navigation.customAmountDidDismiss()
            Task {
                await today.refresh()
                await history.refresh()
            }
        }) { _ in
            customAmountSheet
        }
    }

    private var customAmountSheet: some View {
        let snapshot = today.snapshot
        let formatter = VolumeFormatter(locale: locale)
        return CustomAmountSheet(
            model: today,
            initialAmountMl: snapshot.defaultAddMl,
            initialAmountText: formatter.valueString(
                milliliters: snapshot.defaultAddMl,
                unit: snapshot.unit
            ),
            unit: snapshot.unit
        )
    }
}
