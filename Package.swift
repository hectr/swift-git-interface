// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "GitInterface",
    dependencies: [
        .Package(url: "https://github.com/hectr/swift-shell-interface", majorVersion: 0)
    ]
)
