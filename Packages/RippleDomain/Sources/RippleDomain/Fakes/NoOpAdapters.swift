import Foundation

public struct NoOpWidgetReloading: WidgetReloading {
    public init() {}
    public func reload() async {}
}

public struct NoOpReminderScheduling: ReminderScheduling {
    public init() {}
    public func reschedule(rule: ReminderRule, lastSip: Date?) async {
        _ = rule
        _ = lastSip
    }
}

public struct NoOpWorkoutReading: WorkoutReading {
    public var minutes: Int
    public init(minutes: Int = 0) { self.minutes = minutes }
    public func moderateMinutes(on day: Date) async -> Int {
        _ = day
        return minutes
    }
}

public struct NoOpHealthAuthorizing: HealthAuthorizing {
    public var current: HealthAuthorizationStatus
    public init(current: HealthAuthorizationStatus = .init()) {
        self.current = current
    }

    public func status() async -> HealthAuthorizationStatus { current }
    public func requestWaterWrite() async -> Bool { current.waterWrite }
    public func requestWorkoutRead() async -> Bool { current.workoutRead }
}

public actor FakeHealthProjector: HealthProjecting {
    public private(set) var writtenIDs: [UUID] = []
    public private(set) var retractedIDs: [UUID] = []

    public init() {}

    public func project(intake: Intake) async {
        if writtenIDs.contains(intake.id) { return }
        writtenIDs.append(intake.id)
    }

    public func retract(intakeID: UUID) async {
        writtenIDs.removeAll { $0 == intakeID }
        retractedIDs.append(intakeID)
    }
}

public actor RecordingWidgetReloading: WidgetReloading {
    public private(set) var reloadCount = 0
    public init() {}
    public func reload() async { reloadCount += 1 }
}

public actor RecordingReminders: ReminderScheduling {
    public private(set) var lastSipDates: [Date?] = []
    public init() {}
    public func reschedule(rule: ReminderRule, lastSip: Date?) async {
        _ = rule
        lastSipDates.append(lastSip)
    }
}
