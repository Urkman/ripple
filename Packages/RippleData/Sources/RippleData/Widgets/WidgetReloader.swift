import Foundation
import RippleDomain

#if canImport(WidgetKit)
import WidgetKit
#endif

public struct WidgetReloader: WidgetReloading {
    public init() {}

    public func reload() async {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
