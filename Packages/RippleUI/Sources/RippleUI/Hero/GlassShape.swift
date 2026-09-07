import SwiftUI

public struct GlassMetrics: Sendable, Equatable {
    public static let strokeWidth: CGFloat = 3
    public static let rimRatio: CGFloat = 1.35

    public var rect: CGRect
    public var inset: CGFloat

    public init(in rect: CGRect, inset: CGFloat = 0) {
        self.rect = rect
        self.inset = inset
    }

    public var box: CGRect {
        rect.insetBy(dx: Self.strokeWidth / 2 + 2 + inset, dy: Self.strokeWidth / 2 + 2 + inset)
    }

    public var centerX: CGFloat { box.midX }

    public var rimTopY: CGFloat { box.minY }
    public var rimBottomY: CGFloat { box.minY + max(14, box.height * 0.07) }
    public var bottomY: CGFloat { box.maxY }
    public var bottomRadius: CGFloat { min(20, box.width * 0.11) }

    public var rimWidth: CGFloat { box.width }
    public var bottomWidth: CGFloat { rimWidth / Self.rimRatio }

    public var rimLeftX: CGFloat { centerX - rimWidth / 2 }
    public var rimRightX: CGFloat { centerX + rimWidth / 2 }
    public var bottomLeftX: CGFloat { centerX - bottomWidth / 2 }
    public var bottomRightX: CGFloat { centerX + bottomWidth / 2 }

    public var fillHeight: CGFloat { max(bottomY - rimBottomY, 1) }

    public func y(forLevel level: CGFloat) -> CGFloat {
        bottomY - min(max(level, 0), RippleMotion.maxVisualLevel) * fillHeight
    }

    public func xMin(atY y: CGFloat) -> CGFloat {
        wallX(atY: y, left: true)
    }

    public func xMax(atY y: CGFloat) -> CGFloat {
        wallX(atY: y, left: false)
    }

    public func width(atY y: CGFloat) -> CGFloat {
        xMax(atY: y) - xMin(atY: y)
    }

    public var path: Path {
        var path = Path()
        let radius = bottomRadius
        path.move(to: CGPoint(x: bottomLeftX + radius, y: bottomY))
        path.addLine(to: CGPoint(x: bottomRightX - radius, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: bottomRightX, y: bottomY - radius),
            control: CGPoint(x: bottomRightX, y: bottomY)
        )
        path.addLine(to: CGPoint(x: rimRightX, y: rimBottomY))
        path.addQuadCurve(
            to: CGPoint(x: rimLeftX, y: rimBottomY),
            control: CGPoint(x: centerX, y: rimTopY)
        )
        path.addLine(to: CGPoint(x: bottomLeftX, y: bottomY - radius))
        path.addQuadCurve(
            to: CGPoint(x: bottomLeftX + radius, y: bottomY),
            control: CGPoint(x: bottomLeftX, y: bottomY)
        )
        path.closeSubpath()
        return path
    }

    private func wallX(atY y: CGFloat, left: Bool) -> CGFloat {
        let top = left ? rimLeftX : rimRightX
        let bottom = left ? bottomLeftX : bottomRightX
        let yTop = rimBottomY
        let yBottom = bottomY
        if y <= yTop { return top }
        if y >= yBottom { return bottom }
        let t = (y - yTop) / (yBottom - yTop)
        return top + (bottom - top) * t
    }
}

public struct GlassShape: Shape {
    public var inset: CGFloat

    public init(inset: CGFloat = 0) {
        self.inset = inset
    }

    public func path(in rect: CGRect) -> Path {
        GlassMetrics(in: rect, inset: inset).path
    }
}
