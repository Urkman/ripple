import Foundation
import Synchronization

public enum RippleRoute: String, Sendable, Equatable {
    case today
    case history
    case settings
}

public enum RippleNavigation: Sendable {
    private static let slot = Mutex<RippleRoute?>(nil)

    public static var pending: RippleRoute? {
        get { slot.withLock { $0 } }
        set { slot.withLock { $0 = newValue } }
    }
}
