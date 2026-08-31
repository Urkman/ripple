import SwiftUI

@Animatable
public struct PourStreamShape: Shape {
    public var progress: CGFloat

    public init(progress: CGFloat) {
        self.progress = progress
    }

    public func path(in rect: CGRect) -> Path {
        let visibleProgress = min(max(progress, 0), 1)
        guard visibleProgress > 0 else { return Path() }

        let bottomY = rect.minY + rect.height * visibleProgress
        let topHalfWidth = rect.width / 2
        let bottomHalfWidth = rect.width * 0.36
        let centerX = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: centerX - topHalfWidth, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: centerX - bottomHalfWidth, y: bottomY),
            control1: CGPoint(
                x: centerX - topHalfWidth * 0.96,
                y: rect.minY + (bottomY - rect.minY) * 0.35
            ),
            control2: CGPoint(
                x: centerX - bottomHalfWidth * 1.08,
                y: rect.minY + (bottomY - rect.minY) * 0.72
            )
        )
        path.addLine(to: CGPoint(x: centerX + bottomHalfWidth, y: bottomY))
        path.addCurve(
            to: CGPoint(x: centerX + topHalfWidth, y: rect.minY),
            control1: CGPoint(
                x: centerX + bottomHalfWidth * 1.08,
                y: rect.minY + (bottomY - rect.minY) * 0.72
            ),
            control2: CGPoint(
                x: centerX + topHalfWidth * 0.96,
                y: rect.minY + (bottomY - rect.minY) * 0.35
            )
        )
        path.closeSubpath()
        return path
    }
}

public struct PourStreamView: View {
    public var addedMl: Int
    public var progress: CGFloat
    public var reduceMotion: Bool

    public init(
        addedMl: Int,
        progress: CGFloat,
        reduceMotion: Bool = false
    ) {
        self.addedMl = addedMl
        self.progress = progress
        self.reduceMotion = reduceMotion
    }

    public var body: some View {
        if reduceMotion {
            Color.clear
        } else {
            PourStreamShape(progress: progress)
                .fill(
                    LinearGradient(
                        colors: [
                            RippleColor.waterLagoon.opacity(0.62),
                            RippleColor.waterAqua,
                            RippleColor.waterDeep.opacity(0.24),
                            RippleColor.waterAqua,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: RippleMotion.pourWidth(for: addedMl))
                .accessibilityHidden(true)
        }
    }
}

#Preview("Pour stream · Light") {
    PourStreamView(addedMl: 250, progress: 1)
        .frame(width: 40, height: 220)
        .padding()
        .background(RippleColor.waterFoam)
}

#Preview("Pour stream · Dark") {
    PourStreamView(addedMl: 500, progress: 1)
        .frame(width: 40, height: 220)
        .padding()
        .background(RippleColor.surface)
        .preferredColorScheme(.dark)
}

#Preview("Pour stream · XXXL") {
    VStack {
        Text("500 ml")
            .font(.body.monospacedDigit())
        PourStreamView(addedMl: 500, progress: 1)
            .frame(width: 40, height: 180)
    }
    .dynamicTypeSize(.accessibility3)
    .padding()
    .background(RippleColor.waterFoam)
}

#Preview("Pour stream · Reduce Motion") {
    PourStreamView(addedMl: 250, progress: 1, reduceMotion: true)
        .frame(width: 40, height: 220)
        .padding()
        .background(RippleColor.waterFoam)
}
