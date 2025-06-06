// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KangPhoto",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "KangPhoto", targets: ["KangPhoto"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "KangPhoto",
            dependencies: [],
            path: "KangPhoto/Sources"
        )
    ]
)