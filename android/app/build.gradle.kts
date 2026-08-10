plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("androidx.baselineprofile")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("org.mozilla.rust-android-gradle.rust-android")
}

android {
    namespace = "com.example.neruwallet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.neruwallet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true

        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
        }
    }

    signingConfigs {
        getByName("debug") {
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storeFile = file("debug.keystore")
            storePassword = "android"
        }
    }

    buildTypes {
        debug {
            // ...
        }

        release {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    baselineProfile {
        filter {
            include("com.example.neruwallet.**")
        }
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
            // Point to the relocated build directory where the rust-android-gradle plugin
            // will place its generated JNI libraries.
            jniLibs.srcDirs(file("${layout.buildDirectory.get().asFile}/rustJniLibs"))
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.biometric:biometric:1.1.0")
    implementation("net.java.dev.jna:jna:5.14.0@aar")
}

tasks.register<Exec>("generateUniFFIBindings") {
    workingDir = file("../../rust_signer")
    // Use the local uniffi-bindgen wrapper built from the crate
    commandLine(
        "cargo",
        "run",
        "--bin",
        "uniffi-bindgen",
        "--",
        "generate",
        "src/rust_signer.udl",
        "--language",
        "kotlin",
        "--out-dir",
        "${projectDir}/src/main/kotlin"
    )
}

afterEvaluate {
    tasks.named("preBuild") {
        dependsOn("generateUniFFIBindings")
    }
}

cargo {
    module = "../../rust_signer"
    libname = "uniffi_rust_signer"
    targets = listOf("arm", "arm64", "x86", "x86_64")
}

