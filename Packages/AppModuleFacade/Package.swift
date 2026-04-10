// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppModuleFacade",
    platforms: [.iOS(.v15)], // 指定支持的最低平台
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppModuleFacade",
            targets: ["AppModuleFacade"]
        ),
    ],
    dependencies: [
        // 如果本地库需要依赖第三方库（如 SnapKit），在此添加
        .package(path: "../AppRouting")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppModuleFacade",
            dependencies: [
                .product(name: "AppRouting", package: "AppRouting")
            ]
        ),
        .testTarget(
            name: "AppModuleFacadeTests",
            dependencies: ["AppModuleFacade"]
        ),
    ]
)
