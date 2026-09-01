import Foundation
import RippleDomain

#if canImport(WidgetKit)
import WidgetKit
#endif

/// Home-screen families intentionally have separate kinds. WidgetKit scopes
/// interactive refreshes by kind, so merging these identifiers can refresh a
/// sibling family instead of the widget that handled the interaction.
public enum RippleWidgetKind {
    /// Kept registered so widgets placed by an earlier build remain live after
    /// an app reinstall or upgrade. It uses the same fixed view and intent
    /// path as the family-specific kinds below.
    public static let legacyToday = "de.stefansturm.ripple.today"
    public static let todaySmall = "de.stefansturm.ripple.today.small"
    public static let todayMedium = "de.stefansturm.ripple.today.medium"
    public static let todayLarge = "de.stefansturm.ripple.today.large"
    public static let lockScreen = "de.stefansturm.ripple.lock"
    public static let control = "de.stefansturm.ripple.control"
    public static let watch = "de.stefansturm.ripple.watch"

    public static let iOSTimelineKinds = [
        legacyToday,
        todaySmall,
        todayMedium,
        todayLarge,
        lockScreen,
    ]

    public static let watchTimelineKinds = [watch]
}

public struct WidgetReloader: WidgetReloading {
    public init() {}

    public func reload() async {
        #if canImport(WidgetKit)
        reloadRippleTimelines()
        #endif
    }

    #if canImport(WidgetKit)
    private func reloadRippleTimelines() {
        #if os(iOS)
        reloadTimelines(ofKinds: RippleWidgetKind.iOSTimelineKinds)
        #elseif os(watchOS)
        reloadTimelines(ofKinds: RippleWidgetKind.watchTimelineKinds)
        #else
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func reloadTimelines(ofKinds kinds: [String]) {
        for kind in kinds {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
    }
    #endif
}
