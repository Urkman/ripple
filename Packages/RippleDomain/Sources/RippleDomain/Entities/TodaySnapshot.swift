import Foundation

public struct TodaySnapshot: Sendable, Hashable, Equatable {
    public var date: Date
    public var consumed: Milliliters
    public var goal: Milliliters
    public var remaining: Milliliters
    public var percent: Double
    public var entries: [Intake]
    public var unit: VolumeUnit
    public var defaultAddMl: Int
    public var containers: [Container]
    public var pacingMlPerHour: Int?

    public init(
        date: Date,
        consumed: Milliliters,
        goal: Milliliters,
        remaining: Milliliters,
        percent: Double,
        entries: [Intake],
        unit: VolumeUnit,
        defaultAddMl: Int,
        containers: [Container],
        pacingMlPerHour: Int?
    ) {
        self.date = date
        self.consumed = consumed
        self.goal = goal
        self.remaining = remaining
        self.percent = percent
        self.entries = entries
        self.unit = unit
        self.defaultAddMl = defaultAddMl
        self.containers = containers
        self.pacingMlPerHour = pacingMlPerHour
    }

    public var isEmpty: Bool { consumed.value <= 0 }
    public var isGoalMet: Bool { consumed.value >= goal.value && goal.value > 0 }

    public static func empty(date: Date = Date(), unit: VolumeUnit = .milliliters) -> TodaySnapshot {
        TodaySnapshot(
            date: date,
            consumed: .zero,
            goal: Milliliters(2000),
            remaining: Milliliters(2000),
            percent: 0,
            entries: [],
            unit: unit,
            defaultAddMl: 250,
            containers: Container.seededDefaults(),
            pacingMlPerHour: nil
        )
    }
}
