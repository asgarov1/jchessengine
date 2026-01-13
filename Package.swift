
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "JChessEngine",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "JChessEngine", targets: ["JChessEngine"])
    ],
    targets: [
        .target(name: "JChessEngine"),
        .testTarget(name: "JChessEngineTests", dependencies: ["JChessEngine"])
    ]
)
