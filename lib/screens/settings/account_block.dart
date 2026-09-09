import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/day.dart';
import '../../data/watch.dart';
import '../../data/local/database.dart';
import '../../data/remote/login_service.dart';
import '../../design/brand_marks.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/slide.dart';
import '../../l10n/app_localizations.dart';
import '../start/auth_route.dart';
import '../start/sign_in.dart';
import 'restored_sheet.dart';

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

  /* Вхід відкривається екраном, а не робиться тут.
   *
   * Доти картка входила сама, і всі правила про те, що робити після входу,
   * лежали в ній другою копією поруч із такими самими правилами «Старту». Тепер
   * копія одна: [AuthRoute] показує ту саму форму і той самий її кінець.
   *
   * Аркуш «дані відновлено» лишається тут, бо показувати його має той екран,
   * який лишається на місці: [AuthRoute] у цю мить уже закривається. */
  Future<void> _openAuth(AuthPage page) async {
    final signedIn = await Navigator.of(context).push<bool>(slideRoute(AuthRoute(page: page)));
    if (!mounted) return;

    await _load();
    if (signedIn != true) return;

    final login = _login;
    if (login != null && login.restored && mounted) await showRestoredSheet(context);
  }

  /* Питання «який щоденник лишити» тут більше немає, і це не спрощення екрана,
     а зміна правди під ним: сервер зливає безіменний акаунт пристрою у
     справжній прямо під час входу. Обидва щоденники однієї людини, і вибір
     «який викинути» був хибним питанням. */

  Future<void> _signOut() async {
    final login = _login;
    if (login == null) return;

    /* Вихід робить корінь застосунку: крім акаунта і бази треба забути профіль,
       препарати з нагадуваннями і розмову, яку тримає в памʼяті екран дня, а
       тоді повернутись на вітання. Ця панель до того часу вже зникне разом із
       налаштуваннями, тому оновлювати картку після виходу нема кому і нащо.
       Порожньо в демо-запуску без бази: там просто забуваємо акаунт. */
    final go = AppScope.maybeOf(context)?.signOut;

    await calviSheet<void>(
      context,
      title: L.of(context).accountSignOutAsk,
      doneLabel: L.of(context).accountSignOut,
      onDone: () async {
        if (go != null) return go();
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
            ? _SignedOut(onEnter: _openAuth)
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
                  /* Вхід поштою і невідомий провайдер діляться першою літерою
                     адреси. Знака в нас для них немає і вигадувати його нема
                     за чим: у Google і Apple свої марки саме тому, що людина
                     впізнає їх, а конверт нічого не каже, крім «пошта», яка й
                     так написана поруч. */
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
                    /* Підпис називає того, ким справді зайшли, і мовчить, коли
                       не знає.
                       Тут стояло «або Apple, або Google», і Google був
                       відповіддю на все інше. Через це людина, яка зайшла
                       поштою, читала про себе неправду. Порожньо для
                       невідомого провайдера краще за здогад: такі записи
                       лишились від входів, зроблених до того, як сервер почав
                       відповідати, ким саме зайшли, і вгадати це нізвідки. */
                    if (_via(context, provider) case final via?) ...[
                      const SizedBox(height: 3),
                      Text(via, style: context.t.labelSmall),
                    ],
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
                    '${dayMonth(joinedAt!.day, joinedAt!.month)} ${joinedAt!.year}',
                    style: context.t.labelSmall?.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          /* Годинник під акаунтом, бо він живе цим акаунтом: токен, мова і
             числа дня йдуть на нього звідси. Рядок є лише тоді, коли годинник
             у парі; телефону без годинника нема чого казати. */
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
            FutureBuilder<WatchStatus?>(
              future: Watch.status(),
              builder: (context, snap) {
                final w = snap.data;
                if (w == null || !w.paired) return const SizedBox.shrink();
                final l = L.of(context);
                final word = !w.installed
                    ? l.watchNotInstalled
                    : w.current
                    ? l.watchLinked
                    : l.watchWaiting;
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.cardBorder)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.accountWatch, style: context.t.labelSmall),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          word,
                          textAlign: TextAlign.end,
                          style: context.t.labelSmall?.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

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

/// Ким зайшли, словами. Порожньо, коли сервер цього не сказав.
String? _via(BuildContext context, String? provider) => switch (provider) {
  'apple' => L.of(context).accountViaApple,
  'google' => L.of(context).accountVia,
  'email' => L.of(context).accountViaEmail,
  _ => null,
};

/// Картка того, хто не входив: чому це варто зробити, і кнопка.
class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onEnter});

  /// Куди веде дотик: на екран входу, одразу на потрібну сторінку.
  final void Function(AuthPage) onEnter;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

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

          /* Дві дії замість двох провайдерів.
           *
           * Тут стояли «Продовжити з Google» і «Продовжити з Apple», і картка
           * входила сама. Відколи зʼявився вхід поштою, вона показувала два
           * способи з чотирьох і мовчала про решту, а місця під усі чотири в
           * ній немає і бути не має: профіль це не екран входу.
           *
           * Тепер картка не входить, а веде туди, де вхід і живе. Один екран
           * на всі способи, один на весь застосунок, і будь-який новий спосіб
           * зʼявляється там сам собою.
           *
           * Вагою дві дії різні навмисно: хто дійшов до профілю, найчастіше вже
           * має акаунт і просто не входив на цьому телефоні. */
          const SizedBox(height: 14),
          CalviButton(
            label: L.of(context).authSignInAction,
            onTap: () => onEnter(AuthPage.in_),
          ),
          const SizedBox(height: 10),
          CalviGhost(
            label: L.of(context).authSignUpLink,
            onTap: () => onEnter(AuthPage.up),
          ),
        ],
      ),
    );
  }
}
