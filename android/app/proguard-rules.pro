# Keep annotations
-keep @interface proguard.annotation.Keep
-keep @interface proguard.annotation.KeepClassMembers

# Keep Razorpay SDK classes
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }

# Keep class members if annotated with @Keep
-keepclassmembers class * {
    @proguard.annotation.Keep <fields>;
    @proguard.annotation.Keep <methods>;
}

# =======================
# Firebase Performance Monitoring
# =======================
-keep class com.google.firebase.perf.** { *; }
-keep interface com.google.firebase.perf.** { *; }
-dontwarn com.google.firebase.perf.**
-keep class com.google.firebase.perf.network.FirebasePerfUrlConnection { *; }
-keep class com.google.firebase.perf.network.** { *; }
