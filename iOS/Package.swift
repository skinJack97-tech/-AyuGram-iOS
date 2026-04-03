// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AyuGram",
    platforms: [
        .iOS(.v15) // Понижаем до iOS 15 для максимальной совместимости
    ],
    products: [
        .library(name: "AyuGram", targets: ["AyuGram"])
    ],
    dependencies: [
        // Меняем branch: "master" на branch: "main", так как GitHub теперь использует main
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
