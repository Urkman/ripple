import RippleDomain
import RippleUI
import SwiftUI

#if os(watchOS)
public struct WatchRootView: View {
    private enum Page: Hashable {
        case today
        case history
        case stats
    }

    let useCases: UseCases

    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedPage: Page = .today
    @State private var todayModel: WatchTodayViewModel
    @State private var historyModel: WatchHistoryViewModel
    @State private var statsModel: WatchStatsViewModel

    public init(useCases: UseCases) {
        self.useCases = useCases
        _todayModel = State(initialValue: WatchTodayViewModel(useCases: useCases))
        _historyModel = State(initialValue: WatchHistoryViewModel(useCases: useCases))
        _statsModel = State(initialValue: WatchStatsViewModel(useCases: useCases))
    }

    public var body: some View {
        TabView(selection: $selectedPage) {
            WatchTodayView(model: todayModel)
                .tag(Page.today)

            WatchHistoryView(model: historyModel, useCases: useCases)
                .tag(Page.history)

            WatchStatsView(model: statsModel)
                .tag(Page.stats)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .background(RippleColor.surface.ignoresSafeArea())
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await refreshAll()
        }
    }

    private func refreshAll() async {
        await todayModel.refresh()
        await historyModel.refresh()
        await statsModel.refresh()
    }
}
#endif
