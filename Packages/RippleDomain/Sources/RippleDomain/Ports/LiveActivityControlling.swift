import Foundation

public protocol LiveActivityControlling: Sendable {
    func startOrUpdate(_ snapshot: TodaySnapshot) async
    func end() async
}
