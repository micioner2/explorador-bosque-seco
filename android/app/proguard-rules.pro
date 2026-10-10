# ML Kit: ignorar scripts opcionales no incluidos en este build (chino, devanagari, japonés, coreano)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Mantener clases ML Kit necesarias en runtime
-keep class com.google.mlkit.** { *; }
-keep class com.google_mlkit_** { *; }
