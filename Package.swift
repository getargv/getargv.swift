// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Cgetargv",
  platforms: [.macOS(.v10_13)],
  products: [
    .library(name: "SwiftGetargv", targets: ["SwiftGetargv"]),
    .library(name: "Cgetargv", targets: ["Cgetargv"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
  ],
  targets: [
    .executableTarget(name: "getargv2", dependencies: [ "SwiftGetargv", .product(
                                                                     name: "ArgumentParser",
                                                                     package: "swift-argument-parser"
                                                                   )]),
    .executableTarget(name: "getargv", dependencies: [ "Cgetargv", .product(
                                                                     name: "ArgumentParser",
                                                                     package: "swift-argument-parser"
                                                                   )]),
    .target(name: "SwiftGetargv", dependencies: [ "Cgetargv" ]),
    .systemLibrary(name: "Cgetargv",  pkgConfig: "getargv",  providers: [ .brew(["libgetagv"]) ]),
    .testTarget(name: "SwiftGetargvTests", dependencies: [ "SwiftGetargv" ]),
    .testTarget(name: "CgetargvTests", dependencies: [ "Cgetargv" ])
  ],
  cLanguageStandard: .c99 // https://developer.apple.com/documentation/packagedescription/clanguagestandard
)
