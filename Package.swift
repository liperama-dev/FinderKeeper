// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FinderContextualUtilities",
    platforms: [.macOS(.v10_13)],
    products: [
        .executable(
            name: "FinderContextualUtilities",
            targets: ["FinderContextualUtilities"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "FinderContextualUtilities",
            dependencies: [],
            path: "FinderContextualUtilities"
        ),
    ]
)
