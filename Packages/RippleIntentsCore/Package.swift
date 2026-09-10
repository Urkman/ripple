// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleIntentsCore",
    defaultLocalization: "en",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .watchOS("27.0"),
        .tvOS("27.0"),
        .visionOS("27.0"),
    ],
    products: [
        .library(name: "RippleIntentsCore", targets: ["RippleIntentsCore"]),
    ],
    dependencies: [
        .package(path: "../RippleDomain"),
    ],
    targets: [
        .target(
            name: "RippleIntentsCore",
            dependencies: ["RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "RippleIntentsCoreTests",
            dependencies: ["RippleIntentsCore", "RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
