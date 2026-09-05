import Foundation
import RippleDomain
import Testing
@testable import RippleData

@Suite("Demo data scenario")
struct DemoDataScenarioTests {
    @Test("builds a varied 36-day scenario without future records")
    func buildsExpectedShape() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 11))
        )
        let containerIDs = [UUID(), UUID(), UUID()]

        let scenario = DemoDataScenario.make(
            now: now,
            calendar: calendar,
            containerIDs: containerIDs
        )
        let grouped = Dictionary(grouping: scenario.records) {
            calendar.startOfDay(for: $0.date)
        }
        let todayRecords = scenario.records.filter {
            calendar.isDate($0.date, inSameDayAs: now)
        }
        let priorTotals = grouped
            .filter { !calendar.isDate($0.key, inSameDayAs: now) }
            .map { $0.value.reduce(0) { $0 + $1.amountMl } }
        let sources = Set(scenario.records.map(\.source))

        #expect(grouped.count == 36)
        #expect(grouped.values.allSatisfy { (2...5).contains($0.count) })
        #expect(todayRecords.reduce(0) { $0 + $1.amountMl } == 1_750)
        #expect(priorTotals.contains { $0 < 2_000 })
        #expect(priorTotals.contains { $0 > 2_000 })
        #expect(scenario.records.allSatisfy { $0.date <= now })
        #expect(Set(scenario.records.map(\.id)).count == scenario.records.count)
        #expect(sources.isSuperset(of: [.app, .widget, .intent, .watch, .control]))
        #expect(scenario.records.allSatisfy { record in
            record.containerId.map(containerIDs.contains) ?? true
        })
    }

    @Test("same anchor produces the same records and IDs")
    func isDeterministic() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 11))
        )
        let containerIDs = [UUID(), UUID(), UUID()]

        let first = DemoDataScenario.make(
            now: now,
            calendar: calendar,
            containerIDs: containerIDs
        )
        let second = DemoDataScenario.make(
            now: now,
            calendar: calendar,
            containerIDs: containerIDs
        )

        #expect(first == second)
    }
}
