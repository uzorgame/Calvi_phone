import 'store_config.dart';

/* Google Play: Android.
 *
 * Ключ публічний, як і в Apple: він їде всередині APK і видний у розібраному.
 * Застосунок «Calvi (Play Store)» у RevenueCat заведено 2 вересня 2026, коли
 * Google підтвердив платіжний профіль. SDK один на обидві крамниці, `Billing`
 * бере тариф за видом пакета, а сервер уже розбирає події з `store: PLAY_STORE`.
 *
 * Що ще треба до першої покупки на Android, крім ключа:
 *   1. У Play Console підписка `calvi_pro` з базовими планами `monthly` і
 *      `yearly`. У RevenueCat такий товар зветься `calvi_pro:monthly`, і саме
 *      так він приїде у вебхуку полем `product_id`.
 *   2. У RevenueCat ці товари додані в ті самі пакети офферінгу, що й товари
 *      Apple: місячний і річний. Тоді `Billing.plans()` знайде їх, як і на iOS.
 *   3. У застосунку Play в RevenueCat службовий обліковий запис Google
 *      (service account JSON) для сповіщень про поновлення і повернення. Без
 *      нього вебхуки з Play запізнюються на години.
 *   4. Тестери ліцензій у Play Console, щоб купувати без списання.
 *
 * `--dart-define=RC_ANDROID_KEY=test_...` вмикає Test Store і тут: ключ Test
 * Store один на обидві платформи. */
const googleStore = StoreConfig(
  name: 'Google Play',
  key: String.fromEnvironment(
    'RC_ANDROID_KEY',
    defaultValue: 'goog_BaspRxVFJJIbbEeeOfSEZIXkABA',
  ),
);
