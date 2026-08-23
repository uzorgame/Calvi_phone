import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

/* Ключ підпису лежить поза репозиторієм.
 *
 * У `key.properties` пароль і шлях до сховища, і саме тому файла тут немає і не
 * буде: ключ, який потрапив у репозиторій, це ключ, яким може підписатись хтось
 * інший. Магазин розрізняє застосунки за підписом, а не за назвою.
 *
 * Немає файла, збірка не падає, а підписується відлагоджувальним ключем, як і
 * раніше. Так `flutter run --release` працює на будь-якій машині, а справжній
 * підпис вмикається сам там, де ключ є. */
val keyProps = Properties()
val keyFile = rootProject.file("key.properties")
if (keyFile.exists()) keyFile.inputStream().use(keyProps::load)

/* Android Studio підписує сам, і тоді ми в це не лізьмо.
 *
 * Майстер «Generate Signed App Bundle» передає сховище й паролі окремими
 * властивостями збірки, і саме він, а не цей файл, вирішує, чим підписано.
 * Тому за такої збірки ми не чіпаємо підпис узагалі: інакше вийшов би спір, у
 * якому виграє незрозуміло хто, а ціна помилки це відхилений магазином файл. */
val studioSigns = project.hasProperty("android.injected.signing.store.file")

android {
    namespace = "com.calvi.calvi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Планувальник сповіщень користується сучасним календарем Java, якого на
        // старших Android немає. Десугарування підкладає його в застосунок, і
        // нагадування працюють на всіх телефонах, а не тільки на нових.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.calvi.calvi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keyFile.exists()) {
            create("release") {
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            /* Справжній ключ, якщо він є, і відлагоджувальний, якщо немає.
             *
             * Магазин відлагоджувальний підпис відхиляє, і це правильно: ним
             * може підписатись будь-хто. Але падати без ключа теж не варіант,
             * бо тоді збірку неможливо перевірити на машині без нього.
             *
             * Коли підписує Android Studio, тут не робиться нічого: підпис
             * приходить від майстра. */
            if (!studioSigns) {
                signingConfig =
                    if (keyFile.exists()) signingConfigs.getByName("release")
                    else signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
