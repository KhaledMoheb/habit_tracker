plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin must be applied after Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.khaled.habitt_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.khaled.habitt_app" // ✅ keep consistent
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Kotlin DSL uses function call instead of Groovy string
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
