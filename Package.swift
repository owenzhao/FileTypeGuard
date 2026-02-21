// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FileTypeGuard",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FileTypeGuard",
            targets: ["FileTypeGuard"]
        )
    ],
    targets: [
        .executableTarget(
            name: "FileTypeGuard",
            path: "FileTypeGuard",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FileTypeGuardTests",
            dependencies: ["FileTypeGuard"],
            path: "Tests"
        )
    ]
)
