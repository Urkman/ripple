// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleData",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .watchOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
    ],
    products: [
        .library(name: "RippleData", targets: ["RippleData"]),
    ],
    dependencies: [
        .package(path: "../RippleDomain"),
    ],
    targets: [
        .target(
            name: "RippleData",
            dependencies: ["RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "RippleDataTests",
            dependencies: ["RippleData", "RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
