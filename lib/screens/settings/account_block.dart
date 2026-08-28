import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/day.dart';
import '../../data/local/database.dart';
import '../../data/remote/login_service.dart';
import '../../design/brand_marks.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Обліковий запис у профілі.
///
/// Два стани, і другий не менш важливий за перший. Людина, яка на початку
/// натиснула «поки без входу», не мала жодного способу увійти пізніше: кнопка
/// стояла тільки на екрані знайомства, а він більше не показується. Тому тут не
/// просто напис із поштою, а вхід, доступний з будь-якого дня.
///
/// Замість імені й аватарки стоїть перша літера пошти. Імені ми не питаємо, і
/// брати фото нізвідки: у дозволах Google ми просимо рівно пошту й показуємо
/// рівно її.
class AccountBlock extends StatefulWidget {
  const AccountBlock({super.key});

  @override
  State<AccountBlock> createState() => _AccountBlockState();
}

class _AccountBlockState extends State<AccountBlock> {
  /* Стан акаунта лежить у базі, а не в екрані: вхід і вихід міняють його зовні,
     і єдина правда тут одна на весь застосунок. Порожньо, поки база не
     відповіла, і це кадр або два. */
  SyncMetaData? _meta;

  /* Хто саме зараз заходить, а не просто «хтось заходить».
   *
   * Тут стояв один прапорець на дві кнопки, і напис «Заходимо» зʼявлявся на
   * кнопці Google, коли людина тиснула Apple. Зайнятість має знати, чия вона:
   * інакше екран показує роботу не в тому місці, де вона йде. */
  String? _busyWith;

  /// Чи вже питали базу. Залежності можуть змінитись не раз, а акаунт один.
  bool _asked = false;

  /* Не в `initState`: там `AppScope` ще не можна читати, бо успадковані віджети
     стають доступними лише після нього. Flutter каже про це прямо, і тест на
     геометрію профілю впіймав саме це. */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_asked) return;
    _asked = true;
    unawaited(_load());
  }

  Future<void> _load() async {
    final db = AppScope.maybeOf(context)?.db;
    if (db == null) return;
    final meta = await db.syncDao.state();
    if (!mounted) return;
    setState(() => _meta = meta);
  }

  LoginService? get _login => AppScope.maybeOf(context)?.sync?.login;

  Future<void> _signIn() => _enter('google', (login, device) => login.signIn(deviceName: device));

  Future<void> _signInApple() =>
      _enter('apple', (login, device) => login.signInApple(deviceName: device));

  /* Обидва входи проходять одним шляхом навмисно: оновлення картки і текст
     помилки не мають залежати від того, якою кнопкою людина скористалась.
     Різниця лише в тому, чия кнопка показує зайнятість. */
  Future<void> _enter(
    String who,
    Future<LoginResult> Function(LoginService login, String device) go,
  ) async {
    final login = _login;
    if (login == null) return;

    setState(() => _busyWith = who);
    final LoginResult result;
    try {
      result = await go(login, L.of(context).accountSettingsDevice);
    } finally {
      /* У `finally`, бо між підняттям і опусканням стоїть чекання: один виняток
         лишав екран входу зайнятим назавжди, до перезаходу в застосунок. */
      if (mounted) setState(() => _busyWith = null);
    }
    if (!mounted) return;

    switch (result) {
      case LoginResult.done:
      case LoginResult.canceled:
        await _load();
      case LoginResult.partial:
        /* Вхід відбувся, просто щоденник цього разу не доїхав. Картку
           оновлюємо, кнопку не пропонуємо вдруге. */
        await _load();
      case LoginResult.failed:
        if (!mounted) return;
        /* Причина в тексті навмисно. «Спробуй ще раз» без неї це порада нічого
           не робити: людина тисне вдруге і отримує те саме, а ми лишаємось без
           жодної зачіпки, бо до сервера такий збій не доходить. */
        final why = login.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              why == null
                  ? L.of(context).accountSignInFailed
                  : L.of(context).accountSignInFailedWhy(why),
            ),
            duration: const Duration(seconds: 10),
          ),
        );
    }
  }

  /* Питання «який щоденник лишити» тут більше немає, і це не спрощення екрана,
     а зміна правди під ним: сервер зливає безіменний акаунт пристрою у
     справжній прямо під час входу. Обидва щоденники однієї людини, і вибір
     «який викинути» був хибним питанням. */

  Future<void> _signOut() async {
    final login = _login;
    if (login == null) return;

    await calviSheet<void>(
      context,
      title: L.of(context).accountSignOutAsk,
      doneLabel: L.of(context).accountSignOut,
      onDone: () async {
        await login.signOut();
        await _load();
      },
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(L.of(sheet).accountSignOutNote, style: sheet.t.bodyMedium),
            const SizedBox(height: 10),
            Text(L.of(sheet).accountSignOutBack, style: sheet.t.labelSmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _meta?.email;

    return CalviSection(
      title: L.of(context).accountTitle,
      bare: true,
      trail: 0,
      children: [
        email == null
            ? _SignedOut(busyWith: _busyWith, onTap: _signIn, onApple: _signInApple)
            : _SignedIn(
                email: email,
                joinedAt: _meta?.joinedAt,
                provider: _meta?.provider,
                onOut: _signOut,
              ),
      ],
    );
  }
}

/// Картка того, хто увійшов: пошта, спосіб входу, дата і вихід.
class _SignedIn extends StatelessWidget {
  const _SignedIn({
    required this.email,
    required this.joinedAt,
    required this.provider,
    required this.onOut,
  });

  final String email;
  final DateTime? joinedAt;

  /// Ким увійшли: 'google', 'apple', або порожньо на акаунтах до цього оновлення.
  final String? provider;
  final VoidCallback onOut;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              /* Знак того, ким увійшли, а не перша літера пошти.
               *
               * Літера тут стояла з часів, коли вхід був один. Пошта-ретранслятор
               * Apple починається з випадкових символів, і людина, яка зайшла
               * через Apple, бачила в кружечку «G» і підпис «Вхід через Google»:
               * обидва неправда. Провайдера тепер каже сервер, а не здогад по
               * пошті, бо здогад тут неможливий: Apple вміє віддавати і
               * справжню адресу. */
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                child: switch (provider) {
                  'apple' => AppleMark(size: 21, color: c.text),
                  'google' => const GoogleMark(size: 19),
                  _ => Text(
                    email.substring(0, 1).toUpperCase(),
                    style: context.t.titleMedium?.copyWith(color: c.textSecondary),
                  ),
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider == 'apple'
                          ? L.of(context).accountViaApple
                          : L.of(context).accountVia,
                      style: context.t.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          /* Дата тихіша за пошту навмисно: головне тут те, у який акаунт ти
             увійшов, а не коли це сталося. Її може не бути зовсім, якщо вхід
             стався до того оновлення, яке почало її запитувати. */
          if (joinedAt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.cardBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(L.of(context).accountSince, style: context.t.labelSmall),
                  Text(
                    '${joinedAt!.day} ${monthName(joinedAt!.month)} ${joinedAt!.year}',
                    style: context.t.labelSmall?.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          GestureDetector(
            onTap: onOut,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(L.of(context).accountSignOutAction, style: context.t.bodyMedium),
                  ),
                  CalviIcon('chevron', size: 15, color: c.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Картка того, хто не входив: чому це варто зробити, і кнопка.
class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.busyWith, required this.onTap, required this.onApple});

  /// Чия саме кнопка зараз працює: 'google', 'apple' або порожньо.
  final String? busyWith;
  bool get busy => busyWith != null;
  final VoidCallback onTap;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final login = AppScope.maybeOf(context)?.sync?.login;
    final can = login?.available ?? false;
    final canApple = login?.appleAvailable ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.cardBorder),
        borderRadius: BorderRadius.circular(CalviSize.rLarge),
        boxShadow: context.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L.of(context).accountNoAccountNote, style: context.t.bodyMedium),

          /* Кнопка є тільки тоді, коли за нею щось стоїть. Порожній
             ідентифікатор означає, що вхід не налаштований у цій збірці, і
             кнопка, яка нічого не робить, гірша за її відсутність. */
          if (can) ...[
            const SizedBox(height: 14),
            CalviButton(
              label: busyWith == 'google' ? L.of(context).accountBusy : L.of(context).accountGoogle,
              enabled: !busy,
              onTap: onTap,
            ),
          ],

          /* Apple там, де Apple: на Android цей шлях нікуди не веде, і вхід,
             яким не можна пройти, гірший за один шлях менше. */
          if (canApple) ...[
            const SizedBox(height: 10),
            CalviGhost(
              label: busyWith == 'apple'
                  ? L.of(context).accountBusy
                  : L.of(context).startSignInApple,
              enabled: !busy,
              onTap: onApple,
            ),
          ],

          if (can) ...[
            const SizedBox(height: 12),
            Text(
              L.of(context).accountScopeNote,
              style: context.t.labelSmall?.copyWith(color: c.faint),
            ),
          ],
        ],
      ),
    );
  }
}
