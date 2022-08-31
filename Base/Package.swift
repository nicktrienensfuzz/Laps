// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Base",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(
            name: "Logger",
            targets: ["Logger"]
        ),
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
        //.package(url: "git@github.com:fuzz-productions/tuva-core-iosmodule.git", branch: "master"),
        .package(path: "tuva-core-iosmodule-master")
        .package(path: "fuzz-combine-iosmodule-master")
        //.package(url: "git@github.com:fuzz-productions/fuzz-combine-iosmodule.git", branch: "master"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "5.25.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.37.0"),
        .package(url: "https://github.com/omaralbeik/Drops.git", from: "1.5.0"),
        .package(url: "https://github.com/KaneCheshire/Communicator.git", from: "4.1.0"),
        .package(url: "https://github.com/malcommac/SwiftSimplify.git", from: "1.1.0"),
        .package(url: "https://github.com/matteopuc/swiftui-navigation-stack.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DependencyContainer"
        ),
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "TuvaCore", package: "tuva-core-iosmodule"),
            ]

        ),
        .target(
            name: "Base",
            dependencies: [
                "MusadoraKit",
                "FancyScrollView",
                "AsyncLocationKit",
                "Drops",
                "Logger",
                "Communicator",
                .product(name: "NavigationStack", package: "swiftui-navigation-stack"),
                .product(name: "TuvaCore", package: "tuva-core-iosmodule-master"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "FuzzCombine", package: "fuzz-combine-iosmodule-master"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DependencyContainer",
                "SwiftSimplify",
            ]
        ),
        .target(
            name: "BaseWatch",
            dependencies: [
                "Communicator",
                "Logger",
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
