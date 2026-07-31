// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription



let package = Package(
	name: "PopCommon",
	
	platforms: [
		.iOS(.v15),
		.macOS(.v14)
	],
	

	products: [
		.library(
			name: "PopCommon",
			targets: [
				"PopCommon","PopCommonObjc"
				//,"PopCommonTests"	this is making projects fail
			]),
	],
	
	dependencies: [
		.package(url: "https://github.com/NewChromantics/CoreGraphicsExtensions.SwiftPackage", branch: "main")
	],
	
	targets: [

		.target(
			name: "PopCommon",
			dependencies: [
				.product(name: "CoreGraphicsExtensions", package: "CoreGraphicsExtensions.SwiftPackage")
			]
		),
		.target(
			name: "PopCommonObjc",
			dependencies: []
		),
		.testTarget(
			name: "PopCommonTests",
			dependencies: ["PopCommon"], 
			path: "Tests"
			)
			
	]
)
