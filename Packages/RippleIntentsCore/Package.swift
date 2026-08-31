// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleIntentsCore",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .watchOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
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
