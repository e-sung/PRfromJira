// swift-tools-version: 5.5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PRfromJira",
    platforms: [.macOS(.v12)],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "PRfromJira",
            dependencies: [],
            resources: [.process("./Manuals/SETUP.md"), .process("./Manuals/USAGE.md")]
        ),
        .testTarget(
            name: "PRfromJiraTests",
            dependencies: ["PRfromJira"]
        ),
    ]
)
