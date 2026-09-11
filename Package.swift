// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pomo",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "pomo",
            targets: ["Pomo"]
        ),
        .library(
            name: "PomoCore",
            targets: ["PomoCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PomoCore",
            dependencies: [],
            path: "Sources/PomoCore"
        ),
        .executableTarget(
            name: "Pomo",
            dependencies: ["PomoCore"],
            path: "Sources/Pomo"
        ),
        .testTarget(
            name: "PomoTests",
            dependencies: ["PomoCore"],
            path: "Tests/PomoTests"
        )
    ]
)
