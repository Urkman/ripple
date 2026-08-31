// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RippleDomain",
    defaultLocalization: "en",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .watchOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
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
