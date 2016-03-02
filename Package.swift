import PackageDescription

let package = Package(
    name: "ZewoSimpleRouter",
    dependencies: [
		.Package(url: "https://github.com/Zewo/Zewo.git", majorVersion: 0, minor: 3),
		.Package(url: "https://github.com/Zewo/CURIParser.git", majorVersion: 0),
		.Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0),
		.Package(url: "https://github.com/Zewo/CLibvenice.git", majorVersion: 0),
	]
)
