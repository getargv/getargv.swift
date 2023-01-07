// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Cgetargv",
  products: [
    .library(name: "SwiftGetargv", targets: ["SwiftGetargv"]),
    .library(name: "Cgetargv", targets: ["Cgetargv"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
  ],
  targets: [
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
