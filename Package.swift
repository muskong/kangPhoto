// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "KangPhoto",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "KangPhoto", targets: ["KangPhoto"])
    ],
    targets: [
        .executableTarget(
            name: "KangPhoto",
            path: ".",
            sources: ["main.swift", "AppDelegate.swift", "MouseTrackingView.swift"]
        )
    ]
)