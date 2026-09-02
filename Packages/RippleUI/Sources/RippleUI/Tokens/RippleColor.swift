import SwiftUI

public enum RippleColor {
    public static let waterDeep = Color("RippleWaterDeep", bundle: .module)
    public static let waterLagoon = Color("RippleWaterLagoon", bundle: .module)
    public static let waterAqua = Color("RippleWaterAqua", bundle: .module)
    public static let waterFoam = Color("RippleWaterFoam", bundle: .module)
    public static let glassHighlight = Color.white
    public static let surface = Color("RippleSurface", bundle: .module)

    // These values mirror the dark variants in RippleColors.xcassets. The
    // Watch target uses them for a deterministic OLED-first presentation
    // because package color-asset luminosity variants are not resolved
    // consistently by the current watchOS simulator/runtime combination.
    public static let watchSurface = Color(red: 0.071, green: 0.094, blue: 0.110)
    public static let watchSurfaceElevated = Color(red: 0.082, green: 0.125, blue: 0.149)
    public static let watchText = Color(red: 0.718, green: 0.878, blue: 0.910)
    public static let watchLagoon = Color(red: 0.310, green: 0.702, blue: 0.776)
    public static let watchAqua = Color(red: 0.435, green: 0.859, blue: 0.910)

    public static let success = waterLagoon
    public static let danger = Color.red.opacity(0.82)
}
