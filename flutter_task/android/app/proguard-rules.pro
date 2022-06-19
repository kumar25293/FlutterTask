# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#-libraryjars libs/jmdns-3.4.1.jar
#-libraryjars libs/sadp.jar
#-libraryjars libs/wificonfig.jar

-keepparameternames
-dontwarn com.squareup.**
-dontwarn okio.**
-renamesourcefileattribute SourceFile
-dontwarn com.googlecode.mp4parser.**
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
-keep public class * {
      public protected *;
}

-keepclassmembernames class * {
    java.lang.Class class$(java.lang.String);
    java.lang.Class class$(java.lang.String, boolean);
}

-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

-keepclassmembers,allowoptimization enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
#Try adding All Interface in package
-keep interface * {
  <methods>;
}


#Try adding layout
#-keepclassmembers class **.R$layout {
   # public static <fields>;
#}
#-keepclassmembers class **.R$string {
   # public static <fields>;
#}





