// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Getargv",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "SwiftGetargv", targets: ["SwiftGetargv"]),
        .library(name: "Cgetargv",     targets: ["Cgetargv"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5"),
    ],
    targets: [
        .executableTarget(
            name: "getargv2",
            dependencies: [
                "SwiftGetargv",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        ),
        .executableTarget(
            name: "getargv",
            dependencies: [
                "Cgetargv",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        ),
        .target(name: "SwiftGetargv", dependencies: [ "Cgetargv" ], swiftSettings: [ .strictMemorySafety() ]),
        .systemLibrary(
            name: "Cgetargv",
            pkgConfig: "getargv",
            providers: [ .brew(["libgetagv"]) ]
        ),
        .testTarget(
            name: "SwiftGetargvTests",
            dependencies: [ "SwiftGetargv" ]
        ),
        .testTarget(
            name: "CgetargvTests",
            dependencies: [ "Cgetargv" ]
        )
    ],
    cLanguageStandard: .c99 // https://developer.apple.com/documentation/packagedescription/clanguagestandard
)
