// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Endpoints",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_14)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Endpoints",
            targets: ["Endpoints"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "Endpoints", dependencies: []),
        .testTarget(name: "EndpointsTests", dependencies: ["Endpoints"]),
    ]
)
