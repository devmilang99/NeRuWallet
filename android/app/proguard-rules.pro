# NeRuWallet Security Hardening ProGuard Rules

# Obfuscate all code except for Flutter-specific entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }

# Keep our native security provider methods for MethodChannel
-keep class com.example.neruwallet.SecurityProvider { *; }
-keep class com.example.neruwallet.MainActivity { *; }

# Obfuscate internal logic
-repackageclasses 'com.example.neruwallet.internal'
-allowaccessmodification

# Remove Log calls in release builds for extra stealth
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Cryptography protection
-keepclassmembers class * extends java.security.Signature { *; }
-keepclassmembers class * extends java.security.KeyPairGenerator { *; }
-keepclassmembers class * extends java.security.KeyStore { *; }

# Fix R8/ProGuard errors for Play Core and ML Kit
-dontwarn com.google.android.play.core.**
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.vision.common.internal.ContextUtils
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# JNA and UniFFI rules to prevent native library loading failures
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.Library { *; }
-keep class * extends com.sun.jna.Structure { *; }
-keep class * implements com.sun.jna.Callback { *; }
-keep class uniffi.** { *; }

# Keep the generated UniFFI bindings
-keep class uniffi.rust_signer.** { *; }
