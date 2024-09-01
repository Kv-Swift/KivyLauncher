// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KivyLauncher",
	platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KivyLauncher",
            targets: ["KivyLauncher"]),
    ],
	dependencies: [
		.package(url: "https://github.com/KivySwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0))),
		.package(url: "https://github.com/KivySwiftLink/PythonSwiftLink", .upToNextMajor(from: .init(311, 0, 0))),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KivyLauncher",
			dependencies: [
				.product(name: "PySwiftObject", package: "PythonSwiftLink"),
				.product(name: "PySwiftCore", package: "PythonSwiftLink"),
				.product(name: "PythonCore", package: "PythonCore"),
				.product(name: "PythonLibrary", package: "PythonCore")
			]
		),

    ]
)
