import SwiftUI

public struct OnboardingArtwork: View {
    public let stage: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let reduceMotionOverride: Bool?
    @State private var level: CGFloat = 0

    public init(stage: Int) {
        self.stage = stage
        self.reduceMotionOverride = nil
    }

    fileprivate init(stage: Int, reduceMotionOverride: Bool) {
        self.stage = stage
        self.reduceMotionOverride = reduceMotionOverride
    }

    public var body: some View {
        ZStack {
            GlassShape()
                .fill(RippleColor.waterFoam.opacity(0.26))

            WaterFill(level: level, tilt: 0)

            GlassShape()
                .stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth)

            GlassShape(inset: RippleSpace.sm)
                .stroke(
                    RippleColor.glassHighlight.opacity(0.38),
                    lineWidth: GlassMetrics.strokeWidth / 3
                )
        }
        .frame(
            width: RippleLayout.onboardingArtworkWidth,
            height: RippleLayout.onboardingArtworkHeight
        )
        .accessibilityHidden(true)
        .onAppear {
            updateLevel(animated: false)
        }
        .onChange(of: stage) { _, _ in
            updateLevel(animated: true)
        }
        .onChange(of: reduceMotion) { _, _ in
            updateLevel(animated: false)
        }
    }

    private var targetLevel: CGFloat {
        switch stage {
        case 0:
            0.16
        case 1:
            0.34
        case 2:
            0.56
        case 3:
            0.72
        default:
            0.84
        }
    }

    private func updateLevel(animated: Bool) {
        if (reduceMotionOverride ?? reduceMotion) || !animated {
            level = targetLevel
        } else {
            withAnimation(RippleMotion.springLiquid) {
                level = targetLevel
            }
        }
    }
}

#Preview("Onboarding artwork · welcome") {
    OnboardingArtwork(stage: 0)
        .padding()
        .background(RippleColor.waterFoam)
}

#Preview("Onboarding artwork · Health · dark XXXL") {
    OnboardingArtwork(stage: 2)
        .padding()
        .background(RippleColor.waterFoam)
        .environment(\.colorScheme, .dark)
        .environment(\.dynamicTypeSize, .xxxLarge)
}

#Preview("Onboarding artwork · final · Reduce Motion") {
    OnboardingArtwork(stage: 4, reduceMotionOverride: true)
        .padding()
        .background(RippleColor.waterFoam)
}
