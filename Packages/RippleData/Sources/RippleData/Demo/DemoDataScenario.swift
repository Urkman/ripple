import Foundation
import RippleDomain

struct DemoDataScenario: Sendable, Equatable {
    struct Record: Sendable, Equatable, Identifiable {
        let id: UUID
        let date: Date
        let amountMl: Int
        let source: IntakeSource
        let containerId: UUID?
    }

    let records: [Record]

    private static let templates: [[Int]] = [
        [300, 500, 450],
        [250, 450, 500, 400, 300],
        [350, 500, 350, 500, 400],
        [200, 400, 500, 250],
        [500, 500, 450, 400, 350],
        [250, 400, 300, 450],
        [500, 500, 500, 350, 400],
    ]

    private static let priorDaySlots: [(hour: Int, minute: Int)] = [
        (8, 0),
        (10, 30),
        (13, 0),
        (16, 30),
        (19, 30),
    ]

    static func make(
        now: Date,
        calendar: Calendar,
        containerIDs: [UUID]
    ) -> DemoDataScenario {
        let startOfToday = calendar.startOfDay(for: now)
        var records: [Record] = []

        for dayOffset in stride(from: 35, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: startOfToday) else {
                continue
            }

            let amounts = dayOffset == 0
                ? [250, 500, 250, 400, 350]
                : templates[dayOffset % templates.count]

            for (entryIndex, amountMl) in amounts.enumerated() {
                guard let date = date(
                    for: day,
                    dayOffset: dayOffset,
                    entryIndex: entryIndex,
                    entryCount: amounts.count,
                    now: now,
                    calendar: calendar
                ) else {
                    continue
                }

                records.append(
                    Record(
                        id: fixtureID(dayOffset: dayOffset, entryIndex: entryIndex),
                        date: date,
                        amountMl: amountMl,
                        source: source(for: dayOffset),
                        containerId: containerID(
                            for: entryIndex,
                            dayOffset: dayOffset,
                            from: containerIDs
                        )
                    )
                )
            }
        }

        return DemoDataScenario(records: records)
    }

    private static func date(
        for day: Date,
        dayOffset: Int,
        entryIndex: Int,
        entryCount: Int,
        now: Date,
        calendar: Calendar
    ) -> Date? {
        if dayOffset == 0 {
            let elapsed = max(now.timeIntervalSince(day), 0)
            let fraction = Double(entryIndex + 1) / Double(entryCount + 1)
            return min(day.addingTimeInterval(elapsed * fraction), now)
        }

        let slot = priorDaySlots[entryIndex]
        return calendar.date(
            bySettingHour: slot.hour,
            minute: slot.minute,
            second: 0,
            of: day
        )
    }

    private static func source(for dayOffset: Int) -> IntakeSource {
        switch dayOffset {
        case 3: .widget
        case 10: .intent
        case 17: .watch
        case 24: .control
        default: .app
        }
    }

    private static func containerID(
        for entryIndex: Int,
        dayOffset: Int,
        from containerIDs: [UUID]
    ) -> UUID? {
        guard !containerIDs.isEmpty else { return nil }
        return containerIDs[(entryIndex + dayOffset) % containerIDs.count]
    }

    private static func fixtureID(dayOffset: Int, entryIndex: Int) -> UUID {
        let day = UInt16(clamping: dayOffset)
        let entry = UInt16(clamping: entryIndex)

        return UUID(uuid: (
            0x52,
            0x69,
            0x70,
            0x70,
            0x6C,
            0x65,
            0x44,
            0x65,
            0x6D,
            0x6F,
            0x46,
            0x69,
            UInt8((day >> 8) & 0xFF),
            UInt8(day & 0xFF),
            UInt8((entry >> 8) & 0xFF),
            UInt8(entry & 0xFF)
        ))
    }
}
