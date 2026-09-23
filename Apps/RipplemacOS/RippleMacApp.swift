import RippleData
import RippleFeatures
import RippleUI
import SwiftUI

@main
struct RippleMacApp: App {
    private let container: RippleContainer
    @State private var today: TodayViewModel
    @State private var settingsModel: SettingsViewModel

    init() {
        let started = RippleBootstrap.start()
        container = started
        _today = State(initialValue: TodayViewModel(useCases: started.useCases))
        _settingsModel = State(initialValue: SettingsViewModel(useCases: started.useCases))
    }

    var body: some Scene {
        WindowGroup {
            MacRootView(useCases: container.useCases, today: today)
                .environment(\.rippleUseCases, container.useCases)
                .frame(
                    minWidth: RippleLayout.macWindowMinimumWidth,
                    minHeight: RippleLayout.macWindowMinimumHeight
                )
        }
        .commands {
            RippleMacCommands(today: today)
        }
        Settings {
            SettingsView(model: settingsModel)
        }
        MenuBarExtra("Ripple", systemImage: "drop.fill") {
            MacMenuBarExtra(useCases: container.useCases)
        }
    }
}
