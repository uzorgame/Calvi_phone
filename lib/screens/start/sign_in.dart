import 'dart:async';

import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;

import '../../data/app_scope.dart';
import '../../data/legal.dart';
import '../../data/remote/login_service.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../settings/panel_legal.dart';
import '../settings/restored_sheet.dart';

/// Вхід і реєстрація, перший екран застосунку.
///
/// **Чому пошта, а не тільки Apple і Google.** Провайдер це чужий акаунт: у
/// людини його може не бути, вона могла загубити доступ, або просто не хоче
/// повʼязувати їжу з робочою поштою Google. Досі в нас не було жодного способу
/// завести акаунт без них, і це відрізало частину людей ще до першого екрана.
///
/// **Перший екран це вхід.** На ньому все, чим можна зайти: два провайдери,
/// пошта з паролем і рядок «Далі без акаунту». Хто повертається, робить свою
/// справу не сходячи з місця.
///
/// **Реєстрація це окрема сторінка, а не той самий екран з іншим написом.** На
/// ній три поля і більше нічого: пошта, пароль і його підтвердження. Провайдери
/// туди не переїжджають навмисно: людина, яка натиснула «Зареєструватись», уже
/// вибрала спосіб, і показувати їй ті самі дві кнопки вдруге означає питати те
/// саме після відповіді.
///
/// **Сторінка живе не тут, а в «Старті».** Стрілка «назад» намальована в його
/// шапці, поруч зі смугою, і знати, куди вона веде, має той, хто її малює.
/// Інакше на екрані стояли б дві стрілки з різною поведінкою.
enum AuthPage {
  /// Вхід: провайдери, пошта з паролем, «далі без акаунту».
  in_,

  /// Реєстрація: три поля.
  up,

  /// Шість цифр із листа.
  code,

  /// Забули пароль: спершу адреса, потім код і новий пароль.
  forgot,
}

/// Скільки цифр у коді з листа. Те саме число, що на сервері.
const _codeLen = 6;

/// Скільки секунд до того, як лист можна попросити знову.
const _againAfter = 45;

/* Наскільки надійним має бути пароль. Правило те саме, що на сервері, і
   перевіряється тут лише заради швидкої підказки: вирішує все одно сервер.
   Пʼять літер і хоча б один знак. Не «вісім символів»: `12345678` це вісім
   символів і водночас перший рядок будь-якого словника. */
const _minLetters = 5;
const _minMarks = 1;

final _letter = RegExp(r'\p{L}', unicode: true);
final _mark = RegExp(r'[^\p{L}\s]', unicode: true);

bool passwordOk(String p) =>
    _letter.allMatches(p).length >= _minLetters && _mark.allMatches(p).length >= _minMarks;

/// Пошта виглядає поштою. Точніша перевірка тут шкодить: адреси бувають дивні.
final _mail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

class SignIn extends StatefulWidget {
  const SignIn({
    super.key,
    required this.page,
    required this.onPage,
    required this.onNew,
    required this.onEntered,
    this.returning = false,
  });

  final AuthPage page;
  final ValueChanged<AuthPage> onPage;

  /// Акаунта не буде: далі анкета. Сюди ж веде «далі без акаунту».
  final VoidCallback onNew;

  /// Увійшли у наявний акаунт: профіль уже на сервері, анкету пропускаємо.
  final Future<void> Function() onEntered;

  /// Сюди прийшли з наміром повернутись, а не завести акаунт.
  final bool returning;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _mailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _againCtl = TextEditingController();
  final _codeCtl = TextEditingController();

  bool _agree = true;
  bool _seen = false;

  /* Хто саме зараз заходить, а не просто «хтось заходить». Один прапорець на
     всі кнопки показував би роботу не там, де вона йде. */
  String? _busyWith;
  bool get _busy => _busyWith != null;

  /// Помилка під конкретним полем: `mail`, `pass`, `again`, `code`.
  final _bad = <String, String>{};

  /// Скільки секунд до того, як можна попросити лист ще раз.
  int _left = 0;
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    _mailCtl.dispose();
    _passCtl.dispose();
    _againCtl.dispose();
    _codeCtl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SignIn old) {
    super.didUpdateWidget(old);
    /* Зміна сторінки чистить форму. Пароль, набраний для входу, не має лежати
       в полі реєстрації, а помилка, показана там, не має зустрічати людину
       тут: обидві стосувались іншого питання. */
    if (old.page != widget.page) {
      _bad.clear();
      _seen = false;
      if (widget.page != AuthPage.code) _codeCtl.clear();
      if (widget.page == AuthPage.in_ || widget.page == AuthPage.up) {
        _passCtl.clear();
        _againCtl.clear();
      }
    }
  }

  LoginService? get _login => AppScope.maybeOf(context)?.sync?.login;

  void _countdown() {
    _tick?.cancel();
    setState(() => _left = _againAfter);
    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left -= 1);
      if (_left <= 0) t.cancel();
    });
  }

  /* Один кінець на всі три входи: сервер відповідає однаково, якою дорогою
     людина б не зайшла, і застосунок далі не розрізняє способів. */
  Future<void> _finish(LoginResult result, {required bool fresh}) async {
    final login = _login;
    if (!mounted || login == null) return;

    switch (result) {
      case LoginResult.done:
      case LoginResult.partial:
        /* Акаунт стояв у черзі на видалення, і цей вхід зняв його з черги.
           Сказати про це треба тут, до того, як екран зміниться. */
        if (login.restored) await showRestoredSheet(context);
        if (!mounted) return;

        /* Свіжий акаунт це порожній акаунт: профілю в ньому немає, тому далі
           анкета. Вхід у наявний навпаки: профіль приїде обміном, і питати
           зріст у того, хто вводив його місяць тому, безглуздо. */
        if (fresh) {
          widget.onNew();
        } else {
          setState(() => _busyWith = 'wait');
          await widget.onEntered();
          if (mounted) setState(() => _busyWith = null);
        }
      case LoginResult.canceled:
        // Вікно закрили: не помилка, і казати нічого не треба.
        break;
      case LoginResult.failed:
        _say(login.error ?? L.of(context).startSignInFailed);
    }
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 8)));
  }

  Future<void> _run(String who, Future<void> Function() body) async {
    setState(() => _busyWith = who);
    try {
      await body();
    } finally {
      if (mounted) setState(() => _busyWith = null);
    }
  }

  // --- Дії --------------------------------------------------------------

  Future<void> _provider(String who) async {
    final login = _login;
    if (login == null) return widget.onNew();

    await _run(who, () async {
      final device = L.of(context).startDeviceFirstRun;
      final result = who == 'google'
          ? await login.signIn(deviceName: device)
          : await login.signInApple(deviceName: device);
      /* Провайдер може завести акаунт із нуля, і тоді анкету треба пройти.
         Сервер каже це полем `outcome`, а `LoginService` переказує його
         прапорцем: новий акаунт означає порожній профіль. */
      await _finish(result, fresh: login.created);
    });
  }

  Future<void> _enterByMail() async {
    final l = L.of(context);
    /* Вхід не звіряє формат адреси, на відміну від реєстрації й відновлення.
       Там без справжньої пошти нікуди слати лист, а тут поле лише шукають у
       базі. Ще й службові облікові записи, заведені руками, поштою не звуться:
       рев'ю App Store вимагає пару логін-пароль, і вигаданий «щось@десь.там» у
       їхній формі виглядає гірше за просте ім'я. Порожнє поле однаково не
       пройде: сервер відповість, що пара не підходить. */
    if (!_check(pass: 'any')) return;

    final login = _login;
    if (login == null) return;

    await _run('mail', () async {
      final result = await login.signInWithEmail(
        email: _mailCtl.text.trim(),
        password: _passCtl.text,
        deviceName: l.startDeviceFirstRun,
      );
      await _finish(result, fresh: login.created);
    });
  }

  Future<void> _register() async {
    if (!_check(mail: true, pass: 'strong', again: true)) return;

    final login = _login;
    if (login == null) return;

    await _run('mail', () async {
      final ok = await login.registerByEmail(
        email: _mailCtl.text.trim(),
        password: _passCtl.text,
      );
      if (!mounted) return;
      if (!ok) {
        /* Причина від сервера і під тим полем, якого вона стосується. «Цей
           акаунт вже зареєстровано» це про пошту, «пароль ненадійний» про
           пароль, і показувати обидві однаково внизу означало б змусити
           людину шукати, до чого вони. Поле називає сам сервер кодом помилки,
           а не ми розбором його слів. */
        final why = login.error ?? L.of(context).startSignInFailed;
        setState(() => _bad[login.badField ?? 'mail'] = why);
        return;
      }
      _countdown();
      widget.onPage(AuthPage.code);
    });
  }

  Future<void> _confirm() async {
    if (!_check(code: true)) return;

    final login = _login;
    if (login == null) return;

    await _run('code', () async {
      final l = L.of(context);
      /* Дві різні дороги з одного екрана. Реєстрація підтверджує пошту, і
         акаунт після неї порожній. Відновлення міняє пароль наявного, і
         анкети там бути не має. */
      final result = widget.page == AuthPage.forgot
          ? await login.resetPassword(
              email: _mailCtl.text.trim(),
              code: _codeCtl.text,
              password: _passCtl.text,
              deviceName: l.startDeviceFirstRun,
            )
          : await login.confirmEmail(
              email: _mailCtl.text.trim(),
              code: _codeCtl.text,
              deviceName: l.startDeviceFirstRun,
            );

      if (result == LoginResult.failed && mounted) {
        setState(() => _bad['code'] = login.error ?? l.authCodeBad);
        return;
      }
      await _finish(result, fresh: login.created);
    });
  }

  Future<void> _forgotSend() async {
    if (!_check(mail: true)) return;

    final login = _login;
    if (login == null) return;

    await _run('mail', () async {
      await login.forgotPassword(_mailCtl.text.trim());
      /* Відповідь однакова на знайому адресу і на незнайому, тому і тут
         однакова: інакше форма перетворюється на спосіб перевіряти, хто в нас
         зареєстрований. */
      _countdown();
      if (mounted) setState(() {});
    });
  }

  Future<void> _again() async {
    final login = _login;
    if (login == null) return;
    _countdown();
    await login.resendCode(
      email: _mailCtl.text.trim(),
      reset: widget.page == AuthPage.forgot,
    );
  }

  /* Перевірка форми. Вона тут не заради безпеки: усе вирішує сервер. Вона
     заради того, щоб не ганяти людину за листом по колу через одну літеру. */
  bool _check({bool mail = false, String? pass, bool again = false, bool code = false}) {
    final l = L.of(context);
    final e = <String, String>{};

    if (mail && !_mail.hasMatch(_mailCtl.text.trim())) e['mail'] = l.authMailBad;

    if (pass == 'any' && _passCtl.text.isEmpty) e['pass'] = l.authPassEmpty;
    if (pass == 'strong' && !passwordOk(_passCtl.text)) e['pass'] = l.authPassWeak;

    if (again) {
      if (_againCtl.text.isEmpty) {
        e['again'] = l.authAgainEmpty;
      } else if (_againCtl.text != _passCtl.text) {
        e['again'] = l.authAgainDiffers;
      }
    }

    if (code && _codeCtl.text.length < _codeLen) e['code'] = l.authCodeShort;

    setState(() {
      _bad
        ..clear()
        ..addAll(e);
    });
    return e.isEmpty;
  }

  // --- Вигляд -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);

    return switch (widget.page) {
      AuthPage.up => _page(l.authSignUpTitle, null, _upBody()),
      AuthPage.code => _page(l.authCodeTitle, l.authCodeHint(_mailCtl.text.trim()), _codeBody()),
      AuthPage.forgot => _page(l.authForgotTitle, l.authForgotHint, _forgotBody()),
      AuthPage.in_ => _page(
        widget.returning ? l.startSignInBackTitle : l.authSignInTitle,
        widget.returning ? l.startSignInBackText : null,
        _inBody(),
      ),
    };
  }

  Widget _page(String title, String? hint, List<Widget> body) => ListView(
    padding: const EdgeInsets.fromLTRB(CalviSize.gutter, 0, CalviSize.gutter, 16),
    children: [
      Text(
        title,
        style: context.t.displayLarge?.copyWith(
          fontSize: 34,
          letterSpacing: 34 * -0.03,
          height: 1.12,
        ),
      ),
      if (hint != null) ...[
        const SizedBox(height: 12),
        Text(
          hint,
          style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsBody, height: 1.5),
        ),
      ],
      const SizedBox(height: 24),
      ...body,
    ],
  );

  List<Widget> _inBody() {
    final l = L.of(context);
    final login = _login;

    return [
      // Nothing agreed to means nothing to press, and the row says so by going
      // pale rather than by turning grey.
      Opacity(
        opacity: _agree ? 1 : 0.4,
        child: IgnorePointer(
          ignoring: !_agree,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* Кнопка є тільки тоді, коли за нею щось стоїть. Порожній
                 ідентифікатор означає, що вхід не налаштований у цій збірці, і
                 кнопка, яка нічого не зробить, гірша за одну кнопку менше. */
              if (login?.available ?? false) ...[
                CalviButton(
                  label: _busyWith == 'google' ? l.startSignInBusy : l.startSignInGoogle,
                  enabled: !_busy,
                  onTap: () => unawaited(_provider('google')),
                ),
                const SizedBox(height: 10),
              ],
              if (login?.appleAvailable ?? false) ...[
                CalviGhost(
                  label: _busyWith == 'apple' ? l.startSignInBusy : l.startSignInApple,
                  enabled: !_busy,
                  onTap: () => unawaited(_provider('apple')),
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 12),
              _Or(l.authOr),
              const SizedBox(height: 18),

              _field(
                key: 'mail',
                label: l.authMail,
                controller: _mailCtl,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _field(
                key: 'pass',
                label: l.authPass,
                controller: _passCtl,
                secret: true,
                aside: GestureDetector(
                  onTap: () => widget.onPage(AuthPage.forgot),
                  child: Text(
                    l.authForgotLink,
                    style: context.t.bodyMedium?.copyWith(
                      fontSize: CalviSize.fsMicro,
                      color: context.c.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              CalviButton(
                label: _busyWith == 'mail' ? l.startSignInBusy : l.authSignInAction,
                enabled: !_busy,
                onTap: () => unawaited(_enterByMail()),
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 22),
      /* Просто «Зареєструватись», без питання перед ним: питання «Немає
         акаунту?» ставить людину перед вибором там, де вибір вона вже зробила,
         відкривши застосунок уперше. */
      Center(
        child: GestureDetector(
          onTap: _busy ? null : () => widget.onPage(AuthPage.up),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              l.authSignUpLink,
              style: context.t.bodyLarge?.copyWith(
                fontSize: CalviSize.fsCaption,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),

      /* «Далі без акаунту» більше не пропонується.
       *
       * Акаунти без входу нікуди не діваються: ті, що вже є на телефонах,
       * працюють далі, і сервер їх так само знає. Зникла тільки пропозиція
       * заводити новий такий акаунт. Причина проста: акаунт без пошти не можна
       * відновити. Телефон загубився, і разом із ним пішов щоденник, за який
       * людина платила увагою півроку, а ми навіть не можемо його повернути,
       * бо не знаємо, чий він.
       *
       * Рядок лишився рівно на один випадок: коли входу немає взагалі. Кнопки
       * провайдерів малюються тільки за налаштованим ідентифікатором, і в
       * збірці без нього на цьому екрані не лишалось би жодної дороги далі:
       * пошта вимагає сервера, провайдерів немає, а перший запуск нікуди не
       * пускає. Це не запасний вхід для людини, це запобіжник від застосунку,
       * який не заводиться. У магазинній збірці провайдери є, і цього рядка
       * там не буває. */
      if (login == null || !((login.available) || (login.appleAvailable))) ...[
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _busy ? null : widget.onNew,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l.startSignInSkip,
                style: context.t.bodyMedium?.copyWith(
                  fontSize: CalviSize.fsCaption,
                  color: context.c.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],

      const SizedBox(height: 18),
      _terms(),
    ];
  }

  /* Реєстрація. Три поля і кнопка, більше на сторінці немає нічого: чим менше
     на ній стоїть, тим коротший шлях від наміру завести акаунт до заведеного. */
  List<Widget> _upBody() {
    final l = L.of(context);

    return [
      Opacity(
        opacity: _agree ? 1 : 0.4,
        child: IgnorePointer(
          ignoring: !_agree,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                key: 'mail',
                label: l.authMail,
                controller: _mailCtl,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _field(
                key: 'pass',
                label: l.authPass,
                controller: _passCtl,
                secret: true,
                hint: l.authPassHint,
              ),
              const SizedBox(height: 16),
              _field(
                key: 'again',
                label: l.authAgain,
                controller: _againCtl,
                secret: true,
                hint: l.authAgainHint,
              ),
              const SizedBox(height: 22),
              CalviButton(
                label: _busyWith == 'mail' ? l.startSignInBusy : l.authSignUpAction,
                enabled: !_busy,
                onTap: () => unawaited(_register()),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      _terms(),
    ];
  }

  List<Widget> _codeBody() {
    final l = L.of(context);
    return [
      _cells(),
      const SizedBox(height: 22),
      CalviButton(
        label: _busyWith == 'code' ? l.startSignInBusy : l.authCodeAction,
        enabled: !_busy,
        onTap: () => unawaited(_confirm()),
      ),
      const SizedBox(height: 22),
      _againRow(),
    ];
  }

  /* Відновлення пароля двома кроками на одному екрані: спершу адреса, потім,
     коли лист уже пішов, код і новий пароль. Окремим екраном це були б два
     екрани, на другому з яких людина не бачить, куди саме прийшов лист. */
  List<Widget> _forgotBody() {
    final l = L.of(context);
    final sent = _left > 0 || _codeCtl.text.isNotEmpty;

    return [
      _field(
        key: 'mail',
        label: l.authMail,
        controller: _mailCtl,
        keyboard: TextInputType.emailAddress,
      ),
      const SizedBox(height: 22),
      if (!sent)
        CalviButton(
          label: _busyWith == 'mail' ? l.startSignInBusy : l.authForgotAction,
          enabled: !_busy,
          onTap: () => unawaited(_forgotSend()),
        )
      else ...[
        _cells(),
        const SizedBox(height: 16),
        _field(
          key: 'pass',
          label: l.authPassNew,
          controller: _passCtl,
          secret: true,
          hint: l.authPassHint,
        ),
        const SizedBox(height: 22),
        CalviButton(
          label: _busyWith == 'code' ? l.startSignInBusy : l.authResetAction,
          enabled: !_busy,
          onTap: () => unawaited(_confirm()),
        ),
        const SizedBox(height: 22),
        _againRow(),
      ],
    ];
  }

  Widget _againRow() {
    final l = L.of(context);
    return Center(
      child: _left > 0
          ? Text(
              l.authAgainIn(_left),
              style: context.t.bodyMedium?.copyWith(
                fontSize: CalviSize.fsCaption,
                color: context.c.faint,
              ),
            )
          : GestureDetector(
              onTap: () => unawaited(_again()),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  l.authSendAgain,
                  style: context.t.bodyLarge?.copyWith(
                    fontSize: CalviSize.fsCaption,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
    );
  }

  /* Шість квадратів, але поле одне.
   *
   * Квадрати кажуть, скільки цифр треба і скільки вже є: порожній ряд сам каже,
   * що робити. Робити з кожного квадрата окреме поле не можна, і це не смак:
   * код із листа копіюють цілком, і в шести полях він лягає в перше. Так само
   * ламається автопідстановка коду з повідомлення і стирання назад через пʼять
   * полів. Тому поле лишається одне, прозоре і на весь ряд, а квадрати під ним
   * лише малюють те, що в ньому лежить. */
  Widget _cells() {
    final c = context.c;
    final bad = _bad['code'];
    final code = _codeCtl.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Cap(L.of(context).authCode),
        const SizedBox(height: 9),
        Stack(
          children: [
            LayoutBuilder(
              builder: (context, box) {
                const gap = 8.0;
                final side = (box.maxWidth - gap * (_codeLen - 1)) / _codeLen;
                return Row(
                  children: [
                    for (var i = 0; i < _codeLen; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      AnimatedContainer(
                        duration: CalviMotion.fast,
                        curve: CalviMotion.ease,
                        width: side,
                        height: side,
                        alignment: Alignment.center,
                        /* Набрана цифра трохи підважує свій квадрат. Не
                           прикраса: ряд однакових квадратів інакше не показує
                           руху, і набір відчувається як друк у порожнечу. */
                        transform: Matrix4.translationValues(0, i < code.length ? -1 : 0, 0),
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rCard),
                          border: Border.all(
                            color: bad != null
                                ? c.protein
                                // Підсвічений квадрат замість курсора: поле
                                // розтягнуте на весь ряд, і власний курсор
                                // стояв би не там, куди дивиться людина.
                                : (i == code.length ? c.button : c.cardBorder),
                          ),
                        ),
                        child: Text(
                          i < code.length ? code[i] : '',
                          style: context.t.displayLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _codeCtl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_codeLen),
                  ],
                  onChanged: (_) => setState(() => _bad.remove('code')),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                ),
              ),
            ),
          ],
        ),
        if (bad != null) ...[const SizedBox(height: 8), _Bad(bad)],
      ],
    );
  }

  Widget _field({
    required String key,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
    bool secret = false,
    String? hint,
    Widget? aside,
  }) {
    final c = context.c;
    final bad = _bad[key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: _Cap(label)),
            if (aside != null) aside,
          ],
        ),
        const SizedBox(height: 9),
        Container(
          height: 54,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(14, 0, secret ? 4 : 14, 0),
          decoration: BoxDecoration(
            color: c.fillSecondary,
            borderRadius: BorderRadius.circular(CalviSize.rCard),
            border: Border.all(color: bad != null ? c.protein : c.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: secret && !_seen,
                  keyboardType: keyboard,
                  autocorrect: false,
                  enableSuggestions: !secret,
                  textCapitalization: TextCapitalization.none,
                  onChanged: (_) {
                    if (bad != null) setState(() => _bad.remove(key));
                  },
                  style: context.t.bodyLarge?.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: context.t.bodyLarge?.copyWith(fontSize: 15, color: c.faint),
                  ),
                ),
              ),
              /* Око на кожному полі пароля і одне на всі: коли паролі звіряють
                 між собою, показувати треба обидва, інакше звіряти нема з чим. */
              if (secret)
                GestureDetector(
                  onTap: () => setState(() => _seen = !_seen),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 50,
                    height: 52,
                    child: Center(
                      child: CalviIcon(
                        _seen ? 'eyeOff' : 'eye',
                        size: 19,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (bad != null) ...[const SizedBox(height: 8), _Bad(bad)],
      ],
    );
  }

  Widget _terms() {
    final c = context.c;
    final l = L.of(context);

    return GestureDetector(
      onTap: () => setState(() => _agree = !_agree),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _agree ? c.button : const Color(0x00000000),
              border: Border.all(color: _agree ? c.button : c.hairline, width: 1.5),
            ),
            child: _agree ? CalviIcon('check', size: 13, color: c.buttonText) : null,
          ),
          const SizedBox(width: 10),
          /* Документи відкриваються, а не просто називаються: згода на
             непрочитане це не згода. Аркушем, а не в браузері: людина йшла
             читати умови й поверталась у застосунок, який доводилось починати
             спочатку, а без мережі не поверталась узагалі. */
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l.startAgreeHead),
                  TextSpan(
                    text: l.startAgreeTerms,
                    style: TextStyle(color: c.text, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => legalSheet(context, terms),
                  ),
                  TextSpan(text: l.startAgreeAnd),
                  TextSpan(
                    text: l.startAgreePrivacy,
                    style: TextStyle(color: c.text, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => legalSheet(context, privacy),
                  ),
                ],
              ),
              style: context.t.bodyMedium?.copyWith(fontSize: CalviSize.fsMicro, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/* Підпис поля капсом і врозрядку, а не звичайним рядком. У формі, де полів два,
   підпис це не текст, а мітка: її не читають, її упізнають. */
class _Cap extends StatelessWidget {
  const _Cap(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.t.bodyMedium?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
      color: context.c.textSecondary,
    ),
  );
}

/* Помилка стоїть під своїм полем і тим самим кольором, що «проти цілі» в
   аналітиці. Список помилок угорі форми змушує шукати, до чого він. */
class _Bad extends StatelessWidget {
  const _Bad(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.t.bodyMedium?.copyWith(
      fontSize: CalviSize.fsMicro,
      color: context.c.protein,
    ),
  );
}

/* Розділювач зі словом посередині. Він не прикраса: без нього два способи входу
   читаються як одна купа кнопок і полів. */
class _Or extends StatelessWidget {
  const _Or(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: c.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text.toUpperCase(),
            style: context.t.bodyMedium?.copyWith(
              fontSize: 11,
              letterSpacing: 2.4,
              color: c.faint,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: c.hairline)),
      ],
    );
  }
}
