import 'store_config.dart';

/* App Store: iOS і macOS.
 *
 * Ключ публічний за задумом: він їде всередині застосунку і видний у будь-якому
 * розібраному IPA. Секретний ключ RevenueCat має інший префікс і в застосунку не
 * зʼявляється ніколи, він живе на сервері.
 *
 * Значення прямо тут, а не тільки через `--dart-define`: забутий прапорець
 * збірки тихо вимикав би оплату, і помітили б це вже в сторі. Змінна лишається,
 * щоб підмінити ключ, не чіпаючи код: `--dart-define=RC_IOS_KEY=test_...`
 * вмикає Test Store RevenueCat, де покупка імітується без аркуша Apple.
 *
 * Товари в App Store Connect: `calvi_pro_monthly` і `calvi_pro_yearly`, група
 * «Calvi Pro». У коді назви не шукаються: тариф береться за видом пакета.
 *
 * Пісочниця (TestFlight): пароль Apple питається на кожну покупку, Face ID там
 * не працює, а ціни можуть показуватись у доларах, доки вітрина sandbox-акаунта
 * не збіглась із вітриною телефона. У бойовому App Store обидві речі зникають. */
const appleStore = StoreConfig(
  name: 'App Store',
  key: String.fromEnvironment('RC_IOS_KEY', defaultValue: 'appl_wnvJBVYjiDuTMlvcZMPeVeyxGvv'),
);
