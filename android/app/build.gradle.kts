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
            /* Release means the release key, or no build at all.
             *
             * There used to be a fallback: no key.properties, sign with the
             * debug key so the build still runs. That silence cost a real
             * evening: a debug-signed "release" APK went out to people, and
             * Google sign-in has every right to treat an unknown signature as
             * a stranger. A build that stops with a message costs a minute;
             * a build that lies about its signature costs testers.
             *
             * When Android Studio's wizard signs, we stay out of the way: the
             * keystore and passwords come from the wizard, not this file. */
            if (!studioSigns) {
                check(keyFile.exists()) {
                    "android/key.properties не знайдено. Release підписується " +
                        "тільки релізним ключем; відлагоджувального запасного " +
                        "більше немає, бо такий APK уже одного разу пішов людям. " +
                        "Поклади key.properties поруч із цим файлом або збирай " +
                        "через майстер Android Studio."
                }
                signingConfig = signingConfigs.getByName("release")
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
