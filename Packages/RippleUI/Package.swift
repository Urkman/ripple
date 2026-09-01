// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleUI",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .watchOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
    ],
    products: [
        .library(name: "RippleUI", targets: ["RippleUI"]),
    ],
    targets: [
        .target(
            name: "RippleUI",
            resources: [
                .process("Resources/RippleColors.xcassets"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ],
            linkerSettings: [
                .linkedFramework("CoreMotion", .when(platforms: [.iOS])),
            ]
        ),
        .testTarget(
            name: "RippleUITests",
            dependencies: ["RippleUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
