// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "otp_forge",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "otp-forge", targets: ["otp_forge"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "otp_forge",
            dependencies: [],
            path: "../Classes"
        )
    ]
)
