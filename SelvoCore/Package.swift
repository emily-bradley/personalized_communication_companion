// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SelvoCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SelvoCore", targets: ["SelvoCore"]),
    ],
    targets: [
        .target(name: "SelvoCore"),
        .testTarget(name: "SelvoCoreTests", dependencies: ["SelvoCore"]),
    ]
)
