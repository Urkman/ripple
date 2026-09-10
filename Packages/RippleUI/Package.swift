// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleUI",
    defaultLocalization: "en",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .watchOS("27.0"),
        .tvOS("27.0"),
        .visionOS("27.0"),
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
                .linkedFramework("CoreMotion", .when(platforms: [.iOS, .watchOS])),
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
