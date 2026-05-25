// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RollingNumbers",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        // .visionOS(.v1),  // add when you want visionOS
    ],
    products: [
        .library(
            name: "RollingNumbers",
            targets: ["RollingNumbers"]
        ),
    ],
    targets: [
        .target(
            name: "RollingNumbers",
            dependencies: []
        ),
    ]
)
