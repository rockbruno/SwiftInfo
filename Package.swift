// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftInfo",
    products: [
        .library(name: "SwiftInfoCore", type: .dynamic, targets: ["SwiftInfoCore"]),
        .executable(name: "swiftinfo", targets: ["SwiftInfo"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .exact("8.5.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Csourcekitd: C modules wrapper for sourcekitd.
        .target(
            name: "Csourcekitd",
            dependencies: []
        ),
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftInfoCore",
            dependencies: [
                "Csourcekitd",
                .product(name: "XcodeProj", package: "xcodeproj"),
            ]
        ),
        .target(
            name: "SwiftInfo",
            dependencies: [
                "SwiftInfoCore",
                .product(name: "ArgumentParser", package: "xcodeproj"),
            ]
        ),
        .testTarget(
            name: "SwiftInfoTests",
            dependencies: ["SwiftInfo"]
        ),
    ]
)
