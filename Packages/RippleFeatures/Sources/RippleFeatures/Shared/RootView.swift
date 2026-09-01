import RippleDomain
import RippleUI
import SwiftUI

public struct RootView: View {
    @Environment(\.rippleUseCases) private var useCases
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.scenePhase) private var scenePhase
    @State private var today: TodayViewModel
    @State private var history: HistoryViewModel
    @State private var stats: StatsViewModel
    @State private var settings: SettingsViewModel
    @State private var onboarding: OnboardingViewModel
    @State private var selected: AppSection = .today
    @State private var showOnboarding = false

    public enum AppSection: Hashable {
        case today, history, stats, settings
    }

    public init(useCases: UseCases) {
        _today = State(initialValue: TodayViewModel(useCases: useCases))
        _history = State(initialValue: HistoryViewModel(useCases: useCases))
        _stats = State(initialValue: StatsViewModel(useCases: useCases))
        _settings = State(initialValue: SettingsViewModel(useCases: useCases))
        _onboarding = State(initialValue: OnboardingViewModel(useCases: useCases))
    }

    public var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(model: onboarding) {
                    showOnboarding = false
                    Task { await today.refresh() }
                }
            } else {
                #if os(iOS)
                iOSTabs
                #else
                NavigationStack {
                    TodayView(model: today)
                }
                #endif
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            let profile = try? await useCases.settingsRepository.profile()
            showOnboarding = !(profile?.onboardingCompleted ?? false)
            await today.refresh()
        }
        .tint(RippleColor.waterLagoon)
    }

    #if os(iOS)
    private var iOSTabs: some View {
        TabView(selection: $selected) {
            Tab(L10n.text("Today"), systemImage: "drop.fill", value: .today) {
                NavigationStack {
                    TodayView(model: today)
                }
            }
            Tab(L10n.text("History"), systemImage: "calendar", value: .history) {
                HistoryCalendarView(model: history)
                    .environment(\.rippleHistorySplit, sizeClass == .regular)
            }
            Tab(L10n.text("Stats"), systemImage: "chart.bar.xaxis", value: .stats) {
                StatsView(model: stats)
            }
            Tab(L10n.text("Settings"), systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView(model: settings)
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
    #endif

    public func select(_ tab: AppSection) {
        selected = tab
    }
}
