// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription



let package = Package(
	name: "PopCommon",
	
	platforms: [
		.iOS(.v15),
		.macOS(.v10_15)
	],
	

	products: [
		.library(
			name: "PopCommon",
			targets: [
				"PopCommon","PopCommonObjc","PopCommonTests"
			]),
	],
	targets: [

		.target(
			name: "PopCommon",
			dependencies: []
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
