plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.abwaalaa.halati"
    // Pinned explicitly rather than left as flutter.compileSdkVersion,
    // which silently resolved to 31 on some CI Flutter installs and broke
    // the release build. Kept at the highest level any plugin currently
    // requires (package_info_plus, photo_manager, share_plus,
    // shared_preferences_android, url_launcher_android,
    // video_player_android, androidx.core 1.17.0 all need 36+ as of
    // Flutter stable 3.44.x) — bump this again if a future `flutter build`
    // log reports a plugin asking for something higher than 36.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.abwaalaa.halati"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val releaseKeystorePath = System.getenv("HALATI_KEYSTORE_PATH")
    val releaseStorePassword = System.getenv("HALATI_KEYSTORE_PASSWORD")
    val releaseKeyAlias = System.getenv("HALATI_KEY_ALIAS")
    val releaseKeyPassword = System.getenv("HALATI_KEY_PASSWORD")

    signingConfigs {
        create("halatiRelease") {
            if (!releaseKeystorePath.isNullOrBlank() && !releaseStorePassword.isNullOrBlank() &&
                !releaseKeyAlias.isNullOrBlank() && !releaseKeyPassword.isNullOrBlank()) {
                storeFile = file(releaseKeystorePath)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (!releaseKeystorePath.isNullOrBlank()) {
                signingConfigs.getByName("halatiRelease")
            } else {
                signingConfigs.getByName("debug")
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
