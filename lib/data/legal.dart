// GENERATED FILE. Не правити руками.
//
// Джерело: Demo_Flutter/src/data/legal.ts
// Оновити: node tools/legal.mjs

library;

import '../l10n/data_lang.dart';

/// Пункт списку. Жирне завжди на початку, тому це два поля, а не розмітка.
class LegalItem {
  const LegalItem({this.b, this.t});

  /// Жирний початок пункту.
  final String? b;

  /// Продовження звичайним текстом. Може починатись із коми.
  final String? t;
}

/// Розділ: заголовок, абзац, список, і ще абзац після списку.
class LegalPart {
  const LegalPart({required this.h, this.p, this.list, this.tail});

  final String h;
  final String? p;
  final List<LegalItem>? list;
  final String? tail;
}

class LegalDoc {
  const LegalDoc({
    required this.title,
    required this.updated,
    required this.lede,
    required this.parts,
  });

  final String title;

  /// Дата редакції, як її бачить людина.
  final String updated;

  /// Один рядок замість усього тексту, для тих, хто далі не читатиме.
  final String lede;

  final List<LegalPart> parts;
}

const _termsUk = LegalDoc(
  title: 'Умови користування',
  updated: '24 серпня 2026',
  lede: 'Коротко: щоденник безкоштовний, токени витрачаються тільки на помічника, числа є оцінкою і не є медичною порадою.',
  parts: [
  LegalPart(
    h: 'Що це',
    p: 'Calvi це щоденник харчування і ваги. Ти описуєш словами або фотографуєш те, що з’їв, а застосунок розбирає це на страву і числа: калорії, білки, жири, вуглеводи. Сюди ж пишуться вода, тренування, заміри тіла і препарати, які ти приймаєш.',
    tail: 'Користуючись Calvi, ти погоджуєшся з цими умовами. Якщо не погоджуєшся, просто не користуйся: іншого способу прийняти їх наполовину немає.',
  ),
  LegalPart(
    h: 'Це не медичний застосунок',
    p: 'Це найважливіший розділ тут, і він написаний просто. Calvi створений для самоспостереження і загального добробуту. Він не є медичним виробом.',
    list: [
      LegalItem(b: 'Не діагностує і не лікує.', t: ' Не виявляє хвороб, не запобігає їм і не полегшує їх'),
      LegalItem(b: 'Числа це оцінка.', t: ' Калорії й нутрієнти рахуються з твого опису або фото, і вони можуть бути неточними. Це орієнтир, а не вимірювання'),
      LegalItem(b: 'Помічник не дає медичних порад.', t: ' І не замінює лікаря або дієтолога'),
      LegalItem(b: 'Препарати це щоденник, а не призначення.', t: ' Застосунок не радить ліків, не рахує дозувань і не змінює схему прийому'),
      LegalItem(b: 'Алергени це нагадування.', t: ' Ми звіряємо склад продукту з тим, що ти вніс, але не гарантуємо, що знайдемо усе. При алергії читай склад сам, завжди'),
    ],
    tail: 'Порадься з лікарем, перш ніж міняти харчування, і особливо при вагітності чи годуванні, діабеті, хворобах нирок або печінки, розладах харчової поведінки та при постійному прийомі ліків. У невідкладній ситуації телефонуй 103 або 112, а не відкривай застосунок.',
  ),
  LegalPart(
    h: 'Вік',
    p: 'Calvi для повнолітніх. Користуючись ним, ти підтверджуєш, що тобі виповнилось 18. Ми свідомо не заводимо записів для дітей, а якщо дізнаємось про такий, видалимо його.',
    tail: 'Причина не формальна: підрахунок калорій і зниження ваги це чутлива тема для підлітків, і ми не хочемо бути її частиною.',
  ),
  LegalPart(
    h: 'Обліковий запис',
    p: 'Запис створюється сам при першому запуску, без пошти й реєстрації: застосунок має працювати з першої секунди. Вхід через Google робить одну річ, прив’язує цей самий запис до тебе, щоб його можна було повернути на іншому телефоні.',
    list: [
      LegalItem(b: 'Один запис на людину.', t: ' Ділити його з кимось не варто: щоденник рахує одну людину'),
      LegalItem(b: 'Без входу запис живе тільки на цьому телефоні.', t: ' Втратив телефон, і повернути його нічим: ми не знаємо, чий він'),
      LegalItem(b: 'Видалити можна будь-коли.', t: ' Разом із записом зникає все, що лежить на сервері. Як саме, написано в приватності'),
      LegalItem(b: 'Ми можемо закрити доступ,', t: ' якщо запис використовують для навантаження на сервіс або для обходу лічильника токенів'),
    ],
  ),
  LegalPart(
    h: 'Скільки це коштує',
    p: 'Сам щоденник безкоштовний і без обмеження за кількістю записів. Платного тарифу зараз немає взагалі: ні підписки, ні разових покупок, ні платіжних даних.',
    tail: 'Помічник витрачає токени, і вони нараховуються безкоштовно. Скінчились токени, помічник мовчить до наступного нарахування, а щоденник працює далі як працював. Якщо колись з’явиться платний тариф, умови будуть описані тут заздалегідь.',
  ),
  LegalPart(
    h: 'Чого не можна',
    list: [
      LegalItem(t: 'Вносити чужі дані про здоров’я і фотографії інших людей'),
      LegalItem(t: 'Просити в помічника діагноз, призначення чи дозування'),
      LegalItem(t: 'Навмисно вантажити сервіс або обходити лічильник токенів'),
      LegalItem(t: 'Розбирати застосунок і звертатись до сервера повз нього'),
    ],
  ),
  LegalPart(
    h: 'Твої записи лишаються твоїми',
    p: 'Усе, що ти вносиш, належить тобі. Ми не заявляємо на це прав і не продаємо це нікому. Дозвіл, який ти нам даєш, рівно один і рівно на одне: зберігати твої записи й показувати їх тобі, синхронізувати між твоїми пристроями і передавати те, що ти написав помічникові, моделі, яка це розбирає.',
    tail: 'На своїх моделях ми на твоїх даних не навчаємось.',
  ),
  LegalPart(
    h: 'Відповідальність',
    p: 'Calvi надається як є. Ми стараємось, щоб числа були близькі до правди, а сервер працював, але не обіцяємо ні точності оцінок, ні безперервної роботи.',
    tail: 'Це не знімає з нас відповідальності там, де закон її зняти не дозволяє: за шкоду життю і здоров’ю, за умисел і грубу необережність. Права споживача за законом України і, якщо ти в ЄС, за правом твоєї країни, лишаються з тобою повністю.',
  ),
  LegalPart(
    h: 'Якщо умови зміняться',
    p: 'Змінимо, скажемо. Дата редакції стоїть угорі, і суттєві зміни ми показуємо в застосунку до того, як вони почнуть діяти. Незгоден із новою редакцією, видали запис: це і є відмова.',
  ),
  LegalPart(
    h: 'Право і суперечки',
    p: 'До цих умов застосовується право України. Якщо ти споживач і живеш в іншій країні, це не позбавляє тебе захисту, який дають імперативні норми твоєї країни, і не забирає права звернутись до суду за місцем проживання.',
    tail: 'Перш ніж судитись, напиши на calvi.labs@gmail.com. Більшість речей вирішується листом.',
  ),
  LegalPart(
    h: 'Зв’язок',
    p: 'Calvi веде Михайло Нагреба, приватна особа, Україна. Питання, скарги, запити щодо даних: calvi.labs@gmail.com.',
  ),
  ],
);

const _termsEn = LegalDoc(
  title: 'Terms of use',
  updated: '24 August 2026',
  lede: 'In short: the diary is free, tokens are spent only on the assistant, and the figures are estimates rather than medical advice.',
  parts: [
  LegalPart(
    h: 'What this is',
    p: 'Calvi is a food and weight diary. You describe in words or photograph what you ate, and the app works it out into a dish and figures: calories, protein, fat, carbs. Water, workouts, body measurements and the medicines you take go in here too.',
    tail: 'By using Calvi you agree to these terms. If you do not agree, do not use it: there is no way to accept them halfway.',
  ),
  LegalPart(
    h: 'This is not a medical app',
    p: 'This is the most important section here, and it is written plainly. Calvi is built for self-tracking and general wellbeing. It is not a medical device.',
    list: [
      LegalItem(b: 'It does not diagnose or treat.', t: ' It does not detect disease, prevent it or relieve it'),
      LegalItem(b: 'The figures are estimates.', t: ' Calories and nutrients are worked out from your description or photo, and they can be wrong. Treat them as a guide, not a measurement'),
      LegalItem(b: 'The assistant gives no medical advice.', t: ' And is no substitute for a doctor or a dietitian'),
      LegalItem(b: 'Medicines here are a diary, not a prescription.', t: ' The app does not recommend medicines, calculate doses or change your regimen'),
      LegalItem(b: 'Allergens are a reminder.', t: ' We match a product against what you entered, but we do not promise to catch everything. If you have an allergy, read the label yourself, every time'),
    ],
    tail: 'Talk to a doctor before changing how you eat, and especially if you are pregnant or breastfeeding, have diabetes, kidney or liver disease, an eating disorder, or take medicines regularly. In an emergency call your local emergency number, do not open the app.',
  ),
  LegalPart(
    h: 'Age',
    p: 'Calvi is for adults. By using it you confirm that you are 18 or older. We do not knowingly keep accounts for children, and we will delete one if we learn of it.',
    tail: 'The reason is not a formality: counting calories and losing weight is a sensitive subject for teenagers, and we do not want to be part of it.',
  ),
  LegalPart(
    h: 'Your account',
    p: 'An account is created by itself on the first run, with no email and no sign-up: the app has to work from the first second. Signing in with Google does one thing, it ties that same account to you so it can be brought back on another phone.',
    list: [
      LegalItem(b: 'One account per person.', t: ' Sharing it is a bad idea: the diary counts one person'),
      LegalItem(b: 'Without signing in, the account lives only on this phone.', t: ' Lose the phone and there is nothing to bring it back with: we do not know whose it is'),
      LegalItem(b: 'You can delete it whenever you like.', t: ' Everything on the server goes with it. How exactly is written in the privacy notice'),
      LegalItem(b: 'We may close access', t: ' if an account is used to load the service or to get around the token counter'),
    ],
  ),
  LegalPart(
    h: 'What it costs',
    p: 'The diary itself is free, with no limit on the number of entries. There is no paid tier at all right now: no subscription, no one-off purchases, no payment details.',
    tail: 'The assistant spends tokens, and tokens are granted for free. Run out and the assistant goes quiet until the next grant, while the diary carries on as before. If a paid tier ever appears, its terms will be described here in advance.',
  ),
  LegalPart(
    h: 'What you may not do',
    list: [
      LegalItem(t: 'Enter other people’s health data or photographs of other people'),
      LegalItem(t: 'Ask the assistant for a diagnosis, a prescription or a dose'),
      LegalItem(t: 'Deliberately load the service or get around the token counter'),
      LegalItem(t: 'Take the app apart and talk to the server around it'),
    ],
  ),
  LegalPart(
    h: 'Your entries stay yours',
    p: 'Everything you enter belongs to you. We claim no rights over it and we sell it to no one. The permission you give us is exactly one, and for exactly one thing: to store your entries and show them back to you, sync them between your devices, and pass what you write to the assistant to the model that works it out.',
    tail: 'We do not train our own models on your data.',
  ),
  LegalPart(
    h: 'Liability',
    p: 'Calvi is provided as it is. We work to keep the figures close to the truth and the server running, but we do not promise the accuracy of estimates or uninterrupted service.',
    tail: 'This does not remove our liability where the law does not allow it to be removed: for death or personal injury, for intent and gross negligence. Your consumer rights under the law of your country stay with you in full.',
  ),
  LegalPart(
    h: 'If these terms change',
    p: 'If we change them, we will say so. The revision date is at the top, and we show material changes in the app before they take effect. If you disagree with a new revision, delete your account: that is how you decline.',
  ),
  LegalPart(
    h: 'Law and disputes',
    p: 'These terms are governed by the law of Ukraine. If you are a consumer living elsewhere, this does not deprive you of the protection of the mandatory rules of your own country, nor of the right to go to a court where you live.',
    tail: 'Before going to court, write to calvi.labs@gmail.com. Most things are settled by letter.',
  ),
  LegalPart(
    h: 'Contact',
    p: 'Calvi is run by Mykhailo Nahreba, an individual, Ukraine. Questions, complaints, data requests: calvi.labs@gmail.com.',
  ),
  ],
);

const _privacyUk = LegalDoc(
  title: 'Політика приватності',
  updated: '24 серпня 2026',
  lede: 'Коротко: ми збираємо те, що ти сам вносиш, фотографії не зберігаємо, аналітики й реклами немає, і все можна видалити.',
  parts: [
  LegalPart(
    h: 'Хто відповідає',
    p: 'Calvi веде Михайло Нагреба, приватна особа, Україна. Це та людина, яка вирішує, які дані збираються і навіщо, тобто володілець у розумінні закону. Написати можна на calvi.labs@gmail.com.',
  ),
  LegalPart(
    h: 'Що ми зберігаємо',
    p: 'Рівно те, що ти вносиш сам, і те, без чого не працює вхід.',
    list: [
      LegalItem(b: 'Профіль.', t: ' Стать, рік народження, зріст, ціль і темп, денна норма, як до тебе звертатись'),
      LegalItem(b: 'Щоденник.', t: ' Страви з вагою і числами, вода, вага, заміри тіла, тренування'),
      LegalItem(b: 'Здоров’я.', t: ' Препарати з дозами і годинами прийому, позначки про фактичний прийом, алергії'),
      LegalItem(b: 'Пам’ять помічника.', t: ' Короткі нотатки про тебе, які ти сам попросив запам’ятати'),
      LegalItem(b: 'Вхід.', t: ' Якщо ти входив через Google, ми зберігаємо твою пошту і сталий ідентифікатор Google. Ні імені, ні фото профілю ми не беремо'),
      LegalItem(b: 'Сесії.', t: ' Відбиток токена доступу і рядок про пристрій, на кшталт «Pixel 8, Android 15», щоб ти бачив, звідки заходив'),
      LegalItem(b: 'Токени помічника.', t: ' Скільки лишилось і на що витрачалось'),
    ],
  ),
  LegalPart(
    h: 'Чого ми не збираємо',
    p: 'Це коротший список, і він важливіший за перший.',
    list: [
      LegalItem(b: 'Аналітики немає.', t: ' Жодної: ні своєї, ні чужої'),
      LegalItem(b: 'Реклами немає,', t: ' і рекламних ідентифікаторів теж'),
      LegalItem(b: 'Збору збоїв немає.', t: ' Застосунок не надсилає нам звітів про падіння'),
      LegalItem(b: 'Місця немає.', t: ' Ми не питаємо і не отримуємо геолокацію'),
      LegalItem(b: 'Контактів, календаря і файлів немає'),
      LegalItem(b: 'Свого ідентифікатора пристрою застосунок не створює'),
    ],
  ),
  LegalPart(
    h: 'Фотографії',
    p: 'Фото страви ніде не зберігається. Воно живе в пам’яті рівно стільки, скільки триває один запит: приходить на сервер, іде до моделі, яка його розбирає, і зникає. Ні в базі, ні на диску, ні в резервних копіях його немає.',
    tail: 'Те саме з кадром на телефоні: він не потрапляє в галерею і не лишається у файлах.',
  ),
  LegalPart(
    h: 'Розмова з помічником',
    p: 'Текст розмови на сервері не зберігається. Він проходить крізь нього, щоб отримати відповідь, і лишається тільки на твоєму телефоні. Записаною лишається сама страва, яку ти в підсумку додав у щоденник.',
  ),
  LegalPart(
    h: 'Голос',
    p: 'Диктування виконує служба розпізнавання мови твого телефона, а не ми. До нас приходить уже готовий текст. Звук ми не отримуємо і не зберігаємо.',
  ),
  LegalPart(
    h: 'Кому це передається',
    p: 'Трьом, і кожному рівно стільки, скільки потрібно для його роботи.',
    list: [
      LegalItem(b: 'Google Gemini,', t: ' щоб розібрати твій опис або фото на страву і числа. Туди йде текст, який ти написав, фото, кілька попередніх реплік і короткий блок про тебе: звертання, стать, вік, зріст, вага, ціль, денна норма, алергії й закріплені нотатки. Пошта, ідентифікатори акаунта і будь-що, з чого можна дізнатись твоє ім’я поза межами того, як ти просив себе називати, туди не йдуть'),
      LegalItem(b: 'Open Food Facts і USDA,', t: ' коли ти скануєш штрихкод. Туди йде тільки сам штрихкод і нічого більше'),
      LegalItem(b: 'Хостинг.', t: ' Сервер і база стоять на орендованій машині, а перед нею стоїть Cloudflare, який пропускає трафік і бачить твою IP-адресу'),
    ],
    tail: 'Нікому іншому дані не передаються. Ми їх не продаємо, не обмінюємо і не віддаємо рекламним мережам.',
  ),
  LegalPart(
    h: 'Що лишається в журналах сервера',
    p: 'Метод запиту, адреса, код відповіді й IP, з якого прийшов запит. Вміст запитів у журнали не пишеться: ні текст, ні фото, ні числа щоденника. Ключі доступу з журналів вирізаються.',
  ),
  LegalPart(
    h: 'На якій підставі',
    p: 'Профіль, синхронізація і вхід обробляються, щоб виконати те, про що ми домовились: дати тобі щоденник, який працює. Дані про здоров’я, тобто вага, заміри, препарати й алергії, обробляються на підставі твоєї явної згоди, яку ти даєш, вносячи їх.',
    tail: 'Згоду можна забрати назад: видали ці записи або видали весь акаунт.',
  ),
  LegalPart(
    h: 'Скільки зберігається',
    p: 'Поки живе твій запис. Видалив запис, дані зникають.',
    list: [
      LegalItem(b: 'Щоденник і профіль', t: ' лежать, поки ти їх не видалиш'),
      LegalItem(b: 'Сесія', t: ' діє рік від останнього входу, потім протухає сама'),
      LegalItem(b: 'Журнали сервера', t: ' зберігаються не довше за 30 днів'),
      LegalItem(b: 'Резервні копії бази', t: ' перезаписуються протягом 30 днів'),
    ],
  ),
  LegalPart(
    h: 'Твої права',
    p: 'Усе це робиться листом, і ми відповідаємо не пізніше ніж за 30 днів.',
    list: [
      LegalItem(t: 'Отримати копію всього, що ми про тебе зберігаємо'),
      LegalItem(t: 'Виправити те, що записано неправильно'),
      LegalItem(t: 'Видалити акаунт разом з усім, що на сервері'),
      LegalItem(t: 'Стерти щоденник і лишити акаунт: почати з чистого аркуша, не втративши вхід'),
      LegalItem(t: 'Заперечити проти обробки або попросити її обмежити'),
      LegalItem(t: 'Поскаржитись до наглядового органу своєї країни'),
    ],
    tail: 'Напиши на calvi.labs@gmail.com з тієї пошти, якою входив, або з телефона, де стоїть застосунок. Користуватись щоденником без помічника теж можна: тоді назовні не йде жодного повідомлення.',
  ),
  LegalPart(
    h: 'Автоматичний розбір',
    p: 'Страву і числа визначає модель, автоматично. Це оцінка, а не рішення про тебе: жодних наслідків, крім цифри в щоденнику, вона не має, і будь-яке число можна виправити руками.',
  ),
  LegalPart(
    h: 'Безпека',
    p: 'Зв’язок із сервером іде тільки по захищеному з’єднанню. Токени доступу зберігаються у вигляді відбитків, а не самих значень. Доступ до бази має одна людина, яка веде сервіс.',
    tail: 'Якщо станеться витік, який загрожує тобі, ми повідомимо тебе і наглядовий орган, щойно дізнаємось.',
  ),
  LegalPart(
    h: 'Діти',
    p: 'Calvi для повнолітніх. Ми свідомо не збираємо дані осіб, молодших за 18 років. Якщо ти батько або опікун і вважаєш, що дитина завела тут запис, напиши на calvi.labs@gmail.com, і ми його видалимо.',
  ),
  LegalPart(
    h: 'Якщо ця сторінка зміниться',
    p: 'Дата редакції стоїть угорі. Про суттєві зміни ми скажемо в застосунку до того, як вони почнуть діяти, а не після.',
  ),
  ],
);

const _privacyEn = LegalDoc(
  title: 'Privacy Policy',
  updated: '24 August 2026',
  lede: 'In short: we keep what you enter yourself, we do not store photographs, there is no analytics and no advertising, and everything can be deleted.',
  parts: [
  LegalPart(
    h: 'Who is responsible',
    p: 'Calvi is run by Mykhailo Nahreba, an individual, Ukraine. That is the person who decides what data is collected and why, the controller in the sense of the law. You can write to calvi.labs@gmail.com.',
  ),
  LegalPart(
    h: 'What we store',
    p: 'Exactly what you enter yourself, and what signing in cannot work without.',
    list: [
      LegalItem(b: 'Profile.', t: ' Sex, year of birth, height, goal and pace, daily target, how to address you'),
      LegalItem(b: 'Diary.', t: ' Dishes with weights and figures, water, weight, body measurements, workouts'),
      LegalItem(b: 'Health.', t: ' Medicines with doses and times, marks that a dose was taken, allergies'),
      LegalItem(b: 'Assistant memory.', t: ' Short notes about you that you asked it to remember'),
      LegalItem(b: 'Sign-in.', t: ' If you signed in with Google, we store your email address and a stable Google identifier. We take neither your name nor your profile picture'),
      LegalItem(b: 'Sessions.', t: ' A fingerprint of the access token and a line about the device, such as "Pixel 8, Android 15", so you can see where you signed in from'),
      LegalItem(b: 'Assistant tokens.', t: ' How many are left and what they were spent on'),
    ],
  ),
  LegalPart(
    h: 'What we do not collect',
    p: 'A shorter list, and a more important one than the first.',
    list: [
      LegalItem(b: 'There is no analytics.', t: ' None at all: neither ours nor anyone else’s'),
      LegalItem(b: 'There is no advertising,', t: ' and no advertising identifiers'),
      LegalItem(b: 'There is no crash reporting.', t: ' The app sends us no crash reports'),
      LegalItem(b: 'There is no location.', t: ' We neither ask for it nor receive it'),
      LegalItem(b: 'No contacts, no calendar, no files'),
      LegalItem(b: 'The app creates no device identifier of its own'),
    ],
  ),
  LegalPart(
    h: 'Photographs',
    p: 'A photo of a meal is not stored anywhere. It lives in memory for exactly as long as one request takes: it arrives at the server, goes to the model that reads it, and is gone. It is not in the database, not on disk, not in backups.',
    tail: 'The same on the phone: the frame does not reach your gallery and does not stay in your files.',
  ),
  LegalPart(
    h: 'Talking to the assistant',
    p: 'The text of the conversation is not stored on the server. It passes through to get an answer and stays only on your phone. What is stored is the dish itself, once you add it to the diary.',
  ),
  LegalPart(
    h: 'Voice',
    p: 'Dictation is done by your phone’s own speech recognition, not by us. What reaches us is finished text. We neither receive nor store audio.',
  ),
  LegalPart(
    h: 'Who it is passed to',
    p: 'Three parties, each getting exactly as much as its job needs.',
    list: [
      LegalItem(b: 'Google Gemini,', t: ' to work your description or photo into a dish and figures. It receives the text you wrote, the photo, a few previous messages, and a short block about you: how to address you, sex, age, height, weight, goal, daily target, allergies and pinned notes. Your email, your account identifiers and anything that would reveal your name beyond what you asked to be called do not go there'),
      LegalItem(b: 'Open Food Facts and USDA,', t: ' when you scan a barcode. Only the barcode itself goes there, nothing else'),
      LegalItem(b: 'Hosting.', t: ' The server and the database sit on a rented machine, with Cloudflare in front of it passing traffic through and seeing your IP address'),
    ],
    tail: 'It goes to no one else. We do not sell it, trade it or hand it to advertising networks.',
  ),
  LegalPart(
    h: 'What stays in the server logs',
    p: 'The request method, the address, the response code and the IP the request came from. Request bodies are not written to the logs: not the text, not the photo, not the figures in your diary. Access keys are stripped out of the logs.',
  ),
  LegalPart(
    h: 'On what legal basis',
    p: 'Your profile, syncing and sign-in are processed to do what we agreed on: give you a diary that works. Health data, that is weight, measurements, medicines and allergies, is processed on your explicit consent, which you give by entering it.',
    tail: 'You can take that consent back: delete those entries, or delete the whole account.',
  ),
  LegalPart(
    h: 'How long it is kept',
    p: 'As long as your account lives. Delete the account and the data is gone.',
    list: [
      LegalItem(b: 'Diary and profile', t: ' stay until you delete them'),
      LegalItem(b: 'A session', t: ' lasts a year from the last sign-in, then expires by itself'),
      LegalItem(b: 'Server logs', t: ' are kept for no longer than 30 days'),
      LegalItem(b: 'Database backups', t: ' are overwritten within 30 days'),
    ],
  ),
  LegalPart(
    h: 'Your rights',
    p: 'All of this is done by letter, and we answer within 30 days.',
    list: [
      LegalItem(t: 'Get a copy of everything we store about you'),
      LegalItem(t: 'Correct anything recorded wrongly'),
      LegalItem(t: 'Delete the account along with everything on the server'),
      LegalItem(t: 'Wipe the diary and keep the account: start from a clean slate without losing the sign-in'),
      LegalItem(t: 'Object to the processing, or ask us to restrict it'),
      LegalItem(t: 'Complain to the supervisory authority in your country'),
    ],
    tail: 'Write to calvi.labs@gmail.com from the address you signed in with, or from the phone the app is on. You can also use the diary without the assistant, in which case no message goes out at all.',
  ),
  LegalPart(
    h: 'Automated reading',
    p: 'The dish and the figures are determined by a model, automatically. That is an estimate, not a decision about you: it has no consequence beyond a number in your diary, and any number can be corrected by hand.',
  ),
  LegalPart(
    h: 'Security',
    p: 'Traffic to the server goes over a secure connection only. Access tokens are stored as fingerprints rather than as the values themselves. One person, the one who runs the service, has access to the database.',
    tail: 'If a breach happens that puts you at risk, we will tell you and the supervisory authority as soon as we know.',
  ),
  LegalPart(
    h: 'Children',
    p: 'Calvi is for adults. We do not knowingly collect data from anyone under 18. If you are a parent or guardian and believe a child has an account here, write to calvi.labs@gmail.com and we will delete it.',
  ),
  LegalPart(
    h: 'If this page changes',
    p: 'The revision date is at the top. We will tell you about material changes in the app before they take effect, not after.',
  ),
  ],
);

/* Документ мовою застосунку.
 *
 * Дві редакції цілими, а не по рядку. Юридичний текст читають цілим, і речення,
 * зшите з двох мов по фрагменту, надто легко зробити таким, що англійською
 * обіцяє не те, що українською. */
LegalDoc get terms => dataLang == 'uk' ? _termsUk : _termsEn;

LegalDoc get privacy => dataLang == 'uk' ? _privacyUk : _privacyEn;
