import Foundation

public enum IntakeSource: String, Sendable, Codable, CaseIterable, Equatable {
    case app
    case widget
    case intent
    case watch
    case control
    case notification
    case liveActivity
    case health
}
