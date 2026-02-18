// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Utilities",
    defaultLocalization: "en",
    platforms: [.iOS(.v17),],
    products: [
        .library(
            name: "PieChart",
            type: .static,
            targets: ["PieChart"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PieChart",
            path: "Sources/PieChart",
        )
    ]
)
