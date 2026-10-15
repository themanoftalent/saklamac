// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Saklamac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Saklamac",
            targets: ["Saklamac"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Saklamac",
            path: "Sources/Saklamac",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        )
    ]
)
