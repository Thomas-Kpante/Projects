plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Apply the Google Services plugin using Kotlin DSL syntax.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.secure_chat"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.secure_chat"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdk = 23
    }

    buildTypes {
        release {
            // Use debug signing for now.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Import the Firebase BoM using Kotlin DSL syntax.
    implementation(platform("com.google.firebase:firebase-bom:32.1.1"))
    // Add the Firebase Auth dependency.
    implementation("com.google.firebase:firebase-auth")
    // ... any other dependencies you have.
}


flutter {
    source = "../.."
}
