// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Base",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "Base",
            targets: ["Base"]
        ),
        .library(
            name: "BaseWatch",
            targets: ["BaseWatch"]
        ),
        .library(
            name: "DependencyContainer",
            targets: ["DependencyContainer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/rryam/MusadoraKit.git", from: "1.7.2"),
        .package(url: "git@github.com:nerdsupremacist/FancyScrollView.git", from: "0.1.4"),
        .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", from: "1.0.5"),
        .package(url: "git@github.com:fuzz-productions/tuva-core-iosmodule.git", branch: "master"),
        .package(url: "git@github.com:fuzz-productions/fuzz-combine-iosmodule.git", branch: "master"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "5.25.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.37.0"),
        .package(url: "https://github.com/omaralbeik/Drops.git", from: "1.5.0"),
        .package(url: "https://github.com/KaneCheshire/Communicator.git", from: "4.1.0"),
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
                "Drops",
                "Communicator",
                .product(name: "TuvaCore", package: "tuva-core-iosmodule"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "FuzzCombine", package: "fuzz-combine-iosmodule"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DependencyContainer",
            ]
        ),
        .target(
            name: "BaseWatch",
            dependencies: [
                "Communicator",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "TuvaCore", package: "tuva-core-iosmodule"),
                .product(name: "FuzzCombine", package: "fuzz-combine-iosmodule"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DependencyContainer",
            ]
        ),
        .testTarget(
            name: "BaseTests",
            dependencies: ["Base"]
        ),
    ]
)
