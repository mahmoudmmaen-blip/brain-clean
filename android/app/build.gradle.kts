import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

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
        // Aligned with existing Google Play package name.
        applicationId = "com.brainclean.mobile"
        // RevenueCat 10.x / Play Billing Library 8.3.0 requires API 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // Google Play 16 KB page-size requirement (Android 15+ / 64-bit).
        externalNativeBuild {
            cmake {
                arguments += "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
            }
        }
    }

    packaging {
        jniLibs {
            // Keep native libs uncompressed so zip-align can honor 16 KB ELF LOAD alignment.
            useLegacyPackaging = false
        }
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
            // Prefer gitignored release keystore when present; otherwise keep the
            // existing debug signing path so local AAB compile still works.
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
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

// flutter_jailbreak_detection pulls com.github.scottyab:rootbeer:0.1.0
// (libtoolChecker.so at 4 KB ELF alignment). Force the 16 KB–safe artifact.
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.github.scottyab" && requested.name == "rootbeer") {
            useTarget("com.scottyab:rootbeer-lib:0.1.1")
            because(
                "Replace 4KB-aligned RootBeer with 16KB-safe com.scottyab:rootbeer-lib:0.1.1",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
