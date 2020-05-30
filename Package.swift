// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftInfo",
    products: [
        .library(name: "SwiftInfoCore", type: .dynamic, targets: ["SwiftInfoCore"]),
        .executable(name: "swiftinfo", targets: ["SwiftInfo"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .exact("7.8.0"))
    ],
    targets: [
        // Csourcekitd: C modules wrapper for sourcekitd.
        .target(
            name: "Csourcekitd",
            dependencies: []),
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftInfoCore",
            dependencies: ["Csourcekitd", "XcodeProj"]),
        .target(
            name: "SwiftInfo",
            dependencies: ["SwiftInfoCore"]),
        .testTarget(
            name: "SwiftInfoTests",
            dependencies: ["SwiftInfo"]),
    ]
)
