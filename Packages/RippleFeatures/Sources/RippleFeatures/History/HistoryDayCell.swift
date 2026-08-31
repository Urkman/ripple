import RippleDomain
import RippleUI
import SwiftUI

struct HistoryDayCell: View {
    let date: Date
    let summary: DaySummary?
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool
    let reduceMotion: Bool
    let diameter: CGFloat

    var body: some View {
        DayRing(
            dayNumber: Calendar.current.component(.day, from: date),
            progress: isFuture ? 0 : (summary?.progress ?? 0),
            isToday: isToday,
            isFuture: isFuture,
            isSelected: isSelected,
            hasEntries: (summary?.entryCount ?? 0) > 0,
            hitGoal: (summary?.hitGoal ?? false) && !isFuture,
            reduceMotion: reduceMotion,
            diameter: diameter,
            accessibilityText: VolumeFormatter.current.dayCellAccessibility(
                date: date,
                consumedMl: summary?.consumedMl ?? 0,
                goalMl: summary?.goalMl ?? 0,
                hitGoal: (summary?.hitGoal ?? false) && !isFuture
            )
        )
    }
}
