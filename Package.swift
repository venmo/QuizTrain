// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Quiztrain",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "QuizTrain",
            targets: ["QuizTrain"]),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "QuizTrain",
            dependencies: []),
        .testTarget(
            name: "QuizTrainTests",
            dependencies: ["QuizTrain"]),
    ]
)
