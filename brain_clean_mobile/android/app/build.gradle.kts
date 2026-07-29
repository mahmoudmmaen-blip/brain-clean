plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Base64
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

/** Google sample Android AdMob App ID (safe default for debug / missing config). */
val googleTestAdmobAppId = "ca-app-pub-3940256099942544~3347511713"

/**
 * Reads Flutter `--dart-define=KEY=VALUE` entries passed as `-Pdart-defines`
 * (comma-separated Base64 payloads of `KEY=VALUE`).
 */
fun dartDefinesMap(): Map<String, String> {
    val raw = project.findProperty("dart-defines") as? String ?: return emptyMap()
    if (raw.isBlank()) return emptyMap()
    return raw.split(",")
        .mapNotNull { token ->
            val trimmed = token.trim()
            if (trimmed.isEmpty()) return@mapNotNull null
            try {
                val decoded = String(Base64.getDecoder().decode(trimmed), Charsets.UTF_8)
                val idx = decoded.indexOf('=')
                if (idx <= 0) null
                else decoded.substring(0, idx) to decoded.substring(idx + 1)
            } catch (_: IllegalArgumentException) {
                null
            }
        }
        .toMap()
}

fun resolveAdmobAndroidAppId(): String {
    val fromDart = dartDefinesMap()["ADMOB_ANDROID_APP_ID"]?.trim().orEmpty()
    val fromProp = (project.findProperty("ADMOB_ANDROID_APP_ID") as? String)?.trim().orEmpty()
    val candidate = when {
        fromDart.isNotEmpty() -> fromDart
        fromProp.isNotEmpty() -> fromProp
        else -> ""
    }
    // Ignore empty / documentation placeholders — never bake fake IDs into the APK.
    if (candidate.isEmpty()) return googleTestAdmobAppId
    if (candidate.contains("xxxxxxxx", ignoreCase = true)) return googleTestAdmobAppId
    if (candidate.contains("your_", ignoreCase = true)) return googleTestAdmobAppId
    if (!candidate.startsWith("ca-app-pub-")) return googleTestAdmobAppId
    return candidate
}

val admobAndroidAppId = resolveAdmobAndroidAppId()

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
        // Injected into AndroidManifest meta-data APPLICATION_ID.
        manifestPlaceholders["admobAppId"] = admobAndroidAppId
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
