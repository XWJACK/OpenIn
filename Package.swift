// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenIn",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "OpenIn", targets: ["OpenIn"])
    ],
    targets: [
        .executableTarget(
            name: "OpenIn",
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
