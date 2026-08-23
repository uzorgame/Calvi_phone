import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/allergens.dart';
import '../../data/app_scope.dart';
import '../../data/remote/api.dart';
import '../../design/icons.dart';
import '../../design/shell.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import 'live_feed.dart';
import 'sight.dart';

enum CamMode { food, barcode }

/// Що людина вирішила надіслати з камери.
sealed class CamShot {
  const CamShot();
}

/// Кадр страви. Їде повідомленням у чат до Нори, і відповідь приходить туди.
class PhotoShot extends CamShot {
  const PhotoShot(this.shot);

  final Shot shot;
}

/// Прочитаний штрихкод і те, що знайшлось у довіднику. Не коштує нічого: код
/// читає сам телефон, а числа беруться з нашої бази.
class CodeShot extends CamShot {
  const CodeShot({required this.code, required this.food});

  final String code;
  final FoodHit food;
}

/// Код, якого не знає жодна база. Їде в чат розмовою, а не записом: Нора
/// розпитує про продукт, і нічого не лягає в день без слова людини.
class CodeTalk extends CamShot {
  const CodeTalk(this.code);

  final String code;
}

class _ModeInfo {
  const _ModeInfo({required this.id, required this.icon, required this.title});

  final CamMode id;
  final String icon;
  final String title;
}

/* Two modes, two different jobs for the same lens. Food goes to the model and
   comes back as an estimate; a barcode is read on the device, hits the product
   base and costs nothing. */
List<_ModeInfo> _modes(L l) => [
  _ModeInfo(id: CamMode.food, icon: 'utensils', title: l.camDish),
  _ModeInfo(id: CamMode.barcode, icon: 'barcode', title: l.camBarcode),
];

/// The one product the demo base knows.
const demoBarcode = '4820001234567';

/* The viewfinder is its own world and does not take the app's palette: a
   viewfinder that goes light in the light theme stops being a viewfinder. */
const _ink = Color(0xFFFFFFFF);
const _chrome = Color(0x6B141418);
const _chromeRound = Color(0x73141418);
const _dark = Color(0xFF101014);

/// Viewfinder, full screen.
///
/// Everything is chrome over the picture: the frame is the interface, and the
/// controls float on it rather than sit in a bar that eats the shot. The corner
/// brackets are not decoration, they say where to aim, and in barcode mode they
/// close in on a line, because a barcode needs a strip and a plate needs a
/// square.
///
/// The photo is not kept. It goes up, comes back as numbers, and is gone: an app
/// that quietly builds a gallery of what someone ate is a different app.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.slot, required this.onSend});

  /// Card the shot will be written into, so the shutter can say where it goes.
  final String slot;

  /// The shot leaves as a message. The viewfinder closes behind it and the chat
  /// opens with it already sent, because that is where the answer will arrive.
  final ValueChanged<CamShot> onSend;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CamMode _mode = CamMode.food;
  bool _busy = false;
  bool _done = false;
  bool _flash = false;

  /// The live camera, once it answers. Null on the web, on a refusal, and on a
  /// phone that has none: everything on this screen still works without it.
  CameraController? _cam;

  /* A Timer and not a delayed future: it has to be cancellable. A shutter fired
     on the way out would otherwise open a sheet on a screen that is gone. */
  Timer? _read;

  /* Останній кадр, у памʼяті і тільки до відправлення. На диск він не лягає:
     застосунок, який тихо збирає галерею того, що людина їла, це інший
     застосунок. */
  Shot? _shot;

  /* Чому кадр не відбувся, коли не відбувся. Живе тільки до закриття екрана. */
  String? _trouble;

  /* Прочитаний код і те, що по ньому знайшлось. Читає сам телефон, шукає наш
     сервер, і жодного токена це не коштує. */
  String? _code;
  FoodHit? _food;
  bool _unknown = false;

  /* Чи вже вільна лінза для того читача, який зараз на екрані.
   *
   * Камера на телефоні одна, а читачів у нас два: звичайний видошукач для
   * страви і сканер для штрихкоду. Відпускається вона не миттєво, тому після
   * кожного перемикання режиму живий шар зникає на чверть секунди, і аж потім
   * зʼявляється новий. Перший показ цього не потребує: до нього камеру ніхто не
   * тримав. */
  bool _lensFree = true;
  Timer? _handoff;

  /* --- Прицілювання ---
   *
   * Читання не приймається з першого разу. Кадр за кадром збираються голоси, і
   * перемагає той код, який бачили найчастіше: помилки читання випадкові й
   * різні, а правильне читання одне й те саме. Саме через це раніше довідник
   * казав «не знаю такого», а з другої спроби той самий продукт знаходився. */
  final _votes = <String, int>{};

  /// Де саме на екрані код, за який зараз тримається рамка.
  Rect? _lock;

  /* Рамка вже відпустила код і стоїть посеред екрана.
   *
   * Сама вона до нього не повернеться: відповідь уже є, і рамка, яка знову
   * стрибає на код, поки на екрані картка з числами, каже, що застосунок читає
   * далі, хоча він чекає рішення людини. Знімається це «Ще раз». */
  bool _parked = false;

  /// Розмір видошукача, як його останній раз намалювали.
  Size _view = Size.zero;

  /// Кінець звірки і втрата коду з кадру.
  Timer? _verdict;
  Timer? _lost;

  /// Своя камера в сканера: одну не можна віддати двом читачам одночасно.
  final _scanner = MobileScannerController(
    /* Не `noDuplicates`. Той віддає код рівно один раз, а нам потрібні саме
       повтори: із них і збирається впевненість. */
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 0,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      // QR теж читається: на них живуть етикетки, меню і посилання на склад.
      BarcodeFormat.qrCode,
    ],
  );

  @override
  void dispose() {
    _read?.cancel();
    _handoff?.cancel();
    _verdict?.cancel();
    _lost?.cancel();
    unawaited(_scanner.dispose());
    super.dispose();
  }

  /// Кадр із кодом. Не відповідь, а один голос за неї.
  void _onCode(BarcodeCapture capture) {
    if (!mounted || _parked) return;

    /* Відповідь уже є, але код ще в кадрі: рамка й далі за ним іде, а голоси
       більше не збираються. Так видно, що застосунок дивиться саме на той код,
       про який щойно розповів, і телефон можна повернути, не втративши нитки. */
    final tracking = _busy || _done;

    /* Найбільший із побачених. Вікно читання вже відсікло все, що поза рамкою,
       а якщо в неї потрапило двоє, людина цілилась у того, що ближче. */
    Barcode? best;
    Rect? bestRect;
    for (final b in capture.barcodes) {
      final value = b.rawValue?.trim();
      if (value == null || value.length < 6) continue;

      final rect = codeRect(b, capture.size, _view);
      if (best == null || (rect != null && (bestRect?.longestSide ?? 0) < rect.longestSide)) {
        best = b;
        bestRect = rect ?? bestRect;
      }
    }

    final value = best?.rawValue?.trim();
    if (value == null) return;

    if (!tracking) _votes[value] = (_votes[value] ?? 0) + 1;
    final first = !tracking && _votes[value] == 1;

    /* Рамка переїжджає, тільки коли код справді зрушив.
     *
     * Кадри йдуть по двадцять на секунду, і кути в кожному трохи інші, навіть
     * коли телефон лежить на столі. Перемальовувати екран під це тремтіння
     * означало б гріти телефон заради руху, якого око не бачить. */
    final want = bestRect == null ? null : frameFor(bestRect, _view);
    if (want != null && _moved(want)) setState(() => _lock = want);

    // Перше око: коротка віддача в руку і початок звірки.
    if (first) {
      HapticFeedback.selectionClick();
      _verdict?.cancel();
      _verdict = Timer(dwell, _settle);
    }

    // Код у кадрі. Лічильник втрати починається заново.
    _lost?.cancel();
    _lost = Timer(lostAfter, _release);

    if (tracking) return;

    // Досить однакових читань, щоб не тримати людину всю півтори секунди.
    if ((_votes[value] ?? 0) >= sureHits) _settle();
  }

  /// Чи варто переставляти рамку заради цієї нової позиції.
  bool _moved(Rect want) {
    final was = _lock;
    if (was == null) return true;
    return (want.center - was.center).distance > 5 || (want.width - was.width).abs() > 7;
  }

  /// Код пішов із кадру. Рамка вертається на місце і забуває почуте.
  void _release() {
    _verdict?.cancel();
    _verdict = null;
    _lost?.cancel();
    _lost = null;
    _votes.clear();

    // Код відвели від камери вже після відповіді. Рамка вертається на середину і
    // там лишається: далі слово за людиною, а не за наступним кодом у кадрі.
    if (_busy || _done) _parked = true;

    if (mounted) setState(() => _lock = null);
  }

  /// Звірка закінчилась. Далі це вже питання до довідника, а не до камери.
  Future<void> _settle() async {
    _verdict?.cancel();
    _verdict = null;

    final code = verdictOf(_votes);
    _votes.clear();
    if (code == null || _busy || _done || !mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _busy = true;
      _code = code;
      _food = null;
      _unknown = false;
    });

    /* Камеру тут навмисно не зупиняємо. Зупинена вона лишає під карткою
       завмерлий кадр, а зупинити й запустити наново означало б ще одну передачу
       лінзи на порожньому місці. Другого разу той самий код не наробить біди:
       `_busy` і `_done` не пускають далі. */

    final sync = AppScope.of(context).sync;
    final found = sync == null ? null : await sync.foods.byBarcode(code);

    if (!mounted) return;
    setState(() {
      _food = found;
      _unknown = found == null;
      _busy = false;
      _done = true;
    });
  }

  /// Перемикає режим і передає камеру від одного читача до іншого.
  ///
  /// Саме передає, по черзі, а не вмикає обидва: лінза одна, і два читачі на ній
  /// не уживаються. Тут ховався сірий екран сканера. Новий читач народжувався
  /// тієї ж миті, коли попередній ще тримав пристрій; камера не відкривалась, а
  /// віджет у такому стані малює просто чорний прямокутник, нічого не кажучи.
  ///
  /// Тому спершу живий шар зникає з дерева зовсім, і тільки за чверть секунди,
  /// коли попередній справді закрився, зʼявляється новий.
  void _setMode(CamMode m) {
    if (m == _mode) return;

    setState(() {
      _mode = m;
      _done = false;
      _code = null;
      _food = null;
      _unknown = false;
      _lensFree = false;
      _parked = false;
      _lock = null;
    });

    _handoff?.cancel();
    _handoff = Timer(const Duration(milliseconds: 260), () {
      if (mounted) setState(() => _lensFree = true);
    });
  }

  /// Назад до читання, коли людина хоче спробувати ще раз.
  void _again() {
    _votes.clear();
    setState(() {
      _done = false;
      _code = null;
      _food = null;
      _unknown = false;
      _trouble = null;
      // Аж тепер рамка знову вільна шукати.
      _parked = false;
      _lock = null;
    });
  }

  /* The torch belongs to the camera, so a screen without one simply does not
     offer it rather than pretending the switch did something. */
  Future<void> _torch() async {
    final cam = _cam;
    if (cam == null) return;
    final next = !_flash;
    try {
      await cam.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flash = next);
    } catch (_) {
      /* Some cameras have no lamp. Saying so by not moving is honest. */
    }
  }

  /// Віддає нагору те, що справді є: продукт зі штрихкоду, розмову про
  /// незнайомий код або сам кадр.
  void _send() {
    final food = _food;
    final code = _code;
    if (food != null && code != null) {
      widget.onSend(CodeShot(code: code, food: food));
      return;
    }

    // Код прочитався, але його не знає жодна база: не запис, а розмова.
    if (code != null && _unknown) {
      widget.onSend(CodeTalk(code));
      return;
    }

    final shot = _shot;
    if (shot != null) widget.onSend(PhotoShot(shot));
  }

  /// Знімає кадр і лишає його в памʼяті до відправлення.
  Future<void> _capture() async {
    final cam = _cam;
    if (cam == null) return;
    try {
      final file = await cam.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _shot = Shot(mime: 'image/jpeg', bytes: bytes);
    } catch (_) {
      /* Камера могла зникнути разом з екраном. Тоді відправляти нічого, і
         картка розбору просто скаже, що не вийшло. */
      _shot = null;
    }
  }

  /// A picture that already exists is the same message as one taken now.
  Future<void> _fromGallery() async {
    if (_busy) return;
    final shot = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (shot == null || !mounted) return;
    _shot = Shot(mime: 'image/jpeg', bytes: await shot.readAsBytes());
    _leave();
  }

  /* Затвор надсилає, а не розбирає.
   *
   * Знімок їде повідомленням до Нори, видошукач закривається за ним, і чат
   * відкривається з уже надісланим фото: відповідь прийде саме туди. Розбір на
   * самому екрані сканера тут був і його прибрано: він тримав людину з
   * піднятим телефоном ті десять секунд, поки модель думає, а чат уміє чекати
   * сам. */
  void _shoot() {
    if (_busy) return;
    HapticFeedback.mediumImpact();
    unawaited(() async {
      setState(() => _busy = true);
      await _capture();
      _leave();
    }());
  }

  /// Кадр є, і він їде в чат. Кадру немає, і картка чесно каже, що не вийшло.
  void _leave() {
    if (!mounted) return;

    final shot = _shot;
    if (shot != null) {
      _send();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _trouble = L.of(context).camShotFailed;
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final slim = _mode == CamMode.barcode;

    return Scaffold(
      backgroundColor: _dark,
      body: LayoutBuilder(
        builder: (context, box) {
          /* Один розмір на весь екран, і всі троє рахуються від нього: вікно
             читання, рамка і перерахунок кутів коду з кадру камери. Раніше
             рамку розкладав окремий LayoutBuilder, і сканер про неї не знав
             узагалі. */
          _view = Size(box.maxWidth, box.maxHeight);
          final window = readingWindow(_view);
          final frame = _lock ?? (slim ? window : _plateFrame(_view));

          return _stage(slim: slim, window: window, frame: frame);
        },
      ),
    );
  }

  /// Куди дивитись, коли знімають страву: ширше і трохи нижче, як лежить тарілка.
  Rect _plateFrame(Size view) =>
      Rect.fromLTRB(view.width * 0.12, view.height * 0.26, view.width * 0.88, view.height * 0.66);

  Widget _stage({required bool slim, required Rect window, required Rect frame}) {
    final l = L.of(context);
    return Stack(
      children: [
        /* Одна лінза, два читачі, і вони не уживаються разом: у режимі
             штрихкоду камеру тримає сканер, у режимі страви звичайний
             видошукач. Поки лінза переходить з рук у руки, тут немає жодного з
             них: див. `_setMode`. */
        Positioned.fill(
          child: RepaintBoundary(
            child: !_lensFree
                ? const _Handing()
                : slim
                ? MobileScanner(
                    controller: _scanner,
                    onDetect: _onCode,
                    /* Читається рівно те, на що наведено. Без цього рядка
                         сканер бачить увесь кадр і ловить сусідню пляшку, поки
                         телефон ще їде до потрібної: махнув рукою, і в
                         застосунку вже чужий продукт. */
                    scanWindow: window,
                    // Чорний прямокутник мовчки це найгірша з відповідей:
                    // людина не знає, чи камера зайнята, чи дозволу немає, чи
                    // застосунок просто завис.
                    placeholderBuilder: (context) => const _Handing(),
                    errorBuilder: (context, error) =>
                        _Trouble(text: _scanReason(L.of(context), error)),
                    fit: BoxFit.cover,
                  )
                : LiveFeed(
                    fallback: const _Feed(),
                    onReady: (cam) {
                      if (!mounted) return;
                      setState(() {
                        _cam = cam;
                        if (cam == null) _flash = false;
                      });
                    },
                  ),
          ),
        ),

        /* Рамка стоїть проти екрана, а не по центру того, що лишила хрома: їй
             треба бути там, де лежить тарілка, коли телефон тримають над
             столом.
           *
           * А коли код знайдено, вона з того місця зʼїжджає і сідає на нього.
             Це не прикраса: людина має бачити, що застосунок дивиться саме на
             той код, який вона показує, а не на сусідній. */
        Positioned.fill(
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: CalviMotion.easeRise,
                left: frame.left,
                top: frame.top,
                width: frame.width,
                height: frame.height,
                child: _Frame(slim: slim, holding: _lock != null && !_done && !_busy),
              ),
            ],
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _Round(
                      icon: 'chevron',
                      label: l.actionBack,
                      turn: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        l.camTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _ink,
                          fontSize: CalviSize.fsBody,
                          fontWeight: FontWeight.w600,
                          letterSpacing: CalviSize.fsBody * -0.02,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ),
                    /* Nothing lives behind a menu here. The screen has two
                         modes, a shutter and a flash, and a button that opens
                         nothing teaches people to stop pressing buttons. */
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Spacer(),
              /* Only while it is reading. Where to point is what the frame is
                   for, and a line repeating it under every shot is a line people
                   stop seeing on the second day. */
              if (_busy)
                Text(
                  l.camReading,
                  style: TextStyle(
                    color: _ink.withValues(alpha: 0.78),
                    fontSize: CalviSize.fsMicro,
                    shadows: const [
                      Shadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              _Deck(
                mode: _mode,
                flash: _flash,
                busy: _busy,
                slot: widget.slot,
                onMode: _setMode,
                onFlash: _torch,
                onGallery: _fromGallery,
                onShoot: _shoot,
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),

        if (_done)
          TweenAnimationBuilder<double>(
            // 16.37: it arrives from below rather than appearing in place. The
            // travel is short and the fade is late, so the sheet reads as
            // rising into place rather than being thrown at the screen.
            key: ValueKey(_mode),
            tween: Tween(end: 1),
            duration: const Duration(milliseconds: 420),
            curve: CalviMotion.easeRise,
            builder: (context, t, child) => Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: Curves.easeOut.transform(t.clamp(0, 1)),
                child: Transform.translate(offset: Offset(0, 64 * (1 - t)), child: child),
              ),
            ),
            child: _Result(
              mode: _mode,
              slot: widget.slot,
              code: _code,
              food: _food,
              trouble: _trouble,
              unknown: _unknown,
              onAgain: _again,
              onSend: _send,
            ),
          ),
      ],
    );
  }
}

/// Людською мовою про те, чому камера не відкрилась.
///
/// Коди бібліотеки написані для того, хто читає її вихідний код, а на екрані
/// стоїть людина з телефоном у руці. Різниця між «немає дозволу» і «камера
/// зайнята» для неї величезна: у першому випадку треба йти в налаштування, у
/// другому закрити інший застосунок.
String _scanReason(L l, MobileScannerException e) => switch (e.errorCode) {
  MobileScannerErrorCode.permissionDenied => l.camNoPermission,
  MobileScannerErrorCode.unsupported => l.camNoScanner,
  _ => l.camBusy,
};

/// Пусті чверть секунди, поки камера переходить від одного читача до іншого.
///
/// Малює те саме, що й видошукач без камери, тільки без брязкальця: людина не
/// має помічати цю мить узагалі, і різкий чорний прямокутник посеред неї
/// помітили б відразу.
class _Handing extends StatelessWidget {
  const _Handing();

  @override
  Widget build(BuildContext context) => const ColoredBox(color: _dark);
}

/// Причина замість картинки, коли картинки не буде.
class _Trouble extends StatelessWidget {
  const _Trouble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _dark,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalviIcon('barcode', size: 26, color: _ink.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink.withValues(alpha: 0.8),
                fontSize: CalviSize.fsMicro,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              L.of(context).camStillWorks,
              textAlign: TextAlign.center,
              style: TextStyle(color: _ink.withValues(alpha: 0.5), fontSize: CalviSize.fsMicro),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Stand-in for the live feed: a table out of focus.
///
/// A flat rectangle would not show whether the chrome above it is readable,
/// which is the only thing this screen is here to prove. The plate is cool and
/// what is on it is warm, because that is how a table reads through a lens.
class _Feed extends StatelessWidget {
  const _Feed();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.2),
                    radius: 1.1,
                    colors: [Color(0xFF4A3526), Color(0xFF2A1D15), Color(0xFF15100C)],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
            ),

            _Blur(
              left: -w * 0.06,
              top: h * 0.04,
              w: w * 0.56,
              h: h * 0.26,
              colour: const Color(0xFF7A5C40),
              alpha: 0.4,
            ),
            _Blur(
              left: w * 0.62,
              top: 0,
              w: w * 0.42,
              h: h * 0.30,
              colour: const Color(0xFF3F4F46),
              alpha: 0.45,
            ),
            _Blur(
              left: w * 0.04,
              top: h * 0.76,
              w: w * 0.92,
              h: h * 0.30,
              colour: const Color(0xFF16100B),
              alpha: 0.75,
            ),

            // The plate.
            _Blur(
              left: w * 0.13,
              top: h * 0.39,
              w: w * 0.74,
              h: h * 0.26,
              blur: 18,
              alpha: 0.55,
              gradient: const RadialGradient(
                colors: [Color(0xFFB9D2CC), Color(0xFF86A8A1), Color(0xFF55726C)],
                stops: [0, 0.68, 1],
              ),
            ),
            // What is on it.
            _Blur(
              left: w * 0.27,
              top: h * 0.385,
              w: w * 0.46,
              h: h * 0.17,
              blur: 14,
              alpha: 0.7,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD3A870), Color(0xFFB8834A), Color(0x33946630)],
                stops: [0, 0.6, 1],
              ),
            ),

            // The vignette, so the chrome always has something to sit on.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.04),
                    radius: 0.9,
                    colors: [Color(0x00000000), Color(0x8C000000)],
                    stops: [0.3, 1],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blur extends StatelessWidget {
  const _Blur({
    required this.left,
    required this.top,
    required this.w,
    required this.h,
    required this.alpha,
    this.colour,
    this.gradient,
    this.blur = 34,
  });

  final double left;
  final double top;
  final double w;
  final double h;
  final double alpha;
  final Color? colour;
  final Gradient? gradient;
  final double blur;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    top: top,
    width: w,
    height: h,
    child: ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Opacity(
        opacity: alpha,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.elliptical(w / 2, h / 2)),
            color: colour,
            gradient: gradient,
          ),
        ),
      ),
    ),
  );
}

/// Corner brackets, and a beam when a barcode is what is wanted.
class _Frame extends StatefulWidget {
  const _Frame({required this.slim, this.holding = false});

  final bool slim;

  /// True, поки рамка тримається за знайдений код і йде звірка.
  ///
  /// Тоді промінь гасне, а кути стискаються: промінь означає «шукаю», і водити
  /// ним по коду, який уже знайдено, це казати неправду про свою роботу.
  final bool holding;

  @override
  State<_Frame> createState() => _FrameState();
}

class _FrameState extends State<_Frame> with TickerProviderStateMixin {
  /// 16.35: the reading line runs a 1.8 second cycle.
  late final AnimationController _beam = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  /// 16.33: the frame arrives once, over 620 ms, from a little too large.
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void dispose() {
    _beam.dispose();
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _in,
      builder: (context, child) {
        final t = CalviMotion.easeRise.transform(_in.value);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 1.06 - 0.06 * t, child: child),
        );
      },
      child: Stack(
        children: [
          for (final a in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: a,
              child: AnimatedScale(
                scale: widget.holding ? 1.18 : 1,
                duration: const Duration(milliseconds: 260),
                curve: CalviMotion.easeRise,
                child: _Corner(align: a),
              ),
            ),

          // Смуга звірки: тонке кільце, яке набігає, поки код перечитують.
          if (widget.holding)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: 1),
                duration: dwell,
                curve: Curves.linear,
                builder: (context, t, _) => CustomPaint(painter: _Dwell(t: t)),
              ),
            ),

          if (widget.slim && !widget.holding)
            Positioned(
              left: 6,
              right: 6,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _beam,
                builder: (context, _) {
                  final k = Curves.easeInOut.transform(_beam.value);
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, -16 + 32 * k),
                      child: Opacity(
                        opacity: 0.35 + 0.65 * k,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [Color(0x00FFFFFF), _ink, Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// One bracket of the frame.
///
/// Painted rather than built from a Border: a BoxDecoration with different sides
/// and a corner radius is not something Flutter draws, and it came out as a
/// closed rectangle instead of an L.
class _Corner extends StatelessWidget {
  const _Corner({required this.align});

  final Alignment align;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 30,
    height: 30,
    child: CustomPaint(painter: _CornerPainter(align: align)),
  );
}

/// Скільки лишилось до кінця звірки.
///
/// Кільце по краю рамки, яке набігає за ті самі півтори секунди. Людині видно,
/// що застосунок не завис, а рахує, і скільки ще тримати телефон нерухомо.
class _Dwell extends CustomPainter {
  const _Dwell({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;

    final rect = (Offset.zero & size).deflate(3);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)));

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        // Від верхньої середини за годинниковою: так читається будь-який
        // лічильник, і в застосунку вже так набігає кільце дня.
        metric.extractPath(0, metric.length * t.clamp(0, 1)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = _ink.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_Dwell old) => old.t != t;
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.align});

  final Alignment align;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0;
    final top = align.y < 0;
    final left = align.x < 0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xEBFFFFFF);

    /* Two arms and the arc that joins them, drawn from the outside corner in:
       the bracket is one continuous stroke, so the join never shows a seam. */
    final cx = left ? r : size.width - r;
    final cy = top ? r : size.height - r;
    final path = Path()
      ..moveTo(left ? 0 : size.width, top ? size.height : 0)
      ..lineTo(left ? 0 : size.width, cy)
      ..arcToPoint(
        Offset(cx, top ? 0 : size.height),
        radius: const Radius.circular(r),
        clockwise: left == top,
      )
      ..lineTo(left ? size.width : 0, top ? 0 : size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.align != align;
}

class _Deck extends StatelessWidget {
  const _Deck({
    required this.mode,
    required this.flash,
    required this.busy,
    required this.slot,
    required this.onMode,
    required this.onFlash,
    required this.onShoot,
    required this.onGallery,
  });

  final CamMode mode;
  final bool flash;
  final bool busy;
  final String slot;
  final ValueChanged<CamMode> onMode;
  final VoidCallback onFlash;
  final VoidCallback onShoot;

  /// A picture that already exists, chosen instead of taken.
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          /* The modes sit in one smoked strip. The current one is the only one
             that gets a name; the rest are marks, which is what makes the row
             readable at a glance instead of three equal labels. */
          ClipRRect(
            borderRadius: BorderRadius.circular(CalviSize.rPill),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(6),
                color: _chrome,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final m in _modes(l))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: m.id == mode
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _ink,
                                  borderRadius: BorderRadius.circular(CalviSize.rPill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CalviIcon(m.icon, size: 15, color: _dark),
                                    const SizedBox(width: 7),
                                    Text(
                                      m.title,
                                      style: const TextStyle(
                                        color: _dark,
                                        fontSize: CalviSize.fsMicro,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _Mode(icon: m.icon, label: m.title, onTap: () => onMode(m.id)),
                      ),
                    _Mode(icon: 'image', label: l.camGallery, onTap: onGallery),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _Flash(on: flash, onTap: onFlash),
                ),
              ),
              /* Затвора в штрихкоді немає навмисно.
               *
               * Код читається сам, щойно потрапив у рамку, і кнопка «зняти»
               * тут обіцяла дію, якої не існує: знімок у цьому режимі нікуди
               * не йде. Людина тисла її і не розуміла, чому нічого не
               * відбувається, бо на той момент сканер уже або прочитав код,
               * або ще шукає його.
               *
               * Місце кнопки лишається порожнім: без нього спалах і підпис
               * картки роз'їхались би до країв, і нижній ряд стрибав би
               * щоразу, коли міняють режим. */
              if (mode == CamMode.barcode)
                const SizedBox(width: 68, height: 68)
              else
                _Shutter(busy: busy, onTap: onShoot),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: _chrome,
                        child: Text(
                          l.camIntoSlot(slot),
                          style: TextStyle(color: _ink, fontSize: CalviSize.fsMicro),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One mode that is not the current one: a mark, no background of its own.
class _Mode extends StatefulWidget {
  const _Mode({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_Mode> createState() => _ModeState();
}

class _ModeState extends State<_Mode> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: AnimatedContainer(
            duration: CalviMotion.fast,
            curve: CalviMotion.ease,
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _down ? _ink.withValues(alpha: 0.12) : const Color(0x00000000),
            ),
            child: CalviIcon(widget.icon, size: 19, color: _ink.withValues(alpha: 0.86)),
          ),
        ),
      ),
    );
  }
}

class _Flash extends StatefulWidget {
  const _Flash({required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  State<_Flash> createState() => _FlashState();
}

class _FlashState extends State<_Flash> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: L.of(context).camFlash,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                color: widget.on ? _ink : _chrome,
                child: CalviIcon('bolt', size: 18, color: widget.on ? _dark : _ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shutter extends StatefulWidget {
  const _Shutter({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  State<_Shutter> createState() => _ShutterState();
}

class _ShutterState extends State<_Shutter> with SingleTickerProviderStateMixin {
  /* 16.36: a 900 ms cycle while the frame is being read. The control that
     started the wait is the one that shows it, so there is no spinner. */
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _down = false;

  @override
  void didUpdateWidget(_Shutter old) {
    super.didUpdateWidget(old);
    if (widget.busy && !old.busy) {
      _pulse.repeat(reverse: true);
    } else if (!widget.busy && old.busy) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: L.of(context).camShoot,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _ink.withValues(alpha: 0.9), width: 3),
          ),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final beat = Curves.easeInOut.transform(_pulse.value);
              final scale = widget.busy ? 1 - 0.2 * beat : (_down ? 0.86 : 1.0);
              return Opacity(
                opacity: widget.busy ? 1 - 0.4 * beat : 1.0,
                child: AnimatedScale(
                  scale: scale,
                  duration: widget.busy ? Duration.zero : CalviMotion.fast,
                  curve: CalviMotion.ease,
                  child: const SizedBox(
                    width: 54,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _ink),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Round extends StatefulWidget {
  const _Round({required this.icon, required this.label, required this.onTap, this.turn = false});

  final String icon;
  final String label;
  final VoidCallback? onTap;

  /// The back arrow is the chevron turned around.
  final bool turn;

  @override
  State<_Round> createState() => _RoundState();
}

class _RoundState extends State<_Round> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final mark = CalviIcon(widget.icon, size: 18, color: _ink);
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: CalviMotion.fast,
          curve: CalviMotion.ease,
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                color: _chromeRound,
                child: widget.turn ? Transform.rotate(angle: 3.14159, child: mark) : mark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Попередження про алергени, які людина сама позначила в застосунку.
///
/// «Містить» і «може містити сліди» окремими рядками, бо на упаковці це дві
/// різні обіцянки. Важка алергія фарбує рядок у попереджувальний колір теми.
class _AllergyWarning extends StatelessWidget {
  const _AllergyWarning({required this.item});

  final FoodHit item;

  String _names(BuildContext context, List<String> ids) =>
      ids.map((id) => allergenById(id)?.name ?? id).join(', ').toLowerCase();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    /* Червоним завжди, і той самий червоний, яким день каже про перебір:
       алергія це не новий колір, а та сама мова тривоги. */
    final colour = c.protein;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(CalviSize.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.camAllergen,
            style: context.t.titleMedium?.copyWith(
              fontSize: 16,
              color: colour,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (item.warnContains.isNotEmpty)
            Text(
              l.camAllergyContains(_names(context, item.warnContains)),
              style: context.t.bodyMedium?.copyWith(color: colour, fontWeight: FontWeight.w600),
            ),
          if (item.warnTraces.isNotEmpty)
            Text(
              l.camAllergyTraces(_names(context, item.warnTraces)),
              style: context.t.bodyMedium?.copyWith(color: colour),
            ),
        ],
      ),
    );
  }
}

/* What comes back differs by mode, and pretending otherwise would hide the one
   thing worth showing: a barcode hit costs nothing and is exact, a photo is an
   estimate and says so. */
class _Result extends StatelessWidget {
  const _Result({
    required this.mode,
    required this.slot,
    required this.onAgain,
    required this.onSend,
    this.code,
    this.food,
    this.trouble,
    this.unknown = false,
  });

  final CamMode mode;
  final String slot;
  final VoidCallback onAgain;
  final VoidCallback onSend;

  /// Прочитаний код і те, що по ньому знайшлось у довіднику.
  final String? code;
  final FoodHit? food;

  /// Чому кадр не відбувся, коли не відбувся.
  final String? trouble;

  /// Код прочитано, але такого продукту не знає ні наша база, ні відкрита.
  final bool unknown;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = L.of(context);
    final found = mode == CamMode.barcode;
    final item = food;
    // Числа за звичну порцію, а за її відсутності за сто грамів.
    final plate = item?.forGrams();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        decoration: BoxDecoration(
          color: c.card,
          // Only the top corners: the bottom two are off the screen, and rounding
          // them leaves two dark notches under the sheet.
          borderRadius: const BorderRadius.vertical(top: Radius.circular(CalviSize.rLarge)),
          boxShadow: [BoxShadow(color: c.shade, blurRadius: 30, offset: const Offset(0, -12))],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.hairline,
                    borderRadius: BorderRadius.circular(CalviSize.rPill),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              /* Три різні відповіді, і жодна з них не вигадана.
               *
               * Продукт зі штрихкодом це точні числа з упаковки. Незнайомий код
               * це чесне «не знаю», а не підставлений схожий товар. А коли кадр
               * не вийшов, тут стоїть причина, а не мовчання. Числа за знімком
               * страви сюди не приходять узагалі: знімок їде в чат, і відповідь
               * Нори приходить туди. */
              /* Алерген стоїть найпершим, вище коду й назви.
               *
               * Людина зі списком алергій сканує упаковку саме заради цього
               * рядка, і він не має чекати, поки око пройде числа. Звірив
               * сервер: перетин складу з алергіями саме цієї людини. */
              if (item != null && (item.warnContains.isNotEmpty || item.warnTraces.isNotEmpty)) ...[
                _AllergyWarning(item: item),
                const SizedBox(height: 12),
              ],

              if (found && code != null) ...[
                Text(code!, style: context.t.labelSmall?.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
              ],

              if (item != null && plate != null) ...[
                Text(item.name, style: context.t.titleMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: '${plate.kcal}',
                    children: [
                      TextSpan(
                        text: l.camKcalPer(plate.grams.round()),
                        style: context.t.labelSmall?.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  style: context.t.headlineMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    /* Кожній клітинці її колір, той самий, що в кілець дня:
                       око вже вивчило цю мову на головному екрані. */
                    for (final chip in [
                      (l.macroPShort(plate.protein.round()), c.protein),
                      (l.macroFShort(plate.fat.round()), c.fats),
                      (l.macroCShort(plate.carbs.round()), c.carbs),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: chip.$2.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(CalviSize.rPill),
                          ),
                          child: Text(
                            chip.$1,
                            style: context.t.labelSmall?.copyWith(
                              fontSize: 12,
                              color: chip.$2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                /* Чесність про грамовку. Коли виробник назвав порцію, числа
                   стоять за неї, і це сказано прямо. Коли ні, числа за сто
                   грамів, і це теж сказано прямо, бо «367 ккал» без ваги
                   виглядає як ціна всієї пачки, хоча нею не є. */
                Text(
                  item.portionG != null ? l.camPortionPack(item.portionG!.round()) : l.camPer100,
                  style: context.t.bodyMedium,
                ),
                Text(l.camFromPack, style: context.t.bodyMedium),
                /* Склад, дослівно з упаковки. Його читає людина, яка вирішує,
                   чи їй це можна, тому він тут, а не за зайвим дотиком. Довгий
                   обрізається: картка лишається карткою, а не договором. */
                if (item.ingredients != null && item.ingredients!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.camIngredients(item.ingredients!),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.labelSmall?.copyWith(fontSize: 12, height: 1.4),
                  ),
                ],
              ] else if (unknown) ...[
                Text(l.camUnknownCode, style: context.t.titleMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text(l.camUnknownCodeNote, style: context.t.bodyMedium),
              ] else if (trouble != null) ...[
                Text(l.camNotRead, style: context.t.titleMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text(trouble!, style: context.t.bodyMedium),
              ] else ...[
                Text(l.camShotReady, style: context.t.titleMedium?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text(l.camShotReadyNote, style: context.t.bodyMedium),
              ],
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onAgain,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.fillSecondary,
                          borderRadius: BorderRadius.circular(CalviSize.rCard),
                        ),
                        child: Text(
                          l.camAgain,
                          style: context.t.titleMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: CalviButton(
                      // Знайдений продукт пишеться в день одразу; знімок їде до
                      // Нори, і запис зробить уже вона.
                      label: item != null
                          ? l.camLogInto(slotIntoLabel(context, slot))
                          : l.camSendToNora,
                      onTap: onSend,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
