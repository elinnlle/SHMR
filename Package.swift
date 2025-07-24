// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FinanceApp",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FinanceApp",
            targets: ["FinanceApp"]
        )
    ],
    dependencies: [
        // Lottie‑анимации
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "4.5.2"
        ),
        // Локальный пакет Utilities
        .package(path: "Utilities")
    ],
    targets: [
        .target(
            name: "FinanceApp",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "PieChart", package: "Utilities")
            ],
            path: "FinanceApp",
            resources: [
                .process("Resources"),
                .process("Assets.xcassets"),
                .process("Settings.bundle"),
                .process("Preview Content/Preview Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "FinanceAppTests",
            dependencies: ["FinanceApp"],
            path: "FinanceAppTests"
        )
    ]
)
