// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FinCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FinCore", targets: ["FinCore"])
    ],
    targets: [
        .target(name: "FinCore", path: "Sources/FinCore")
    ]
)
