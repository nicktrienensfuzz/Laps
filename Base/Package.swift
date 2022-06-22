// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Base",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Base",
            targets: ["Base"]),
    ],
    dependencies: [
        .package(url: "git@github.com:rryam/MusadoraKit.git", from: "1.3.0"),
        .package(url: "git@github.com:nerdsupremacist/FancyScrollView.git", from: "0.1.4"),
        .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", from: "1.0.5"),
        .package(url: "git@github.com:fuzz-productions/tuva-core-iosmodule.git", from: "0.0.5"),
        .package(url: "git@github.com:fuzz-productions/fuzz-combine-iosmodule.git", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "Base",
            dependencies: [
                "MusadoraKit",
                "FancyScrollView",
                "AsyncLocationKit",
                .product(name: "TuvaCore", package: "tuva-core-iosmodule")
                ]
        ),
        .testTarget(
            name: "BaseTests",
            dependencies: ["Base"]),
    ]
)
