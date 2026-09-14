// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault")
]

let package = Package(
  name: "VoiceRecognitionProfileGenerator",
  defaultLocalization: "en",
  platforms: [.macOS(.v27)],
  products: [
    .executable(name: "generate-profile", targets: ["VoiceRecognitionProfileGenerator"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.5.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "VoiceRecognitionProfileGenerator",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [
        .process("Localizable.xcstrings")
      ],
      swiftSettings: upcomingFeatures
    )
  ],
  swiftLanguageModes: [.v6]
)
