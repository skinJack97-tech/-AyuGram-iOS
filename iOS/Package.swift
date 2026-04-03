// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AyuGram",
    platforms: [
        .iOS(.v15) 
    ],
    products: [
        .library(name: "AyuGram", targets: ["AyuGram"])
    ],
    dependencies: [
        .package(url: "https://github.com/Swiftgram/TDLibKit", branch: "main"),
    ],
    targets: [
        .target(
            name: "AyuGram",
            dependencies: ["TDLibKit"],
            path: "AyuGram"
        )
    ]
)
