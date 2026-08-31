import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public enum RippleColor {
    public static let waterDeep = Color(light: Color(hex: 0x0B3D4A), dark: Color(hex: 0xB7E0E8))
    public static let waterLagoon = Color(light: Color(hex: 0x1A7A8C), dark: Color(hex: 0x4FB3C6))
    public static let waterAqua = Color(light: Color(hex: 0x4FB3C6), dark: Color(hex: 0x6FDBE8))
    public static let waterFoam = Color(light: Color(hex: 0xE8F4F6), dark: Color(hex: 0x152026))
    public static let glassHighlight = Color(light: .white, dark: .white)
    public static let surface = Color(light: Color(hex: 0xE8F4F6), dark: Color(hex: 0x12181C))
    public static let success = waterLagoon
    public static let danger = Color.red.opacity(0.82)
}

public extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    init(light: Color, dark: Color) {
        self.init(uiOrNSColor: light, dark: dark)
    }

    private init(uiOrNSColor light: Color, dark: Color) {
        #if os(watchOS) || os(tvOS)
        self = light
        #elseif canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
        #else
        self = light
        #endif
    }
}
