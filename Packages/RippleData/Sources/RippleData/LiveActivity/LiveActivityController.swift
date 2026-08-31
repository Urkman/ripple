import Foundation
import RippleDomain

#if os(iOS)
import ActivityKit
#endif

public struct LiveActivityController: LiveActivityControlling {
    public init() {}

    public func startOrUpdate(_ snapshot: TodaySnapshot) async {
        #if os(iOS)
        await LiveActivityBridge.shared.startOrUpdate(snapshot)
        #endif
    }

    public func end() async {
        #if os(iOS)
        await LiveActivityBridge.shared.end()
        #endif
    }
}

#if os(iOS)
@MainActor
enum LiveActivityBridge {
    static let shared = LiveActivityRuntime()
}

@MainActor
final class LiveActivityRuntime {
    func startOrUpdate(_ snapshot: TodaySnapshot) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = RippleActivityAttributes.ContentState(
            consumedMl: snapshot.consumed.value,
            goalMl: snapshot.goal.value,
            defaultAddMl: snapshot.defaultAddMl,
            unitRaw: snapshot.unit.rawValue
        )
        let attributes = RippleActivityAttributes(dayStart: snapshot.date)

        if let existing = Activity<RippleActivityAttributes>.activities.first {
            await existing.update(.init(state: state, staleDate: midnight(after: snapshot.date)))
            return
        }

        if snapshot.consumed.value <= 0 { return }

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: midnight(after: snapshot.date)),
                pushType: nil
            )
        } catch {
            // Activity budget / user dismissal — logging still succeeded.
        }
    }

    func end() async {
        for activity in Activity<RippleActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func midnight(after date: Date) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(86_400)
    }
}
#endif
