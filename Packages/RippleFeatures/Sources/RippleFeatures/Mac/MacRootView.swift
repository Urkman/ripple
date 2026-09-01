import RippleDomain
import RippleUI
import SwiftUI

#if os(macOS)
public struct MacRootView: View {
    @Bindable var today: TodayViewModel
    @State private var history: HistoryViewModel
    @State private var stats: StatsViewModel
    @State private var settings: SettingsViewModel
    @State private var selection = Sidebar.today

    private enum Sidebar: Hashable {
        case today, history, stats, settings
    }

    public init(useCases: UseCases, today: TodayViewModel) {
        self.today = today
        _history = State(initialValue: HistoryViewModel(useCases: useCases))
        _stats = State(initialValue: StatsViewModel(useCases: useCases))
        _settings = State(initialValue: SettingsViewModel(useCases: useCases))
    }

    public var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label(L10n.text("Today"), systemImage: "drop.fill").tag(Sidebar.today)
                Label(L10n.text("History"), systemImage: "calendar").tag(Sidebar.history)
                Label(L10n.text("Stats"), systemImage: "chart.bar.xaxis").tag(Sidebar.stats)
                Label(L10n.text("Settings"), systemImage: "gearshape").tag(Sidebar.settings)
            }
            .navigationSplitViewColumnWidth(200)
        } detail: {
            switch selection {
            case .today:
                TodayView(model: today)
            case .history:
                HistoryCalendarView(model: history, todayModel: today)
            case .stats:
                StatsView(model: stats)
            case .settings:
                SettingsView(model: settings)
            }
        }
    }
}

public struct RippleMacCommands: Commands {
    var today: TodayViewModel

    public init(today: TodayViewModel) {
        self.today = today
    }

    public var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button(L10n.text("Log default")) {
                Task { await today.addDefault() }
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        CommandGroup(after: .undoRedo) {
            Button(L10n.text("Undo last sip")) {
                Task { await today.undo() }
            }
            .keyboardShortcut("z", modifiers: .command)
        }
        CommandMenu(L10n.text("Containers")) {
            ForEach(Array(today.snapshot.containers.prefix(3).enumerated()), id: \.element.id) { index, container in
                Button(container.name) {
                    Task { await today.add(container: container) }
                }
                .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: .command)
            }
        }
    }
}

public struct MacMenuBarExtra: View {
    @State private var model: TodayViewModel

    public init(useCases: UseCases) {
        _model = State(initialValue: TodayViewModel(useCases: useCases))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(VolumeFormatter.current.percentString(model.snapshot.percent))
            Button(L10n.text("Log default")) {
                Task { await model.addDefault() }
            }
        }
        .padding()
        .task { await model.refresh() }
    }
}
#endif
