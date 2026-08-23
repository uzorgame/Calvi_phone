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
  updated: '20 серпня 2026',
  lede:
      'Коротко: щоденник безкоштовний, токени витрачаються тільки на помічника, числа є оцінкою і не є медичною порадою.',
  parts: [
    LegalPart(
      h: 'Що входить',
      p: 'Ведення щоденника, аналітика, синхронізація і всі дані, які ти вносиш, доступні без оплати і без обмеження за кількістю записів.',
    ),
    LegalPart(
      h: 'Обліковий запис',
      p: 'Запис створюється сам при першому запуску, без пошти й реєстрації: застосунок має працювати з першої секунди. Вхід через Google робить одну річ, привʼязує цей самий запис до тебе, щоб його можна було повернути на іншому телефоні.',
      list: [
        LegalItem(
          b: 'Один запис на людину.',
          t: ' Ділити його з кимось не варто: щоденник рахує одну людину',
        ),
        LegalItem(
          b: 'Без входу запис живе тільки на цьому телефоні.',
          t: ' Втратив телефон, і повернути його нічим: ми не знаємо, чий він',
        ),
        LegalItem(t: 'Видалити запис можна будь-коли, і разом із ним зникає все, що на сервері'),
        LegalItem(
          t: 'Ми можемо закрити доступ, якщо запис використовують для навантаження на сервіс або для обходу лічильника токенів',
        ),
      ],
    ),
    LegalPart(
      h: 'Токени',
      list: [
        LegalItem(t: 'Нараховуються при першій реєстрації і далі щодня'),
        LegalItem(t: 'Списуються за роботу помічника: повідомлення один, фото два'),
        LegalItem(t: 'Повертаються автоматично, якщо збій стався з нашого боку'),
        LegalItem(t: 'Не є валютою, не обмінюються на гроші й не передаються між акаунтами'),
      ],
    ),
    LegalPart(
      h: 'Точність чисел',
      p: 'Калорійність і склад це оцінка. Для упакованих продуктів вона береться з етикетки або з відкритої бази, для страв це середні значення. Застосунок завжди показує, коли число є оцінкою.',
    ),
    LegalPart(
      h: 'За що ми не відповідаємо',
      p: 'За рішення щодо здоровʼя, харчування чи ліків, ухвалені на основі показаних чисел. Calvi це інструмент обліку, а не медичний прилад і не лікар.',
    ),
    LegalPart(
      h: 'Зміни',
      p: 'Якщо умови зміняться суттєво, ми скажемо про це в застосунку, а не лише тихою правкою тут.',
    ),
  ],
);

const _termsEn = LegalDoc(
  title: 'Terms of use',
  updated: '20 August 2026',
  lede:
      'In short: the diary is free, tokens are spent only on the assistant, and the figures are estimates rather than medical advice.',
  parts: [
    LegalPart(
      h: 'What is included',
      p: 'Keeping the diary, analytics, syncing, and all the data you enter are available at no cost and with no limit on the number of entries.',
    ),
    LegalPart(
      h: 'Your account',
      p: 'An account is created by itself on the first run, with no email and no sign-up: the app has to work from the first second. Signing in with Google does one thing, it ties that same account to you so it can be brought back on another phone.',
      list: [
        LegalItem(
          b: 'One account per person.',
          t: ' Sharing it is a bad idea: the diary counts one person',
        ),
        LegalItem(
          b: 'Without signing in, the account lives only on this phone.',
          t: ' Lose the phone and there is nothing to bring it back with: we do not know whose it is',
        ),
        LegalItem(
          t: 'You can delete the account at any time, and everything on the server goes with it',
        ),
        LegalItem(
          t: 'We may close access if an account is used to load the service or to get around the token counter',
        ),
      ],
    ),
    LegalPart(
      h: 'Tokens',
      list: [
        LegalItem(t: 'Granted on first registration and daily after that'),
        LegalItem(t: 'Spent on the assistant: one for a message, two for a photo'),
        LegalItem(t: 'Returned automatically if the failure was on our side'),
        LegalItem(
          t: 'Not a currency, not exchangeable for money, and not transferable between accounts',
        ),
      ],
    ),
    LegalPart(
      h: 'How exact the figures are',
      p: 'Calories and composition are an estimate. For packaged products it comes from the label or from an open base; for dishes these are average values. The app always shows when a figure is an estimate.',
    ),
    LegalPart(
      h: 'What we are not responsible for',
      p: 'Decisions about health, food or medication taken on the basis of the figures shown. Calvi is a record-keeping tool, not a medical device and not a doctor.',
    ),
    LegalPart(
      h: 'Changes',
      p: 'If the terms change in any substantial way, we will say so in the app, not only by quietly editing this.',
    ),
  ],
);

const _privacyUk = LegalDoc(
  title: 'Політика приватності',
  updated: '20 серпня 2026',
  lede:
      'Коротко: щоденник живе на твоєму телефоні, копія на сервері потрібна для синхронізації, фото не зберігаються.',
  parts: [
    LegalPart(
      h: 'Що ми зберігаємо',
      p: 'Записи щоденника: страви, вага, вода, тренування, вимірювання, препарати і налаштування профілю. Плюс технічне: ідентифікатор пристрою, час останнього звернення і баланс токенів.',
      list: [
        LegalItem(
          b: 'Основне джерело правди це телефон.',
          t: ' Сервер тримає копію, щоб пристрої бачили одне й те саме',
        ),
        LegalItem(
          b: 'Фотографії їжі не зберігаються.',
          t: ' Знімок живе рівно стільки, скільки триває розбір, і не потрапляє в базу',
        ),
        LegalItem(b: 'Ми не збираємо контакти, місцеположення і не читаємо інші застосунки'),
      ],
    ),
    LegalPart(
      h: 'Якщо ти увійшов через Google',
      p: 'Вхід не обовʼязковий: щоденник працює й без нього. Він потрібен для одного, щоб записи можна було повернути на новий телефон.',
      list: [
        LegalItem(
          b: 'Сталий ідентифікатор твого акаунта Google.',
          t: ' Це і є ключ, за яким ми впізнаємо тебе наступного разу. Він не змінюється, навіть якщо змінити пошту',
        ),
        LegalItem(
          b: 'Пошта',
          t: ', і тільки підтверджена. Потрібна, щоб ти бачив, у який акаунт увійшов, і щоб ми впізнали тебе, коли ти напишеш нам',
        ),
        LegalItem(
          b: 'Імʼя, фото профілю і список контактів ми не просимо.',
          t: ' Google їх не передає, бо ми не питаємо',
        ),
      ],
      tail:
          'Пошта нікуди не їде далі нашого сервера: ні до постачальника моделі, ні в аналітику, ні в рекламу, якої в нас немає.',
    ),
    LegalPart(
      h: 'Навіщо це нам',
      p: 'Щоб щоденник працював на кількох пристроях, щоб помічник міг відповісти на питання про минулий тиждень і щоб порахувати токени. Інших причин немає: ми не продаємо дані і не показуємо реклами.',
    ),
    LegalPart(
      h: 'Хто ще їх бачить',
      p: 'Текст повідомлення до помічника і знімок тарілки передаються постачальнику моделі рівно на час відповіді. Разом із ними їде маленький сталий набір: як до тебе звертатись, ціль, норма і алергії. Імені, пошти й телефону там немає.',
    ),
    LegalPart(
      h: 'Скільки це живе',
      p: 'Поки існує акаунт. Видалення акаунта прибирає записи з сервера остаточно; локальна копія зникає разом із застосунком.',
    ),
    LegalPart(
      h: 'Твої права',
      list: [
        LegalItem(t: 'Отримати копію всього, що ми про тебе зберігаємо'),
        LegalItem(t: 'Видалити акаунт разом із усім, що на сервері'),
        LegalItem(
          t: 'Стерти щоденник, лишивши сам акаунт: почати з чистого аркуша, не втрачаючи входу',
        ),
        LegalItem(
          t: 'Користуватись щоденником без помічника, і тоді на сервер не їде жодне повідомлення',
        ),
      ],
      tail: 'Для будь-чого з цього достатньо написати на calvi.labs@gmail.com.',
    ),
  ],
);

const _privacyEn = LegalDoc(
  title: 'Privacy policy',
  updated: '20 August 2026',
  lede:
      'In short: the diary lives on your phone, the copy on the server is there for syncing, and photos are not kept.',
  parts: [
    LegalPart(
      h: 'What we store',
      p: 'Diary entries: dishes, weight, water, workouts, measurements, medications and profile settings. Plus the technical part: a device identifier, the time of the last request and the token balance.',
      list: [
        LegalItem(
          b: 'The phone is the source of truth.',
          t: ' The server keeps a copy so that devices see the same thing',
        ),
        LegalItem(
          b: 'Photos of food are not kept.',
          t: ' A shot lives exactly as long as reading it takes, and never reaches the database',
        ),
        LegalItem(b: 'We do not collect contacts or location, and we do not read other apps'),
      ],
    ),
    LegalPart(
      h: 'If you signed in with Google',
      p: 'Signing in is not required: the diary works without it. It is there for one thing, so that entries can be brought back on a new phone.',
      list: [
        LegalItem(
          b: 'The permanent identifier of your Google account.',
          t: ' That is the key we recognise you by next time. It does not change, even if you change the email',
        ),
        LegalItem(
          b: 'The email',
          t: ', and only a verified one. It is needed so you can see which account you signed into, and so we recognise you when you write to us',
        ),
        LegalItem(
          b: 'We do not ask for your name, profile picture or contacts.',
          t: ' Google does not pass them on, because we do not ask',
        ),
      ],
      tail:
          'The email goes no further than our server: not to the model provider, not into analytics, and not into advertising, which we do not have.',
    ),
    LegalPart(
      h: 'Why we need it',
      p: 'So the diary works on several devices, so the assistant can answer a question about last week, and so tokens can be counted. There are no other reasons: we do not sell data and we do not show ads.',
    ),
    LegalPart(
      h: 'Who else sees it',
      p: 'The text of a message to the assistant and a photo of the plate are passed to the model provider for exactly as long as the answer takes. A small fixed set travels with them: how to address you, the goal, the norm and the allergies. Your name, email and phone number are not among them.',
    ),
    LegalPart(
      h: 'How long it lives',
      p: 'As long as the account exists. Deleting the account removes the entries from the server for good; the local copy goes with the app.',
    ),
    LegalPart(
      h: 'Your rights',
      list: [
        LegalItem(t: 'Get a copy of everything we store about you'),
        LegalItem(t: 'Delete the account along with everything on the server'),
        LegalItem(
          t: 'Wipe the diary and keep the account: start from a clean slate without losing the sign-in',
        ),
        LegalItem(
          t: 'Use the diary without the assistant, in which case no message goes to the server at all',
        ),
      ],
      tail: 'For any of this, writing to calvi.labs@gmail.com is enough.',
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
