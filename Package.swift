// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftBoilerplate",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftBoilerplate",
            targets: ["SwiftBoilerplate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "SwiftBoilerplate",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
        .testTarget(
            name: "SwiftBoilerplateTests",
            dependencies: ["SwiftBoilerplate"]),
    ]
) 