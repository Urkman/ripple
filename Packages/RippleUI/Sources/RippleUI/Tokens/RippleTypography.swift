import SwiftUI

public enum RippleFont {
    public static let display = Font.largeTitle.weight(.semibold).monospacedDigit()
    public static let title = Font.title2.weight(.semibold)
    public static let body = Font.body
    public static let callout = Font.callout
    public static let caption = Font.caption
}

public enum RippleRadius {
    public static let control: CGFloat = 12
    public static let card: CGFloat = 20
    public static let hero: CGFloat = 28
}

public enum RippleSpace {
    public static let grid: CGFloat = 4
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
}
