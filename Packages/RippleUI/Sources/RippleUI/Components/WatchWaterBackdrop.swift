import SwiftUI

public struct WatchWaterLevelShape: Shape {
    public var level: CGFloat

    public init(level: CGFloat) {
        self.level = level
    }

    public func path(in rect: CGRect) -> Path {
        guard level > 0, rect.width > 0, rect.height > 0 else {
            return Path()
        }

        let cappedLevel = min(max(level, 0), RippleMotion.maxVisualLevel)
        let surfaceY = rect.maxY - rect.height * cappedLevel
        return Path(CGRect(
            x: rect.minX,
            y: surfaceY,
            width: rect.width,
            height: rect.maxY - surfaceY
        ))
    }
}

public struct WatchWaterSurfaceShape: Shape {
    public var level: CGFloat

    public init(level: CGFloat) {
        self.level = level
    }

    public func path(in rect: CGRect) -> Path {
        guard level > 0, rect.width > 0, rect.height > 0 else {
            return Path()
        }

        let cappedLevel = min(max(level, 0), RippleMotion.maxVisualLevel)
        let surfaceY = rect.maxY - rect.height * cappedLevel
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: surfaceY))
        path.addLine(to: CGPoint(x: rect.maxX, y: surfaceY))
        return path
    }
}

public struct WatchWaterBackdrop: View {
    public var level: CGFloat

    public init(level: CGFloat) {
        self.level = level
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                RippleColor.surface

                WatchWaterLevelShape(level: level)
                    .fill(RippleColor.waterAqua.opacity(0.88))

                WatchWaterSurfaceShape(level: level)
                    .stroke(RippleColor.waterLagoon.opacity(0.92), lineWidth: 1)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview("Watch Water") {
    WatchWaterBackdrop(level: 0.52)
        .frame(width: 184, height: 224)
}

#Preview("Watch Water · Dark · Reduce Motion") {
    WatchWaterBackdrop(level: 0.52)
        .frame(width: 184, height: 224)
        .preferredColorScheme(.dark)
}
