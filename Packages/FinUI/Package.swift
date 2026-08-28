// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FinUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FinUI", targets: ["FinUI"])
    ],
    dependencies: [
        .package(path: "../FinCore")
    ],
    targets: [
        .target(
            name: "FinUI",
            dependencies: ["FinCore"],
            path: "Sources/FinUI"
        )
    ]
)
