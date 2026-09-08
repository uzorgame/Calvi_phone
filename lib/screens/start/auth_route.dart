import 'package:flutter/material.dart';

import '../../design/shell.dart';
import '../../design/tokens.dart';
import 'sign_in.dart';

/// Вхід, відкритий не з першого запуску, а з профілю.
///
/// **Той самий екран, а не другий такий самий.** У картці акаунта стояли дві
/// кнопки провайдерів, і вона входила сама. Відколи зʼявився вхід поштою, це
/// означало показувати два способи з чотирьох і мовчати про решту, а місця під
/// усі чотири в картці немає і бути не має: профіль це не екран входу.
///
/// Тепер картка веде сюди, а сюди приїжджає [SignIn] зі «Старту». Один екран на
/// всі способи, один на весь застосунок, і будь-який новий спосіб зʼявляється
/// тут сам собою, без другої копії правил про те, що робити після входу.
///
/// **Анкети за цим екраном немає.** На першому запуску після входу йде «Про
/// тебе», бо профілю ще не існує. Сюди приходить людина, яка вже місяць
/// користується застосунком: її зріст і ціль лежать на телефоні, і питати їх
/// заново означало б стерти те, що вона вводила. Тому обидва кінці входу тут
/// однакові й обидва просто закривають екран.
class AuthRoute extends StatefulWidget {
  const AuthRoute({super.key, this.page = AuthPage.in_});

  /// З якої сторінки починати: вхід чи реєстрація.
  final AuthPage page;

  @override
  State<AuthRoute> createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  late AuthPage _page = widget.page;

  /* Куди веде стрілка згори. З реєстрації і відновлення на вхід, з коду на
     реєстрацію, а з самого входу вже з екрана: позаду нього профіль. */
  void _back() {
    switch (_page) {
      case AuthPage.in_:
        Navigator.of(context).pop(false);
      case AuthPage.up:
      case AuthPage.forgot:
        setState(() => _page = AuthPage.in_);
      case AuthPage.code:
        setState(() => _page = AuthPage.up);
    }
  }

  /* Вхід відбувся, або людина передумала. В обох випадках екран закривається, і
     різниця лише в тому, чи має картка акаунта перечитати себе. */
  void _done(bool signedIn) {
    if (mounted) Navigator.of(context).pop(signedIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Прозорий: під сторінкою лежить ґрунт, який знає тему.
      backgroundColor: const Color(0x00000000),
      body: SafeArea(
        child: Column(
          children: [
            /* Шапка та сама, що в «Старті», але без смуги кроків: кроків тут
               немає, і порожня смуга обіцяла б анкету, якої не буде. */
            Padding(
              padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 6, CalviSize.gutter, 22),
              child: Row(children: [CalviBack(onTap: _back)]),
            ),
            Expanded(
              child: SignIn(
                page: _page,
                onPage: (p) => setState(() => _page = p),
                onNew: () => _done(true),
                onEntered: () async => _done(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
