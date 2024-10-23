// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImplicitChecker",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "ImplicitChecker", targets: ["ImplicitChecker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj", from: "8.20.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ImplicitChecker",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XcodeProj", package: "XcodeProj"),
            ]
        ),
        .testTarget(
            name: "ImplicitCheckerTests",
            dependencies: ["ImplicitChecker"]
        ),
    ]
)
