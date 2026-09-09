import Foundation
import Testing
import SwiftUI
@testable import RippleUI

@Suite("Physical water response")
struct WaterDynamicsTests {
    let metrics = GlassMetrics(in: CGRect(x: 0, y: 0, width: 200, height: 280), inset: 3)

    @Test("rotation and slosh preserve contained water area", arguments: [0.01, 0.3, 0.5, 0.99])
    func conservedArea(level: Double) {
        let reference = WaterSurfaceGeometry(metrics: metrics, level: level, tilt: 0)
        let area = WaterSurfaceGeometry.area(reference.polygon)
        for degrees: CGFloat in [-180, -135, -90, -60, -30, 30, 60, 90, 135, 180] {
            for slosh: CGFloat in [-0.06, 0, 0.06] {
                let water = WaterSurfaceGeometry(metrics: metrics, level: level,
                    tilt: degrees * .pi / 180, slosh: slosh)
                #expect(abs(WaterSurfaceGeometry.area(water.polygon) - area) / area < 0.001)
                #expect(water.polygon.allSatisfy { point in
                    point.x.isFinite && point.y.isFinite
                        && point.y >= metrics.rimBottomY - 0.001
                        && point.y <= metrics.bottomY + 0.001
                        && point.x >= metrics.xMin(atY: point.y) - 0.001
                        && point.x <= metrics.xMax(atY: point.y) + 0.001
                })
            }
        }
    }

    @Test("water rises on the side gravity points toward")
    func direction() {
        let water = WaterSurfaceGeometry(metrics: metrics, level: 0.5, tilt: -.pi / 4)
        let left = water.contactY(atX: metrics.centerX - 30, fallback: metrics.bottomY)
        let right = water.contactY(atX: metrics.centerX + 30, fallback: metrics.bottomY)
        #expect(right < left)
        #expect(abs((right - left) / 60 + 1) < 0.01)
    }

    @Test("movement creates curved slosh, reverses and settles exactly")
    func dampedSlosh() {
        var state = WaterDynamics()
        state.update(target: 0, elapsed: 1.0 / 60)
        var values: [CGFloat] = []
        for _ in 0..<90 {
            state.update(target: -.pi / 3, elapsed: 1.0 / 60)
            values.append(state.slosh)
        }
        #expect(values.contains { $0 < -0.001 })
        #expect(values.contains { $0 > 0.001 })
        for _ in 0..<300 { state.update(target: -.pi / 3, elapsed: 1.0 / 60) }
        #expect(state.slosh == 0)
        #expect(abs(state.tilt + .pi / 3) < 0.002)
        let curve = WaterSurfaceGeometry(metrics: metrics, level: 0.5, tilt: 0, slosh: 0.06)
        let a = curve.contactY(atX: metrics.centerX + 20, fallback: metrics.bottomY)
        let b = curve.contactY(atX: metrics.centerX + 40, fallback: metrics.bottomY)
        let c = curve.contactY(atX: metrics.centerX + 60, fallback: metrics.bottomY)
        #expect(abs((a + c) / 2 - b) > 0.1)
    }

    @Test("returning upright retains visible waves after the phone stops", arguments: [0.25, 0.6, 1.0])
    func returnUpright(duration: Double) {
        let dt = 1.0 / 60
        for initialAngle: CGFloat in [-.pi / 4, .pi / 4] {
            var state = WaterDynamics()
            for _ in 0..<360 { state.update(target: initialAngle, elapsed: dt) }
            let steps = Int(duration / dt)
            for index in 1...steps {
                state.update(target: initialAngle * (1 - CGFloat(index) / CGFloat(steps)), elapsed: dt)
            }
            var positivePeak: CGFloat = 0
            var negativePeak: CGFloat = 0
            for frame in 0..<90 {
                state.update(target: 0, elapsed: dt)
                if frame >= 30 {
                    positivePeak = max(positivePeak, state.slosh)
                    negativePeak = min(negativePeak, state.slosh)
                }
            }
            // Both crests must remain visible 0.5–1.5 s after motion stops.
            #expect(positivePeak * metrics.rimWidth > 0.5)
            #expect(negativePeak * metrics.rimWidth < -0.5)
            for _ in 0..<360 { state.update(target: 0, elapsed: dt) }
            #expect(state.slosh == 0)
            #expect(state.tilt == 0)
        }
    }

    @MainActor
    @Test("rotating the interface changes coordinates without erasing momentum")
    func orientationPreservesMomentum() {
        let baseline = GravityTiltController()
        let rotated = GravityTiltController()
        let dt = 1.0 / 60
        for frame in 0..<120 {
            let target: Double = frame < 20 ? 0 : -.pi / 4
            let rotation: CGFloat = frame >= 80 ? 0 : (frame >= 30 ? .pi / 2 : 0)
            baseline.record(gravityX: -sin(target), gravityY: -cos(target), gravityZ: 0,
                            timestamp: Double(frame) * dt)
            rotated.record(gravityX: -sin(target), gravityY: -cos(target), gravityZ: 0,
                           timestamp: Double(frame) * dt, referenceRotation: rotation)
            #expect(abs(WaterDynamics.angleDifference(rotated.tilt, baseline.tilt + rotation)) < 0.0001)
            #expect(abs(rotated.slosh - baseline.slosh) < 0.0001)
        }
    }

    @Test("wraparound takes the short path and irregular samples remain bounded")
    func wrapAndTiming() {
        var state = WaterDynamics()
        for _ in 0..<300 { state.update(target: .pi - 0.01, elapsed: 1.0 / 60) }
        let before = state.tilt
        state.update(target: -.pi + 0.01, elapsed: 0.03)
        #expect(abs(state.tilt - before) < 0.1)
        for index in 0..<300 {
            state.update(target: index.isMultiple(of: 2) ? -2 : 2, elapsed: 1)
            #expect(state.tilt.isFinite)
            #expect(abs(state.slosh) <= RippleMotion.sloshLimit)
        }
    }

    @Test("sensor jitter does not sustain an idle wave")
    func quietIdle() {
        var state = WaterDynamics()
        for index in 0..<300 {
            state.update(target: index.isMultiple(of: 2) ? 0 : 0.0005, elapsed: 1.0 / 60)
        }
        #expect(state.slosh == 0)
        #expect(state.tilt == 0)
    }

    @MainActor
    @Test("face-up and stop clear the full motion state")
    func reset() {
        let controller = GravityTiltController()
        controller.record(gravityX: 0, gravityY: -1, gravityZ: 0, timestamp: 0)
        controller.record(gravityX: 1, gravityY: 0, gravityZ: 0, timestamp: 0.05)
        #expect(controller.tilt != 0)
        #expect(controller.slosh != 0)
        controller.record(gravityX: 0, gravityY: 0, gravityZ: 1, timestamp: 0.1)
        #expect(controller.tilt == 0 && controller.slosh == 0)
        controller.record(gravityX: -1, gravityY: 0, gravityZ: 0, timestamp: 0.2)
        controller.stop()
        #expect(controller.tilt == 0 && controller.slosh == 0)
    }

    @MainActor
    @Test("Reduce Motion renders the same flat hero despite incoming tilt and slosh")
    func reduceMotionRendering() throws {
        func pixels(tilt: CGFloat, slosh: CGFloat) throws -> Data {
            let hero = RippleHeroView(consumedMl: 500, goalMl: 1000, reduceMotion: true,
                tilt: tilt, slosh: slosh, amountText: "500", unitText: "ml",
                percentText: "50 %", accessibilitySummary: "Water")
                .frame(width: 200, height: 320)
            let renderer = ImageRenderer(content: hero)
            let image = try #require(renderer.cgImage)
            return try #require(image.dataProvider?.data) as Data
        }
        #expect(try pixels(tilt: 0, slosh: 0) == pixels(tilt: -.pi / 3, slosh: 0.06))
    }

    @Test("empty and full remain stable at every orientation")
    func extremes() {
        for angle: CGFloat in [0, .pi / 2, .pi, -.pi / 2] {
            let empty = WaterSurfaceGeometry(metrics: metrics, level: 0, tilt: angle, slosh: 0.06)
            #expect(empty.path.isEmpty)
            let full = WaterSurfaceGeometry(metrics: metrics, level: 1, tilt: angle, slosh: 0.06)
            let upright = WaterSurfaceGeometry(metrics: metrics, level: 1, tilt: 0)
            #expect(WaterSurfaceGeometry.area(full.polygon) == WaterSurfaceGeometry.area(upright.polygon))
        }
    }

    @Test("upright fill follows the tapered inner walls", arguments: [0.25, 0.5, 0.85])
    func taperedFill(level: Double) {
        let water = WaterSurfaceGeometry(metrics: metrics, level: level, tilt: 0)
        let surfaceY = water.polygon.map(\.y).min() ?? metrics.bottomY
        let surfacePoints = water.polygon.filter { abs($0.y - surfaceY) < 0.001 }
        let surfaceWidth = (surfacePoints.map(\.x).max() ?? 0)
            - (surfacePoints.map(\.x).min() ?? 0)
        #expect(abs(surfaceY - metrics.y(forLevel: level)) < 0.5)
        #expect(abs(surfaceWidth - metrics.width(atY: surfaceY)) < GlassMetrics.strokeWidth)
    }
}
