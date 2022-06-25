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
        .library(
            name: "DependencyContainer",
            targets: ["DependencyContainer"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:rryam/MusadoraKit.git", from: "1.3.0"),
        .package(url: "git@github.com:nerdsupremacist/FancyScrollView.git", from: "0.1.4"),
        .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", from: "1.0.5"),
        .package(url: "git@github.com:fuzz-productions/tuva-core-iosmodule.git", from: "0.0.5"),
        .package(url: "git@github.com:fuzz-productions/fuzz-combine-iosmodule.git", from: "0.0.5"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "5.13.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.37.0")
       
 
    ],
    targets: [
        .target(
            name: "DependencyContainer"
        ),
        .target(
            name: "Base",
            dependencies: [
                "MusadoraKit",
                "FancyScrollView",
                "AsyncLocationKit",
                .product(name: "TuvaCore", package: "tuva-core-iosmodule"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name:"FuzzCombine", package: "fuzz-combine-iosmodule"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DependencyContainer"
                ]
        ),
        .testTarget(
            name: "BaseTests",
            dependencies: ["Base"]),
    ]
)
