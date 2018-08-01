// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoreSwift",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    ],
    targets: [
        .target(
            name: "GoreSwift",
            dependencies: ["GoreSwiftCore", "Commander"]
        ),
        .target(
            name: "GoreSwiftCore"
        ),
    ]
)
