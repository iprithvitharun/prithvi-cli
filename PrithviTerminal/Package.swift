// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PrithviTerminal",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "PrithviTerminal",
            dependencies: ["SwiftTerm"],
            path: "PrithviTerminal",
            exclude: ["Info.plist", "PrithviTerminal.entitlements", "AppIcon.icns", "Assets.xcassets"]
        ),
    ]
)
