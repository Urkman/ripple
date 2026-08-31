import Foundation

public enum RippleIdentifiers: Sendable {
    public static let appGroup = bundleValue("RippleAppGroup") ?? "group.de.stefansturm.ripple"
    public static let iCloudContainer = bundleValue("RippleiCloudContainer") ?? "iCloud.de.stefansturm.ripple"
    public static let healthUUIDKey = "app.ripple.intakeUUID"
    public static let healthSourceKey = "app.ripple.source"

    private static func bundleValue(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}
