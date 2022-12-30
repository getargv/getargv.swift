// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Cgetargv",
  pkgConfig: "getargv",
  providers: [ .brew(["libgetagv"]) ],
  //products: [ .library(name: "Cgetargv", targets: ["Cgetargv"]) ],
  /*
   targets: [
   .target(name: "Cgetargv"),
   .testTarget(name: "CgetargvTests", dependencies: ["Cgetargv"])
   ],
   */
  cLanguageStandard: .c99 // https://developer.apple.com/documentation/packagedescription/clanguagestandard
)
