import Foundation
import Testing
@testable import RippleUI

@Suite("Watch UI components")
struct WatchComponentsTests {
    @Test("water and surface shapes disappear at zero")
    func zeroLevelIsEmpty() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 400)

        #expect(WatchWaterLevelShape(level: 0).path(in: rect).isEmpty)
        #expect(WatchWaterLevelShape(level: -1).path(in: rect).isEmpty)
        #expect(WatchWaterSurfaceShape(level: 0).path(in: rect).isEmpty)
        #expect(WatchWaterSurfaceShape(level: -1).path(in: rect).isEmpty)
    }

    @Test("water level caps at the visual maximum")
    func visualLevelCaps() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 400)
        let capped = WatchWaterLevelShape(level: 2).path(in: rect)
        let expectedMinimumY = rect.minY - rect.height * 0.05

        #expect(capped.boundingRect.minY >= expectedMinimumY - 0.001)
        #expect(capped.boundingRect.maxY <= rect.maxY + 0.001)
    }

    @Test("amount options preserve stable identity and selection kind")
    func amountOptionIdentity() {
        let containerID = UUID()
        let predefined = WatchAmountOption(
            id: "container",
            title: "Glass",
            subtitle: "250 ml",
            kind: .predefined(containerID)
        )
        let custom = WatchAmountOption(
            id: "custom",
            title: "Custom",
            subtitle: "",
            kind: .custom
        )

        #expect(predefined.id == "container")
        #expect(predefined.kind == .predefined(containerID))
        #expect(custom.kind == .custom)
        #expect([predefined, custom].map(\.id) == ["container", "custom"])
    }

    @Test("weekly chart points preserve dated categories and empty state")
    func chartPointIdentity() {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 8, day: 31))!
        let points = (0..<7).compactMap { offset -> WatchStatChartPoint? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else {
                return nil
            }
            return WatchStatChartPoint(date: date, consumed: Double(offset * 100), goal: 2_000)
        }

        #expect(points.count == 7)
        #expect(points.map(\.id) == points.map(\.date))
        #expect(WatchStatChartPoint(date: start, consumed: 0, goal: 2_000) != points[1])
        #expect([WatchStatChartPoint]().isEmpty)
    }
}
