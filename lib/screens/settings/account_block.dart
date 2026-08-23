import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/day.dart';
import '../../data/local/database.dart';
import '../../data/remote/login_service.dart';
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

  /// Поки триває обмін із Google. Другий тап дав би другий вхід.
  bool _busy = false;

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

  Future<void> _signIn() async {
    final login = _login;
    if (login == null) return;

    setState(() => _busy = true);
    final result = await login.signIn(deviceName: L.of(context).accountSettingsDevice);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case LoginResult.done:
      case LoginResult.canceled:
        await _load();
      case LoginResult.needsChoice:
        await _ask(login);
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

  /* Два щоденники, і жоден не можна викинути мовчки.
   *
   * Людина увійшла в акаунт, у якому вже щось є, а на телефоні лежать її власні
   * записи. Вибір тут необоротний в обидва боки, тому він словами, а не
   * кнопкою «ОК». */
  Future<void> _ask(LoginService login) async {
    await calviSheet<void>(
      context,
      title: L.of(context).accountWhichDiary,
      doneLabel: L.of(context).accountKeepCloud,
      onDone: () async {
        await login.keepAccount();
        await _load();
      },
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 4, CalviSize.gutter, 12),
        child: Text(L.of(sheet).accountWhichDiaryNote, style: sheet.t.bodyMedium),
      ),
    );

    /* Аркуш закрили, не обравши: людина лишається там, де була, а вхід
       скасовується. Мовчазний вхід «наполовину» був би найгіршим із варіантів. */
    if (login.pending != null) {
      await login.keepLocal();
      if (mounted) await _load();
    }
  }

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
            ? _SignedOut(busy: _busy, onTap: _signIn)
            : _SignedIn(email: email, joinedAt: _meta?.joinedAt, onOut: _signOut),
      ],
    );
  }
}

/// Картка того, хто увійшов: пошта, спосіб входу, дата і вихід.
class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.email, required this.joinedAt, required this.onOut});

  final String email;
  final DateTime? joinedAt;
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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.fillSecondary),
                child: Text(
                  email.substring(0, 1).toUpperCase(),
                  style: context.t.titleMedium?.copyWith(color: c.textSecondary),
                ),
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
                    Text(L.of(context).accountVia, style: context.t.labelSmall),
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
  const _SignedOut({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final can = AppScope.maybeOf(context)?.sync?.login.available ?? false;

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
              label: busy ? L.of(context).accountBusy : L.of(context).accountGoogle,
              onTap: busy ? () {} : onTap,
            ),
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
