# flutter_local_notifications: keep plugin + gson-serialised classes so scheduled
# reminders survive R8 shrinking in release builds.
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
