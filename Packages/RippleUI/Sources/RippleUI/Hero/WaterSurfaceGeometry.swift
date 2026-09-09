import SwiftUI

/// Area-preserving 2D water in a closed glass, including sideways and inverted poses.
struct WaterSurfaceGeometry {
    let polygon: [CGPoint]

    init(metrics: GlassMetrics, level: CGFloat, tilt: CGFloat, slosh: CGFloat = 0,
         pourDepth: CGFloat = 0, ripplePosition: CGFloat = 0, rippleAmplitude: CGFloat = 0,
         thickness: CGFloat = 0) {
        let container = Self.container(in: metrics)
        // The rounded wall/floor joins are slightly non-convex because the
        // wall is straight while the corner is quadratic. Use the convex
        // envelope for the half-plane clipping calculation; WaterFill's
        // final GlassShape clip remains the authoritative visible boundary.
        let clippingContainer = Self.convexHull(of: container)
        guard level > 0 else { polygon = []; return }
        guard level < 1 else { polygon = container; return }
        let center = CGPoint(x: metrics.centerX, y: (metrics.rimBottomY + metrics.bottomY) / 2)
        let extent = hypot(metrics.rimWidth, metrics.fillHeight)
        let angle = tilt.isFinite ? tilt : 0
        let tangent = CGPoint(x: cos(angle), y: sin(angle))
        let normal = CGPoint(x: -sin(angle), y: cos(angle))
        let target = Self.area(Self.clip([
            CGPoint(x: center.x - extent, y: metrics.y(forLevel: level)),
            CGPoint(x: center.x + extent, y: metrics.y(forLevel: level)),
            CGPoint(x: center.x + extent, y: metrics.bottomY + extent),
            CGPoint(x: center.x - extent, y: metrics.bottomY + extent),
        ], to: clippingContainer))
        let amplitude = min(max(slosh, -RippleMotion.sloshLimit), RippleMotion.sloshLimit) * metrics.rimWidth
        let steps = RippleMotion.surfaceSegments
        // Build the curved surface once; the area search only translates it.
        var surface: [CGPoint] = []
        for index in 0...steps {
            let distance = -extent + 2 * extent * CGFloat(index) / CGFloat(steps)
            let u = distance / max(metrics.rimWidth / 2, 1)
            let wave = amplitude * 3 * u * exp(-2 * u * u)
            let x = center.x + tangent.x * distance + normal.x * wave
            let y = center.y + tangent.y * distance + normal.y * wave
            let depth = RippleMotion.waveAmplitude(requested: pourDepth, level: level)
            let ripple = RippleMotion.waveAmplitude(requested: abs(rippleAmplitude), level: level)
                * (rippleAmplitude < 0 ? -1 : 1)
            let contact = RippleMotion.pourSurfaceOffset(x: x, centerX: center.x,
                surfaceWidth: metrics.width(atY: metrics.y(forLevel: level)), depth: depth)
            let response = RippleMotion.travellingSurfaceOffset(x: x, centerX: center.x,
                surfaceWidth: metrics.width(atY: metrics.y(forLevel: level)),
                position: ripplePosition, amplitude: ripple)
            surface.append(CGPoint(x: x, y: y + contact + response))
        }
        surface.append(CGPoint(x: center.x + tangent.x * extent + normal.x * extent * 3,
                               y: center.y + tangent.y * extent + normal.y * extent * 3))
        surface.append(CGPoint(x: center.x - tangent.x * extent + normal.x * extent * 3,
                               y: center.y - tangent.y * extent + normal.y * extent * 3))
        func translated(_ offset: CGFloat) -> [CGPoint] {
            Self.clip(surface.map { CGPoint(x: $0.x + normal.x * offset,
                                            y: $0.y + normal.y * offset) }, to: clippingContainer)
        }
        var low = -extent
        var high = extent
        for _ in 0..<RippleMotion.surfaceAreaIterations {
            let mid = (low + high) / 2
            if Self.area(translated(mid)) > target { low = mid } else { high = mid }
        }
        polygon = translated((low + high) / 2 + thickness)
    }

    var path: Path {
        Path { path in
            guard let first = polygon.first else { return }
            path.move(to: first)
            for point in polygon.dropFirst() { path.addLine(to: point) }
            path.closeSubpath()
        }
    }

    /// First visible water intersection along the vertical pour ray.
    func contactY(atX x: CGFloat, fallback: CGFloat) -> CGFloat {
        guard let last = polygon.last else { return fallback }
        var previous = last
        var result = fallback
        for point in polygon {
            if (previous.x <= x && point.x > x) || (point.x <= x && previous.x > x) {
                let t = (x - previous.x) / (point.x - previous.x)
                result = min(result, previous.y + (point.y - previous.y) * t)
            }
            previous = point
        }
        return result
    }

    static func area(_ polygon: [CGPoint]) -> CGFloat {
        guard var previous = polygon.last else { return 0 }
        var sum: CGFloat = 0
        for point in polygon {
            sum += previous.x * point.y - point.x * previous.y
            previous = point
        }
        return abs(sum) / 2
    }

    private static func container(in metrics: GlassMetrics) -> [CGPoint] {
        let radius = metrics.bottomRadius
        var points = [CGPoint(x: metrics.rimLeftX, y: metrics.rimBottomY),
                      CGPoint(x: metrics.rimRightX, y: metrics.rimBottomY),
                      CGPoint(x: metrics.bottomRightX, y: metrics.bottomY - radius)]
        for index in 1...8 {
            let t = CGFloat(index) / 8
            points.append(CGPoint(x: metrics.bottomRightX - radius * t * t,
                                  y: metrics.bottomY - radius * (1 - t) * (1 - t)))
        }
        points.append(CGPoint(x: metrics.bottomLeftX + radius, y: metrics.bottomY))
        for index in 1...8 {
            let t = CGFloat(index) / 8
            points.append(CGPoint(x: metrics.bottomLeftX + radius * (1 - t) * (1 - t),
                                  y: metrics.bottomY - radius * t * t))
        }
        return points
    }

    private static func convexHull(of points: [CGPoint]) -> [CGPoint] {
        let sorted = points.sorted {
            if $0.x == $1.x { return $0.y < $1.y }
            return $0.x < $1.x
        }
        guard sorted.count > 2 else { return sorted }

        func cross(_ origin: CGPoint, _ first: CGPoint, _ second: CGPoint) -> CGFloat {
            (first.x - origin.x) * (second.y - origin.y)
                - (first.y - origin.y) * (second.x - origin.x)
        }

        var lower: [CGPoint] = []
        for point in sorted {
            while lower.count >= 2,
                  cross(lower[lower.count - 2], lower[lower.count - 1], point) <= 0 {
                lower.removeLast()
            }
            lower.append(point)
        }

        var upper: [CGPoint] = []
        for point in sorted.reversed() {
            while upper.count >= 2,
                  cross(upper[upper.count - 2], upper[upper.count - 1], point) <= 0 {
                upper.removeLast()
            }
            upper.append(point)
        }

        return Array(lower.dropLast()) + Array(upper.dropLast())
    }

    private static func clip(_ polygon: [CGPoint], to container: [CGPoint]) -> [CGPoint] {
        var output = polygon
        guard var edgeStart = container.last else { return [] }
        for edgeEnd in container {
            let input = output
            output = []
            guard var previous = input.last else { return [] }
            func side(_ point: CGPoint) -> CGFloat {
                (edgeEnd.x - edgeStart.x) * (point.y - edgeStart.y)
                    - (edgeEnd.y - edgeStart.y) * (point.x - edgeStart.x)
            }
            var previousSide = side(previous)
            for point in input {
                let currentSide = side(point)
                if (currentSide >= 0) != (previousSide >= 0) {
                    let t = previousSide / (previousSide - currentSide)
                    output.append(CGPoint(x: previous.x + (point.x - previous.x) * t,
                                          y: previous.y + (point.y - previous.y) * t))
                }
                if currentSide >= 0 { output.append(point) }
                previous = point
                previousSide = currentSide
            }
            edgeStart = edgeEnd
        }
        return output
    }
}
