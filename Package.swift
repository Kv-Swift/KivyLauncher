// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport


let kivy = true
let local = false

let pykit_package: Package.Dependency = if kivy {
    .package(url: "https://github.com/kv-swift/PySwiftKit", from: .init(311, 0, 0))
} else {
    if local {
        .package(path: "../PySwiftKit")
    } else {
        .package(url: "https://github.com/py-swift/PySwiftKit", from: .init(311, 0, 0))
    }
}

let py_launcher_package : Package.Dependency = if local {
    .package(path: "../PythonLauncher")
} else {
    .package(url: "https://github.com/kv-swift/PythonLauncher", from: .init(0, 0, 0))
}

let kivycore_package: Package.Dependency = if local {
    .package(path: "../KivyCore")
} else {
    .package(url: "https://github.com/kv-swift/KivyCore", from: .init(311, 0, 0))
}


let pykit: Target.Dependency = if kivy {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
} else {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
}


let package = Package(
    name: "KivyLauncher",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KivyLauncher",
            targets: ["KivyLauncher"]),
    ],
	dependencies: [
		.package(url: "https://github.com/kv-swift/PythonCore", .upToNextMajor(from: .init(311, 0, 0))),
        kivycore_package,
        pykit_package,
        py_launcher_package
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KivyLauncher",
			dependencies: [
				.product(name: "SwiftonizeModules", package: "PySwiftKit"),
				//.product(name: "PythonCore", package: "PythonCore"),
				.product(name: "PythonLibrary", package: "PythonCore"),
                .product(name: "KivyCore", package: "KivyCore", condition: .when(platforms: [.iOS])),
                "PythonLauncher"
			],
            swiftSettings: [
                .define("KIVY"),
                .define("ANDROID", .when(platforms: [.android]))
            ]
		),
		
		

    ]
)
