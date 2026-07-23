plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseStoreFilePath = keystoreProperties.getProperty("storeFile")
val releaseStoreFile = releaseStoreFilePath?.let { file(it) }
val canSignRelease = keystorePropertiesFile.exists()
    && !keystoreProperties.getProperty("keyAlias").isNullOrBlank()
    && !keystoreProperties.getProperty("keyPassword").isNullOrBlank()
    && !keystoreProperties.getProperty("storePassword").isNullOrBlank()
    && releaseStoreFile != null
    && releaseStoreFile.exists()

android {
    namespace = "com.brainclean.mobile"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.brainclean.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (canSignRelease) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
                storeFile = releaseStoreFile
            }
        }
    }

    buildTypes {
        release {
            // Prefer gitignored release keystore when present; otherwise fall back to
            // debug signing so local `flutter build appbundle` still verifies compile.
            // Do not upload a debug-signed bundle to Play.
            signingConfig = if (canSignRelease) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "brain_clean_mobile: release keystore missing or incomplete " +
                        "(android/key.properties + storeFile). Using debug signing — " +
                        "not valid for Play upload.",
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
