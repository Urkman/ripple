import AppIntents
import Foundation

public struct RippleShortcuts: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor { .teal }

    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogWaterIntent(),
            phrases: [
                "Logge Wasser in \(.applicationName)",
                "Log water in \(.applicationName)",
                "\(.applicationName), 300 Milliliter",
            ],
            shortTitle: "Log water",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: GetTodayProgressIntent(),
            phrases: [
                "Wie viel Wasser noch heute in \(.applicationName)?",
                "How much water left today in \(.applicationName)?",
            ],
            shortTitle: "Today's progress",
            systemImageName: "drop.circle"
        )
        AppShortcut(
            intent: UndoLastIntakeIntent(),
            phrases: [
                "Nimm den letzten Schluck in \(.applicationName) zurück",
                "Undo last sip in \(.applicationName)",
            ],
            shortTitle: "Undo last sip",
            systemImageName: "arrow.uturn.backward"
        )
        AppShortcut(
            intent: OpenTodayIntent(),
            phrases: [
                "Öffne \(.applicationName)",
                "Open \(.applicationName)",
            ],
            shortTitle: "Open Today",
            systemImageName: "drop"
        )
    }
}
