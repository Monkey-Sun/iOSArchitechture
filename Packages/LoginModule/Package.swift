// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoginModule",
    platforms: [.iOS(.v15)], // 指定支持的最低平台
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LoginModule",
            targets: ["LoginModule"]
        ),
    ],
    dependencies: [
        .package(path: "../AppRouting"),
        .package(path: "../AppModuleFacade")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LoginModule",
            dependencies: [
                .product(name: "AppRouting", package: "AppRouting"),
                .product(name: "AppModuleFacade", package: "AppModuleFacade")
            ]
        ),
        .testTarget(
            name: "LoginModuleTests",
            dependencies: ["LoginModule"]
        ),
    ]
)
