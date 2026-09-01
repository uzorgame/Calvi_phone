import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

/* Підписка: усе, що застосунок знає про магазин.
 *
 * Один шар на весь застосунок, і решта коду про RevenueCat не чує. Екран
 * підписки просить план і натискає «купити», а звідки взялась ціна і що
 * робити з чеком, вирішується тут.
 *
 * **Доступ дає сервер, а не цей файл.** Магазин підтверджує покупку RevenueCat,
 * той шле вебхук нашому серверу, сервер ставить `pro_until` і знімає лічильник
 * токенів. Питати телефон «чи він платний» означало б вірити пристрою, з якого
 * знімають лічильник, а це та сама помилка, через яку підписки ламають дітям на
 * планшетах. Тому `isPro` тут використовується лише для швидкого вигляду
 * одразу після покупки, а правда приїде з сервера наступною синхронізацією. */

/// Публічні ключі SDK, свій на кожен магазин.
///
/// Не секрет: вони їдуть усередині застосунку і видні в будь-якому розібраному
/// APK, так і задумано. Секретний ключ RevenueCat має інший префікс і в
/// застосунку не з'являється ніколи.
///
/// Порожньо означає «магазин не підключений»: усе нижче стає тихим, а екран
/// підписки показує сторінку без цін. Так застосунок збирається і працює до
/// того, як ключі з'являться, і не падає в тестах.
/// Значення прямо тут, а не тільки через `--dart-define`: забутий прапорець
/// збірки тихо вимикав би оплату, і помітили б це вже в сторі. Змінна лишається
/// як спосіб підмінити ключ, не чіпаючи код.
const _appleKey = String.fromEnvironment(
  'RC_IOS_KEY',
  defaultValue: 'appl_wnvJBVYjiDuTMlvcZMPeVeyxGvv',
);

/// Порожньо, поки в RevenueCat не заведений застосунок Play. А він чекає, поки
/// Google підтвердить платіжний профіль.
const _googleKey = String.fromEnvironment('RC_ANDROID_KEY');

/// Ідентифікатор права доступу в RevenueCat. Одне на весь застосунок.
const _entitlement = 'pro';

/// Один тариф, як його віддав магазин.
///
/// `display` це готовий рядок із валютою і місцевим форматом, і саме він іде на
/// екран. Свого форматування тут немає навмисно: показувати не те, що стягне
/// стор, заборонено правилами рев'ю обох магазинів.
class StorePlan {
  const StorePlan({
    required this.kind,
    required this.productId,
    required this.display,
    required this.amount,
    this.package,
  });

  /* Місяць це 'month', рік це 'year'. Береться з типу пакета в RevenueCat, а не
     з назви товару, і це принципово.
   *
   * Ідентифікатори товарів у трьох крамницях різні й будуть різними завжди: в
   * Apple це `calvi_pro_yearly`, у Play підписка з базовим планом усередині, а
   * в тестовій крамниці взагалі `yearly`. Екран, який шукає товар за назвою,
   * ламається від кожної з цих відмінностей і показує порожню сторінку. Тип
   * пакета однаковий скрізь. */
  final String kind;

  /// Як товар зветься у своїй крамниці. Для журналу і розбору скарг, не для
  /// пошуку.
  final String productId;

  /// «$8.99», «199 ₴», «39,99 zł».
  final String display;

  /// Те саме числом, для власних підрахунків на кшталт «скільки на місяць».
  final double amount;

  /// Що передати магазину при покупці. Порожньо в підставних тарифах.
  final Package? package;
}

/// Чим скінчилась покупка. Скасування це не помилка, і плутати їх не можна:
/// людина, яка передумала, не має бачити «щось пішло не так».
enum BuyResult { done, canceled, failed }

class Billing {
  Billing._();

  static bool _ready = false;

  /// Чи підключений магазин узагалі. Поки ключа немає, екран підписки живе без
  /// цін, а кнопка покупки не вдає, що працює.
  static bool get configured => _key.isNotEmpty;

  static String get _key {
    if (kIsWeb) return '';
    if (Platform.isIOS || Platform.isMacOS) return _appleKey;
    if (Platform.isAndroid) return _googleKey;
    return '';
  }

  /* Підняти SDK. Викликається один раз зі старту застосунку.
   *
   * Помилка тут нічого не валить: без магазину застосунок лишається щоденником,
   * а щоденник це те, чим людина користується щодня. Впасти на старті через те,
   * що не піднявся модуль оплати, було б обміном головного на другорядне. */
  static Future<void> start() async {
    if (_ready || !configured) return;
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(_key));
      _ready = true;
    } catch (e) {
      note = 'SDK не піднявся: $e';
      debugPrint('billing: $note');
    }
  }

  /* Сказати магазину, хто це.
   *
   * Наш `userId` стає `app_user_id` у RevenueCat, і саме за ним вебхук знайде
   * людину на сервері. Без цього покупка приїде під випадковим ідентифікатором,
   * і зіставити її з акаунтом буде нічим.
   *
   * Порожній ідентифікатор означає вихід з акаунта: далі RevenueCat рахує
   * покупки анонімними, поки хтось не увійде знову. */
  static Future<void> identify(String? userId) async {
    if (!_ready) return;
    try {
      if (userId == null || userId.isEmpty) {
        await Purchases.logOut();
      } else {
        await Purchases.logIn(userId);
      }
    } catch (e) {
      debugPrint('billing: не вдалось назватись ($e)');
    }
  }

  /* Що саме сталось під час останнього запиту тарифів.
   *
   * Не для краси. Порожній список у відповідь на «дай тарифи» має три різні
   * причини, і зовні вони виглядають однаково: не піднятий SDK, немає
   * офферінга, магазин не віддав товари. Без цього рядка розрізнити їх можна
   * лише здогадками, а вони коштували нам години. */
  static String note = 'ще не питали';

  /* Тарифи з магазину: місячний і річний.
   *
   * Порожньо означає «магазин не відповів або товарів ще немає». Екран у такому
   * разі показує сторінку без цін, а не вигадані числа. */
  static Future<List<StorePlan>> plans() async {
    if (!configured) {
      note = 'магазин не підключений';
      return const [];
    }
    if (!_ready) {
      note = 'SDK не піднявся';
      return const [];
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        note = 'офферінга немає (усього: ${offerings.all.length})';
        return const [];
      }

      final out = <StorePlan>[];
      for (final (kind, p) in [('month', current.monthly), ('year', current.annual)]) {
        if (p == null) continue;
        out.add(
          StorePlan(
            kind: kind,
            productId: p.storeProduct.identifier,
            display: p.storeProduct.priceString,
            amount: p.storeProduct.price,
            package: p,
          ),
        );
      }
      note = out.isEmpty
          ? 'офферінг «${current.identifier}» без пакетів місяця і року'
          : 'ok: ${out.map((p) => '${p.kind}=${p.productId} ${p.display}').join(', ')}';
      debugPrint('billing: $note');
      return out;
    } catch (e) {
      note = 'помилка: $e';
      debugPrint('billing: $note');
      return const [];
    }
  }

  /* Купити.
   *
   * Право доступу перевіряється одразу, щоб екран не завмер до наступної
   * синхронізації. Але це лише вигляд: лічильник токенів зніме сервер, коли
   * отримає вебхук. */
  static Future<BuyResult> buy(StorePlan plan) async {
    final pack = plan.package;
    if (!_ready || pack == null) return BuyResult.failed;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(pack));
      return result.customerInfo.entitlements.active.containsKey(_entitlement)
          ? BuyResult.done
          : BuyResult.failed;
    } on PlatformException catch (e) {
      /* Скасування це не помилка. Людина передумала, і сказати їй «щось пішло
         не так» означало б звинуватити її у власному рішенні. */
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return BuyResult.canceled;
      debugPrint('billing: покупка не пройшла ($code)');
      return BuyResult.failed;
    } catch (e) {
      debugPrint('billing: покупка не пройшла ($e)');
      return BuyResult.failed;
    }
  }

  /* Відновити покупки.
   *
   * Обов'язкове за правилами обох сторів: людина, яка змінила телефон, має
   * повернути оплачене без звернень у підтримку. Повертає, чи знайшлась активна
   * підписка. */
  static Future<bool> restore() async {
    if (!_ready) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlement);
    } catch (e) {
      debugPrint('billing: відновлення не вдалось ($e)');
      return false;
    }
  }

  /* Куди йти скасовувати.
   *
   * Своєї кнопки «скасувати» в застосунку немає і не буде: підпискою керує
   * магазин, з якого вона оформлена, так вимагають правила обох. Порожньо
   * означає «підписки в цього акаунта немає», і тоді відкривати нічого. */
  static Future<String?> manageUrl() async {
    if (!_ready) return null;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.managementURL;
    } catch (e) {
      debugPrint('billing: не дізнались адресу керування ($e)');
      return null;
    }
  }
}
