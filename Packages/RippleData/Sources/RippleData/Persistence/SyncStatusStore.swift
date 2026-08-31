import Foundation
import RippleDomain

public actor SyncStatusStore {
    public private(set) var current: SyncStatus

    public init(_ current: SyncStatus) {
        self.current = current
    }

    public func update(_ status: SyncStatus) {
        current = status
    }
}
