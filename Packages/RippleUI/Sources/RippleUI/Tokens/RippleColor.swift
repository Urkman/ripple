import SwiftUI

public enum RippleColor {
    public static let waterDeep = Color("RippleWaterDeep", bundle: .module)
    public static let waterLagoon = Color("RippleWaterLagoon", bundle: .module)
    public static let waterAqua = Color("RippleWaterAqua", bundle: .module)
    public static let waterFoam = Color("RippleWaterFoam", bundle: .module)
    public static let glassHighlight = Color.white
    public static let surface = Color("RippleSurface", bundle: .module)
    public static let success = waterLagoon
    public static let danger = Color.red.opacity(0.82)
}
