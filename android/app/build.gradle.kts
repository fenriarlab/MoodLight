plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.moodlight.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.moodlight.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// 🌟 构建完成后自动生成包含确切版本号的 APK 副本：MoodLight_v1.0.1_release.apk
tasks.configureEach {
    if (name == "assembleRelease") {
        doLast {
            val versionName = project.findProperty("version-name")?.toString()
                ?: android.defaultConfig.versionName
                ?: "1.0.1"

            val flutterApkDir = file("../../build/app/outputs/flutter-apk")
            val releaseApkDir = file("${layout.buildDirectory.get()}/outputs/apk/release")
            val targetName = "MoodLight_v${versionName}_release.apk"

            val defaultFlutterApk = file("$flutterApkDir/app-release.apk")
            if (defaultFlutterApk.exists()) {
                defaultFlutterApk.copyTo(file("$flutterApkDir/$targetName"), overwrite = true)
            }

            val defaultReleaseApk = file("$releaseApkDir/app-release.apk")
            if (defaultReleaseApk.exists()) {
                defaultReleaseApk.copyTo(file("$releaseApkDir/$targetName"), overwrite = true)
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
