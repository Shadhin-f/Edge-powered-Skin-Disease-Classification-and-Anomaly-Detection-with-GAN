plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin - temporarily disabled
}

android {
    namespace = "com.example.project991"
    compileSdk = 35  // Updated from 34 to 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.project991"
        minSdk = 21 // Firebase minSdk requirement
        targetSdk = 34  // Keep at 34 for now - upgrade later with proper testing
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now, using debug signing config
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Firebase dependencies - temporarily disabled
    // Import the Firebase BoM
    // implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-bom:32.7.0")
    // Example: Firebase Analytics
    // implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase products here
    // e.g. Authentication: implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}