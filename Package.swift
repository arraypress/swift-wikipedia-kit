// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WikipediaKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "WikipediaKit",
            targets: ["WikipediaKit"]),
    ],
    targets: [
        .target(
            name: "WikipediaKit",
            swiftSettings: [
                // Async functions run on the caller's executor rather than hopping
                // to the global pool — Swift 6.2's "nonisolated nonsending" default.
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ]),
        .testTarget(
            name: "WikipediaKitTests",
            dependencies: ["WikipediaKit"]),
    ]
)

// Swift 7's import rule, today: a file must import every module whose members
// it uses, rather than leaning on another file's imports.
for target in package.targets where target.type != .system && target.type != .binary && target.type != .plugin {
    target.swiftSettings = (target.swiftSettings ?? []) + [.enableUpcomingFeature("MemberImportVisibility")]
}
