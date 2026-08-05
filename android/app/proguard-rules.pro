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
