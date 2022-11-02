// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "StringSimilarity",
    products: [
        .library(
            name: "StringSimilarity",
            targets: ["StringSimilarity"]
        ),
    ],
    targets: [
        .target(
            name: "StringSimilarity",
            dependencies: []
        ),
        .testTarget(
            name: "StringSimilarityTests",
            dependencies: ["StringSimilarity"]
        )
    ]
)
