import Foundation

public enum SyncStatus: Sendable, Hashable, Equatable {
    case available
    case importing
    case failed(String)
    case unavailable

    public var isUsable: Bool {
        switch self {
        case .available, .importing: true
        case .failed, .unavailable: false
        }
    }
}
