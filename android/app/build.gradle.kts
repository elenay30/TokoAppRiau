plugins {
    id("com.android.application")
    // Google Services plugin sudah ada di classpath, jadi tinggal apply
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.toko_app"
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
        applicationId = "com.example.toko_app"
        // PERBAIKAN: Update minSdk untuk Google Sign-In
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // PERBAIKAN: Tambahkan multiDexEnabled
        multiDexEnabled = true
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

dependencies {
    // PERBAIKAN: Gunakan versi yang kompatibel dengan Google Services 4.3.15
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Versi yang kompatibel dengan plugin Google Services 4.3.15
    implementation("com.google.android.gms:play-services-auth:20.5.0")
    implementation("com.google.firebase:firebase-auth:21.3.0")
    implementation("com.google.firebase:firebase-core:21.1.1")
    implementation("com.google.firebase:firebase-firestore:24.6.1")
    
    // Base dependencies untuk mencegah konflik
    implementation("com.google.android.gms:play-services-base:18.1.0")
    implementation("com.google.android.gms:play-services-basement:18.1.0")
}