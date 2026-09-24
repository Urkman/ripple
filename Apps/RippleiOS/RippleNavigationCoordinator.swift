import Foundation
import Observation
import RippleFeatures
import RippleIntentsCore

@MainActor
@Observable
final class RippleNavigationCoordinator {
    enum Section: Hashable {
        case today
        case history
        case stats
        case settings
    }

    enum Route: Hashable {
        case today
        case history
        case historyDay(Date)
        case stats
        case settings
    }

    enum Destination: Hashable {
        case historyDay(Date)
    }

    enum Sheet: String, Identifiable {
        case customAmount

        var id: String { rawValue }
    }

    var selectedSection: Section = .today
    var historyPath: [Destination] = []
    var historyDetailRefreshID = 0
    var presentedSheet: Sheet?
    var settingsPresentation: SettingsRoute?

    func select(_ section: Section) {
        selectedSection = section
    }

    func open(_ route: Route) {
        switch route {
        case .today:
            select(.today)
        case .history:
            select(.history)
        case .historyDay(let date):
            select(.history)
            historyPath = [.historyDay(date)]
        case .stats:
            select(.stats)
        case .settings:
            select(.settings)
        }
    }

    func open(_ route: RippleRoute) {
        switch route {
        case .today:
            open(Route.today)
        case .history:
            open(Route.history)
        case .settings:
            open(Route.settings)
        }
    }

    func presentCustomAmount() {
        presentedSheet = .customAmount
    }

    func customAmountDidDismiss() {
        historyDetailRefreshID += 1
    }

    func presentSettings(_ route: SettingsRoute) {
        open(Route.settings)
        settingsPresentation = route
    }

    func consumePendingRoute() {
        guard let route = RippleNavigation.pending else { return }
        RippleNavigation.pending = nil
        open(route)
    }
}
