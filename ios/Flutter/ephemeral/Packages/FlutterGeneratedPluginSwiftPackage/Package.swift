// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.22.0"),
        .package(name: "pointer_interceptor_ios", path: "../.packages/pointer_interceptor_ios-0.10.1"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.7.1"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.3.3"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.4"),
        .package(name: "purchases_flutter", path: "../.packages/purchases_flutter-9.9.5"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.4.0"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.12+2"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-5.9.0"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-3.14.0"),
        .package(name: "firebase_storage", path: "../.packages/firebase_storage-12.4.7"),
        .package(name: "firebase_performance", path: "../.packages/firebase_performance-0.10.1+7"),
        .package(name: "firebase_dynamic_links", path: "../.packages/firebase_dynamic_links-6.1.6"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-4.3.7"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-5.6.0"),
        .package(name: "firebase_analytics", path: "../.packages/firebase_analytics-11.5.0"),
        .package(name: "file_picker", path: "../.packages/file_picker-10.1.9"),
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore-5.6.9"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "pointer-interceptor-ios", package: "pointer_interceptor_ios"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "purchases-flutter", package: "purchases_flutter"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-storage", package: "firebase_storage"),
                .product(name: "firebase-performance", package: "firebase_performance"),
                .product(name: "firebase-dynamic-links", package: "firebase_dynamic_links"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
