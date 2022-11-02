// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "StringMetric",
    products: [
        .library(
            name: "StringMetric",
            targets: ["StringMetric"]
        ),
    ],
    targets: [
        .target(
            name: "StringMetric",
            dependencies: []
        ),
        .testTarget(
            name: "StringMetricTests",
            dependencies: ["StringMetric"]
        )
    ]
)
