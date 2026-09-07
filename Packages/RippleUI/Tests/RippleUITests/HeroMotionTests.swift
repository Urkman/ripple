import Foundation
import Testing
@testable import RippleUI

@Suite("Hero motion")
struct HeroMotionTests {
    @Test("pour dimensions and duration follow milliliters with stable caps")
    func pourScalesWithAmount() {
        #expect(RippleMotion.pourWidth(for: 0) == 7)
        #expect(RippleMotion.pourWidth(for: 50) == 7)
        #expect(RippleMotion.pourWidth(for: 750) == 12)
        #expect(RippleMotion.pourWidth(for: 2000) == 12)
        #expect(RippleMotion.pourDuration(for: 50) == 0.40)
        #expect(RippleMotion.pourDuration(for: 750) == 0.70)
        #expect(RippleMotion.pourDepth(for: 50) == 5)
        #expect(RippleMotion.pourDepth(for: 750) == 9)

        let cupWidth = RippleMotion.pourWidth(for: 200)
        let glassWidth = RippleMotion.pourWidth(for: 250)
        let bottleWidth = RippleMotion.pourWidth(for: 500)
        #expect(cupWidth < glassWidth)
        #expect(glassWidth < bottleWidth)
        #expect(abs(glassWidth - 8.4286) < 0.002)
        #expect(abs(RippleMotion.pourDuration(for: 250) - 0.4857) < 0.002)
        #expect(abs(RippleMotion.pourDepth(for: 250) - 6.1429) < 0.002)
    }

    @Test("level rise lasts until the visible stream has fully disappeared")
    func levelRiseMatchesVisibleStream() {
        for amount in [0, 50, 250, 500, 750, 2_000] {
            let expected = RippleMotion.pourDuration(for: amount)
                + RippleMotion.pourFadeOut
            #expect(
                abs(RippleMotion.levelRiseDuration(for: amount) - expected)
                    < 0.0001
            )
        }

        #expect(abs(RippleMotion.levelRiseDuration(for: 250) - 0.6257) < 0.002)
    }

    @Test("one pour clock drives level interpolation and stream fade")
    func sharedPourClock() {
        let activeDuration = RippleMotion.pourDuration(for: 500)
        let totalDuration = RippleMotion.levelRiseDuration(for: 500)
        let halfProgress = RippleMotion.pourProgress(
            elapsed: totalDuration / 2,
            duration: totalDuration
        )

        #expect(RippleMotion.pourProgress(elapsed: -1, duration: totalDuration) == 0)
        #expect(abs(halfProgress - 0.5) < 0.0001)
        #expect(RippleMotion.pourProgress(elapsed: totalDuration + 1, duration: totalDuration) == 1)
        #expect(
            abs(
                RippleMotion.pourLevel(
                    start: 0.45,
                    target: 0.70,
                    progress: halfProgress
                ) - 0.575
            ) < 0.0001
        )

        let activeProgress = RippleMotion.pourProgress(
            elapsed: activeDuration,
            duration: totalDuration
        )
        #expect(RippleMotion.pourFadeProgress(
            progress: activeProgress,
            activeDuration: activeDuration,
            totalDuration: totalDuration
        ) == 0)
        #expect(RippleMotion.pourFadeProgress(
            progress: 1,
            activeDuration: activeDuration,
            totalDuration: totalDuration
        ) == 1)
    }

    @Test("stream grows from its top and reaches the contact edge")
    func pourStreamGeometry() {
        let rect = CGRect(x: 10, y: 20, width: 12, height: 180)
        let hidden = PourStreamShape(progress: 0).path(in: rect)
        let full = PourStreamShape(progress: 1).path(in: rect)

        #expect(hidden.isEmpty)
        #expect(abs(full.boundingRect.minY - rect.minY) < 0.001)
        #expect(abs(full.boundingRect.maxY - rect.maxY) < 0.001)
        #expect(full.boundingRect.width <= rect.width)
    }

    @Test("pour contact creates a symmetric depression with raised shoulders")
    func pourContactProfile() {
        let centerX: CGFloat = 100
        let surfaceWidth: CGFloat = 160
        let depth: CGFloat = 8
        let leftWallX = centerX - surfaceWidth / 2
        let rightWallX = centerX + surfaceWidth / 2
        let leftShoulderX = centerX - surfaceWidth * 0.18
        let rightShoulderX = centerX + surfaceWidth * 0.18

        let center = RippleMotion.pourSurfaceOffset(
            x: centerX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            depth: depth
        )
        let leftShoulder = RippleMotion.pourSurfaceOffset(
            x: leftShoulderX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            depth: depth
        )
        let rightShoulder = RippleMotion.pourSurfaceOffset(
            x: rightShoulderX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            depth: depth
        )
        let leftWall = RippleMotion.pourSurfaceOffset(
            x: leftWallX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            depth: depth
        )
        let rightWall = RippleMotion.pourSurfaceOffset(
            x: rightWallX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            depth: depth
        )

        #expect(center > depth * 0.95)
        #expect(leftShoulder < 0)
        #expect(abs(leftShoulder - rightShoulder) < 0.001)
        #expect(abs(leftWall) < depth * 0.01)
        #expect(abs(rightWall) < depth * 0.01)
        #expect(
            RippleMotion.pourSurfaceOffset(
                x: centerX,
                centerX: centerX,
                surfaceWidth: surfaceWidth,
                depth: 0
            ) == 0
        )
    }

    @Test("surface crests travel symmetrically and invert for the reflection")
    func travellingSurfacePair() {
        let centerX: CGFloat = 100
        let surfaceWidth: CGFloat = 160
        let position: CGFloat = 0.35
        let leftCrestX = centerX - surfaceWidth * position
        let rightCrestX = centerX + surfaceWidth * position

        let leftOutbound = RippleMotion.travellingSurfaceOffset(
            x: leftCrestX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            position: position,
            amplitude: 6
        )
        let rightOutbound = RippleMotion.travellingSurfaceOffset(
            x: rightCrestX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            position: position,
            amplitude: 6
        )
        let reflected = RippleMotion.travellingSurfaceOffset(
            x: rightCrestX,
            centerX: centerX,
            surfaceWidth: surfaceWidth,
            position: position,
            amplitude: -6 * RippleMotion.rippleReflectionRatio
        )

        #expect(leftOutbound < -4)
        #expect(abs(leftOutbound - rightOutbound) < 0.001)
        #expect(reflected > 0)
        #expect(abs(reflected) < abs(rightOutbound) * 0.40)
        #expect(
            RippleMotion.travellingSurfaceOffset(
                x: centerX,
                centerX: centerX,
                surfaceWidth: surfaceWidth,
                position: position,
                amplitude: 0
            ) == 0
        )
    }

    @Test("outbound, reflection, and settle durations total exactly 0.90 seconds")
    func oneShotSurfaceTiming() {
        let total = RippleMotion.rippleOutboundDuration
            + RippleMotion.rippleReflectionDuration
            + RippleMotion.rippleSettleDuration
        #expect(abs(total - 0.90) < 0.0001)
        #expect(
            abs(
                RippleMotion.rippleTurnDuration
                    + RippleMotion.rippleReturnDuration
                    - RippleMotion.rippleReflectionDuration
            ) < 0.0001
        )
        #expect(RippleMotion.rippleReflectionRatio == 0.36)
    }

    @Test("shallow fill clamps amplitude to 4 pt")
    func shallowAmplitudeCap() {
        #expect(RippleMotion.waveAmplitude(requested: 14, level: 0.10) == 4)
        #expect(RippleMotion.waveAmplitude(requested: 6, level: 0.14) == 4)
        #expect(RippleMotion.waveAmplitude(requested: 3, level: 0.10) == 3)
        #expect(RippleMotion.waveAmplitude(requested: 14, level: 0.15) == 14)
        #expect(RippleMotion.waveAmplitude(requested: 6, level: 0.50) == 6)
    }

    @Test("fill level follows milliliters, not stream width, and caps visually")
    func fillLevel() {
        #expect(RippleMotion.fillLevel(consumedMl: 0, goalMl: 2000) == 0)
        #expect(RippleMotion.fillLevel(consumedMl: 1000, goalMl: 2000) == 0.5)
        #expect(RippleMotion.fillLevel(consumedMl: 2000, goalMl: 2000) == 1)
        #expect(RippleMotion.fillLevel(consumedMl: 3000, goalMl: 2000) == RippleMotion.maxVisualLevel)
        #expect(RippleMotion.fillLevel(consumedMl: 250, goalMl: 0) == 0)
    }

    @Test("tumbler rim is 1.35 times the base, level 0 at floor, level 1 at lower rim")
    func glassMetrics() {
        let metrics = GlassMetrics(in: CGRect(x: 0, y: 0, width: 200, height: 280))
        #expect(abs(metrics.rimWidth / metrics.bottomWidth - GlassMetrics.rimRatio) < 0.001)
        #expect(abs(metrics.y(forLevel: 0) - metrics.bottomY) < 0.001)
        #expect(abs(metrics.y(forLevel: 1) - metrics.rimBottomY) < 0.001)
        #expect(metrics.y(forLevel: 1) > metrics.rimTopY)
        #expect(metrics.width(atY: metrics.rimBottomY) > metrics.width(atY: metrics.bottomY))
    }

    @Test("gravity follows the full angle without a 16 degree cap", arguments: [-170.0, -90, -45, 0, 45, 90, 170])
    func gravityAngle(degrees: Double) {
        let angle = degrees * .pi / 180
        let target = RippleMotion.tiltTarget(gravityX: -sin(angle), gravityY: -cos(angle), gravityZ: 0)
        #expect(abs(target - angle) < 0.0001)
        #expect(RippleMotion.tiltTarget(gravityX: 1, gravityY: 0, gravityZ: 0.95) == 0)
    }

    @Test("level zero produces no water path")
    func emptyFill() {
        let shape = WaterFillShape(
            level: 0,
            pourDepth: 9,
            ripplePosition: 0.46,
            rippleAmplitude: 7,
            tilt: 0.2,
            thickness: 0
        )
        #expect(shape.path(in: CGRect(x: 0, y: 0, width: 200, height: 280)).isEmpty)
    }
}
