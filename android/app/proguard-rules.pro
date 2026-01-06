# Flutter default ProGuard rules - Always include these first
-ignorewarnings
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- Stripe SDK: Keep required classes ---
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
# If you are using react-native-stripe-sdk, keep this. Otherwise, it can be removed.
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# ================================================
# Specific Rules for Shared Preferences
# ================================================
# Keep SharedPreferences native bridge and its Pigeon-generated classes
# The "channel-error" specifically points to Pigeon interfaces being stripped.
-keep class io.flutter.plugins.shared_preferences.** { *; }
-dontwarn io.flutter.plugins.shared_preferences.**
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }
-dontwarn dev.flutter.pigeon.shared_preferences_android.**


# ================================================
# Specific Rules for Flutter InAppWebView
# ================================================
# Keep all flutter_inappwebview plugin classes and their dependencies
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

# Keep Android WebView core functionality
-keep class android.webkit.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**


-keep class * implements io.flutter.plugin.platform.PlatformViewFactory { *; }


# ================================================
# General Flutter Plugin System Preservation
# ================================================
# Ensure all FlutterPlugin implementations are kept, as they are entry points
# for native plugin registration.
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.plugin.common.MethodCallHandler { *; }


# Prevent obfuscation of specific Flutter internal classes related to plugin registration.
-keep class io.flutter.embedding.engine.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep generated plugin classes (e.g., in GeneratedPluginRegistrant)
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }



# If you have any custom native code or third-party SDKs, add rules for them too.