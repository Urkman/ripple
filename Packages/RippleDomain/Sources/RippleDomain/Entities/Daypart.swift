import Foundation

public enum Daypart: String, Sendable, Hashable, Codable, CaseIterable, Comparable {
    case morning
    case midday
    case afternoon
    case evening

    public static func < (lhs: Daypart, rhs: Daypart) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }

    public var sortIndex: Int {
        switch self {
        case .morning: 0
        case .midday: 1
        case .afternoon: 2
        case .evening: 3
        }
    }

    public static func from(hour: Int) -> Daypart {
        switch hour {
        case 5..<11: .morning
        case 11..<14: .midday
        case 14..<18: .afternoon
        default: .evening
        }
    }
}
