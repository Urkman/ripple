// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleDomain",
    defaultLocalization: "en",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .watchOS("27.0"),
        .tvOS("27.0"),
        .visionOS("27.0"),
    ],
    products: [
        .library(name: "RippleDomain", targets: ["RippleDomain"]),
    ],
    targets: [
        .target(
            name: "RippleDomain",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "RippleDomainTests",
            dependencies: ["RippleDomain"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
