// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuizTrain",
    products: [
        .library(
            name: "QuizTrain",
            type: .dynamic,
            targets: ["QuizTrain"]),
    ],
    targets: [
        .target(
            name: "QuizTrain",
            dependencies: [],
        .testTarget(
            name: "QuizTrainTests",
            dependencies: ["QuizTrain"],
            resources: [
                .copy("Tests/QuizTrainTests/Testing\ Misc/TestCredentials.json"),
            ]),
    ]
)
