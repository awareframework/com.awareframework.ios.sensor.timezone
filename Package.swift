// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.timezone",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.timezone",
            targets: [
                "com.awareframework.ios.sensor.timezone"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/awareframework/com.awareframework.ios.core.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.timezone",
            dependencies: [
                .product(name: "com.awareframework.ios.core", package: "com.awareframework.ios.core", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/com.awareframework.ios.sensor.timezone"
        ),
        .testTarget(
            name: "com.awareframework.ios.sensor.timezoneTests",
            dependencies: ["com.awareframework.ios.core", "com.awareframework.ios.sensor.timezone"]
        )
    ],
    swiftLanguageModes: [.v5]
)
