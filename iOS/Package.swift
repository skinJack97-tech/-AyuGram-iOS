// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AyuGram",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "AyuGram", targets: ["AyuGram"])
    ],
    dependencies: [
        .package(url: "https://github.com/Swiftgram/TDLibKit", branch: "master"),
    ],
    targets: [
        .target(
            name: "AyuGram",
            dependencies: ["TDLibKit"],
            path: "AyuGram"
        )
    ]
)
