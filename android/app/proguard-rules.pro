# Add rules to keep Flutter and plugin classes, but obfuscate the rest
# Flutter recommended ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class com.shounakmulay.** { *; }
-keep class com.dexterous.** { *; }
-keep class com.example.sms_phish_detective.** { *; }
-keep class androidx.** { *; }
-keep class io.** { *; }
-keep class org.** { *; }
-keep class android.** { *; }
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-keep class com.google.** { *; }
-keep class com.baseflow.** { *; }
-keep class com.yourcompany.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugins.**
-dontwarn io.flutter.app.**
-dontwarn com.shounakmulay.**
-dontwarn com.dexterous.**
-dontwarn com.example.sms_phish_detective.**
-dontwarn androidx.**
-dontwarn io.**
-dontwarn org.**
-dontwarn android.**
-dontwarn kotlin.**
-dontwarn kotlinx.**
-dontwarn com.google.**
-dontwarn com.baseflow.**
-dontwarn com.yourcompany.**
# Obfuscate everything else
#-dontobfuscate
#-dontoptimize
#-dontpreverify
#-dontshrink
