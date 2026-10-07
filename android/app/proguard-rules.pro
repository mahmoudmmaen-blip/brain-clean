# R8 / ProGuard — Brain Clean release keeps for plugins used at runtime.

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Exceptions

-dontwarn sun.misc.**
-dontwarn com.google.gson.stream.**
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# --- Gson TypeToken (flutter_local_notifications + any JSON models) ---
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# --- flutter_local_notifications ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- RevenueCat / purchases_flutter ---
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# --- Supabase / OkHttp / Kotlin serialization ---
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class kotlinx.serialization.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# --- local_auth / BiometricPrompt ---
-keep class androidx.biometric.** { *; }
-keep class androidx.fragment.app.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# --- flutter_secure_storage ---
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }
-keep class android.security.keystore.** { *; }

# --- Play Billing (RevenueCat dependency) ---
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# --- Flutter embedding / plugins ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- Play Core (referenced by Flutter deferred components; not used at runtime) ---
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
