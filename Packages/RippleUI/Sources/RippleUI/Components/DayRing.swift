import SwiftUI

public enum DayRingMetrics {
    public static let compactDiameter: CGFloat = 36
    public static let regularDiameter: CGFloat = 36
    public static let lineWidth: CGFloat = 3
    public static let todayDot: CGFloat = 1.5
    public static let selectedHalo: CGFloat = 2
}

public enum RippleChart {
    public static let height: CGFloat = 180
}

public struct DayRing: View {
    public var dayNumber: Int
    public var progress: Double
    public var isToday: Bool
    public var isFuture: Bool
    public var isSelected: Bool
    public var hasEntries: Bool
    public var hitGoal: Bool
    public var reduceMotion: Bool
    public var diameter: CGFloat
    public var accessibilityText: String

    public init(
        dayNumber: Int,
        progress: Double,
        isToday: Bool,
        isFuture: Bool,
        isSelected: Bool,
        hasEntries: Bool,
        hitGoal: Bool,
        reduceMotion: Bool,
        diameter: CGFloat,
        accessibilityText: String
    ) {
        self.dayNumber = dayNumber
        self.progress = min(1, max(0, progress))
        self.isToday = isToday
        self.isFuture = isFuture
        self.isSelected = isSelected
        self.hasEntries = hasEntries
        self.hitGoal = hitGoal
        self.reduceMotion = reduceMotion
        self.diameter = diameter
        self.accessibilityText = accessibilityText
    }

    public var body: some View {
        VStack(spacing: RippleSpace.xs) {
            ZStack {
                Circle()
                    .stroke(RippleColor.waterDeep.opacity(0.12), lineWidth: DayRingMetrics.lineWidth)
                    .frame(width: diameter, height: diameter)
                Circle()
                    .trim(from: 0, to: isFuture ? 0 : progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: DayRingMetrics.lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: diameter, height: diameter)
                    .animation(reduceMotion ? nil : .easeInOut(duration: RippleMotion.durationQuick), value: progress)
                Text(verbatim: "\(dayNumber)")
                    .font(numberFont)
                    .monospacedDigit()
                    .foregroundStyle(numberColor)
            }
            .overlay {
                if isSelected {
                    Circle()
                        .stroke(RippleColor.waterLagoon, lineWidth: DayRingMetrics.selectedHalo)
                        .frame(
                            width: diameter + DayRingMetrics.selectedHalo * 2,
                            height: diameter + DayRingMetrics.selectedHalo * 2
                        )
                }
            }
            Circle()
                .fill(isToday ? RippleColor.waterDeep : Color.clear)
                .frame(width: DayRingMetrics.todayDot, height: DayRingMetrics.todayDot)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityHidden(isFuture)
    }

    private var ringColor: Color {
        if isFuture || progress <= 0 {
            return .clear
        }
        if hitGoal {
            return RippleColor.waterAqua
        }
        return RippleColor.waterLagoon
    }

    private var numberColor: Color {
        if isFuture {
            return RippleColor.waterDeep.opacity(0.3)
        }
        if !hasEntries {
            return RippleColor.waterDeep.opacity(0.6)
        }
        return RippleColor.waterDeep
    }

    private var numberFont: Font {
        if isToday {
            return RippleFont.caption.weight(.bold)
        }
        if hitGoal && !isFuture {
            return RippleFont.caption.weight(.semibold)
        }
        return RippleFont.caption
    }
}

#Preview("DayRing") {
    HStack(spacing: RippleSpace.lg) {
        DayRing(
            dayNumber: 28,
            progress: 0.62,
            isToday: true,
            isFuture: false,
            isSelected: false,
            hasEntries: true,
            hitGoal: false,
            reduceMotion: false,
            diameter: DayRingMetrics.compactDiameter,
            accessibilityText: "28 August, 1250 milliliters of 2000"
        )
        DayRing(
            dayNumber: 1,
            progress: 1,
            isToday: false,
            isFuture: false,
            isSelected: true,
            hasEntries: true,
            hitGoal: true,
            reduceMotion: true,
            diameter: DayRingMetrics.regularDiameter,
            accessibilityText: "1 August, goal reached"
        )
    }
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("DayRing dark XXXL") {
    DayRing(
        dayNumber: 12,
        progress: 0.4,
        isToday: false,
        isFuture: false,
        isSelected: false,
        hasEntries: true,
        hitGoal: false,
        reduceMotion: true,
        diameter: DayRingMetrics.regularDiameter,
        accessibilityText: "12"
    )
    .padding()
    .background(RippleColor.waterFoam)
    .environment(\.colorScheme, .dark)
    .environment(\.dynamicTypeSize, .xxxLarge)
}
