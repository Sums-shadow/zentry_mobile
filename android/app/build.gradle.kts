import java.util.Properties
import java.nio.charset.StandardCharsets

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.reader(StandardCharsets.UTF_8).use { load(it) }
}
val mapsApiKey = localProps.getProperty("MAPS_API_KEY") ?: ""

android {
    namespace = "com.horiondrc.zentry"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.horiondrc.zentry"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 👇 IMPORTANT : injecte la clé dans le manifest via placeholder
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
        // (équivalent possible)
        // manifestPlaceholders.put("MAPS_API_KEY", mapsApiKey)
        // ou :
        // manifestPlaceholders = mapOf("MAPS_API_KEY" to mapsApiKey)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
