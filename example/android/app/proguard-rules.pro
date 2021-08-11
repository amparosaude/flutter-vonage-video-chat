#Flutter Wrapper
-keep class com.opentok.android.* { *; }
-keep class com.opentok.android.Session { *; }
-keep class com.opentok.client.* { *; }
-keep class com.opentok.impl.* { *; }
-keep class com.opentok.otc.* { *; }
-keep class org.webrtc.* { *; }
-keep class org.otwebrtc.* { *; }
-keep class org.otwebrtc.voiceengine.* { *; }
-keep class org.otwebrtc.voiceengine.*
-keep class org.otwebrtc.WebRtcClassLoader{*;}
-keep class org.otwebrtc.voiceengine61.* { *; }
-keep class org.otwebrtc.voiceengine.BuildInfo { *; }

-dontwarn com.opentok.*
-keepclassmembers class com.opentok.* { *; }