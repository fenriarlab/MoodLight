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

    // 🌟 自定义 Android 原生输出 APK 档名格式：MoodLight_v1.0.0_release.apk
    applicationVariants.all(object : org.gradle.api.Action<com.android.build.gradle.api.ApplicationVariant> {
        override fun execute(variant: com.android.build.gradle.api.ApplicationVariant) {
            variant.outputs.all(object : org.gradle.api.Action<com.android.build.gradle.api.BaseVariantOutput> {
                override fun execute(output: com.android.build.gradle.api.BaseVariantOutput) {
                    val outputImpl = output as com.android.build.gradle.internal.api.BaseVariantOutputImpl
                    val appName = "MoodLight"
                    val versionName = variant.versionName
                    val buildType = variant.buildType.name
                    outputImpl.outputFileName = "${appName}_v${versionName}_${buildType}.apk"
                }
            })
        }
    })
}

// 🌟 自动生成 Flutter 输出目录下的自定义命名副本：MoodLight_v1.0.0_release.apk
tasks.whenTaskAdded {
    if (name.startsWith("assemble")) {
        doLast {
            val flutterApkDir = file("../../build/app/outputs/flutter-apk")
            val defaultApk = file("$flutterApkDir/app-release.apk")
            val versionName = android.defaultConfig.versionName ?: "1.0.0"
            if (defaultApk.exists()) {
                val customApk = file("$flutterApkDir/MoodLight_v${versionName}_release.apk")
                defaultApk.copyTo(customApk, overwrite = true)
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
