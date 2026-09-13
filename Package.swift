// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PulseUI",
platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .visionOS("26.0")
    ],
    products: [
        .library(
            name: "PulseUI",
            targets: ["PulseUI"]
        ),
        .library(
            name: "PulseCLI",
            targets: ["PulseCLI"]
        ),
        .executable(
            name: "pulse-render",
            targets: ["PulseRender"]
        ),
        .executable(
            name: "pulse",
            targets: ["Pulse"]
        ),
    ],
    targets: [
        .target(
            name: "PulseUI",
            path: "Sources/PulseUI"
        ),
        .target(
            name: "PulseCLI",
            path: "Sources/PulseCLI"
        ),
        .testTarget(
            name: "PulseUITests",
            dependencies: ["PulseUI"],
            path: "Tests/PulseUITests"
        ),
        .testTarget(
            name: "PulseCLITests",
            dependencies: ["PulseCLI"],
            path: "Tests/PulseCLITests"
        ),
        .executableTarget(
            name: "PulseRender",
            dependencies: ["PulseUI"],
            path: "Tools/PulseRender"
        ),
        .executableTarget(
            name: "Pulse",
            dependencies: ["PulseCLI"],
            path: "Tools/Pulse",
            exclude: ["generate_embedded.swift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
