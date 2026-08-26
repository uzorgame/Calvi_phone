import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../l10n/data_lang.dart';

/// Вхід через Apple, з боку телефона.
///
/// Та сама дисципліна, що і в Google: тут рівно один крок, показати системний
/// аркуш Apple і взяти з нього `identityToken`. Перевіряє його сервер, бо
/// телефон не має права вирішувати, хто перед ним.
///
/// Відмінності від Google дві, і обидві на користь простоти. Ніяких
/// ідентифікаторів клієнта: аркуш системний, застосунок упізнається за своїм
/// пакетом і підписом. І ніякої ініціалізації: викликати можна одразу.
class AppleLogin {
  AppleLogin();

  /// Чи можна взагалі показувати кнопку.
  ///
  /// Вхід через Apple живе тільки на пристроях Apple. Android-версія плагіна
  /// існує, але вимагає веб-обв'язки, якої в нас немає, а кнопка Apple на
  /// Android і не потрібна: правило магазину стосується лише iOS.
  bool get available =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Чому не вийшло минулого разу, словами Apple.
  ///
  /// Порожньо після відмови людини: «передумав» це не помилка, і показувати
  /// після нього нема чого.
  String? lastError;

  /* Той самий журнал, що і в Google, і з тієї ж причини: один вечір здогадок
     навчив, що рядок справжньої причини в logcat вартий більше за будь-яку
     теорію. Мітка спільна навмисно, щоб `grep CalviAuth` показував обидва
     входи поруч. */
  static void _note(String what) {
    // ignore: avoid_print
    print('CalviAuth[apple]: $what');
  }

  /// Токен для сервера, або порожньо, якщо людина передумала.
  Future<String?> identityToken() async {
    lastError = null;
    _note('старт: platform=$defaultTargetPlatform');

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      ).timeout(const Duration(seconds: 60));

      final token = credential.identityToken;
      _note('успіх: токен=${token == null ? 'НЕМАЄ' : '${token.length} символів'}');
      if (token == null) lastError = dataL.loginNoToken;
      return token;
    } on TimeoutException {
      _note('таймаут: 60 секунд без відповіді від аркуша');
      lastError = dataL.loginSlow;
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      /* Відмова людини не лишає помилки: аркуш закрили, і це нормальна
         відповідь. Усе інше лишає, бо «нічого не сталось» після дотику
         читається як зламана кнопка. */
      _note('AuthorizationException: code=${e.code.name} | ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) return null;
      lastError = dataL.loginServer(e.code.name);
      return null;
    } catch (e, stack) {
      _note('несподіване: $e\n$stack');
      lastError = e.toString();
      return null;
    }
  }

  /// Apple не тримає на телефоні вибору, який треба забувати: аркуш питає
  /// щоразу. Метод існує для симетрії з Google, щоб вихід не знав різниці.
  Future<void> forget() async {}
}
