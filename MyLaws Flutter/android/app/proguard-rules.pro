# Drift & SQLite
-keep class * extends drift.** { *; }
-keep class * extends org.sqlite.** { *; }
-keep class * extends com.almworks.sqlite4java.** { *; }

# Flutter & Plugins
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
