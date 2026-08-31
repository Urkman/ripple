// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleFeatures",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .watchOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
    ],
    products: [
        .library(name: "RippleFeatures", targets: ["RippleFeatures"]),
    ],
    dependencies: [
        .package(path: "../RippleDomain"),
        .package(path: "../RippleUI"),
    ],
    targets: [
        .target(
            name: "RippleFeatures",
            dependencies: ["RippleDomain", "RippleUI"],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self),
            ]
        ),
        .testTarget(
            name: "RippleFeaturesTests",
            dependencies: ["RippleFeatures", "RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .defaultIsolation(MainActor.self),
            ]
        ),
    ]
)
