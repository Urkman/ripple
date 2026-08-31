import Foundation

public protocol WidgetReloading: Sendable {
    func reload() async
}
