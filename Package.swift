// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FinderKeeper",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "FinderKeeper",
            targets: ["FinderKeeper"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FinderKeeper",
            dependencies: [],
            path: "FinderKeeper"
        ),
    ]
)
