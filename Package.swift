// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport


let kivy = true
let local = false

let pykit_package: Package.Dependency = if kivy {
    .package(url: "https://github.com/KivySwiftLink/PySwiftKit", from: .init(311, 0, 0))
} else {
    if local {
        .package(path: "/Users/codebuilder/Documents/GitHub/PySwiftKit")
    } else {
        .package(url: "https://github.com/PythonSwiftLink/PySwiftKit", from: .init(311, 0, 0))
    }
}

let kivycore_package: Package.Dependency = if local {
    .package(path: "../KivyCore")
} else {
    .package(url: "https://github.com/KivySwiftLink/KivyCore", from: .init(311, 0, 0))
}


let pykit: Target.Dependency = if kivy {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
} else {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
}

let kivycore: Target.Dependency = if kivy {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
} else {
    .product(name: "SwiftonizeModules", package: "PySwiftKit")
}

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
//		.package(url: "https://github.com/KivySwiftLink/KivyCore", .upToNextMajor(from: .init(311, 0, 0))),
        kivycore_package,
//		.package(url: "https://github.com/KivySwiftLink/PythonSwiftLink", .upToNextMajor(from: .init(311, 0, 0))),
        pykit_package
		//.package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
//		.macro(
//			name: "KivyLauncherMacros",
//			dependencies: [
//				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//				.product(name: "SwiftCompilerPlugin", package: "swift-syntax")
//			]
//		),
        .target(
            name: "KivyLauncher",
			dependencies: [
				.product(name: "PySwiftObject", package: "PySwiftKit"),
				.product(name: "PySwiftCore", package: "PySwiftKit"),
				.product(name: "PythonCore", package: "PythonCore"),
				.product(name: "PythonLibrary", package: "PythonCore"),
				.product(name: "KivyCore", package: "KivyCore"),
				//"KivyLauncherMacros"
			],
            swiftSettings: [
                .define("KIVY")
            ]
		),
		
		

    ]
)
