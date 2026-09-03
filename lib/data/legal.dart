// GENERATED FILE. Не правити руками.
//
// Джерело: Demo_Flutter_001/src/data/legal.ts
// Оновити: node tools/legal.mjs

library;

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

const _terms = LegalDoc(
  title: 'Terms of Use',
  updated: '3 September 2026',
  lede:
      'The diary is free of charge, the assistant runs on a token allowance, all nutritional figures are estimates, and Calvi is not a medical device.',
  parts: [
    LegalPart(
      h: 'Agreement to these Terms',
      p: 'These Terms of Use (the "Terms") govern access to and use of the Calvi mobile application and the services provided through it (the "Service"). By installing, accessing or using the Service, you agree to be bound by these Terms. If you do not agree to them, do not use the Service.',
    ),
    LegalPart(
      h: 'Description of the Service',
      p: 'Calvi is a self-tracking application for nutrition and body measurements. You describe in writing, dictate or photograph what you have consumed, and the Service estimates the corresponding food item together with its energy content and macronutrient composition. The Service additionally records water intake, physical activity, body measurements, allergies and medication schedules that you choose to enter.',
    ),
    LegalPart(
      h: 'No medical purpose',
      p: 'The Service is intended for general wellness and self-observation only. It is not a medical device and is not intended to diagnose, treat, cure, mitigate or prevent any disease or medical condition.',
      list: [
        LegalItem(
          b: 'Estimates rather than measurements.',
          t: ' Nutritional values are derived from your description or photograph and from public food reference databases. They are approximations and may be materially inaccurate.',
        ),
        LegalItem(
          b: 'No clinical advice.',
          t: ' The assistant does not provide medical, nutritional or pharmaceutical advice, and does not substitute for consultation with a qualified healthcare professional.',
        ),
        LegalItem(
          b: 'Medication entries constitute a record only.',
          t: ' The Service does not prescribe medication, calculate dosages, or recommend changes to any treatment regimen.',
        ),
        LegalItem(
          b: 'Allergen indications are not exhaustive.',
          t: ' Allergen matching is performed against public product data and against the description you provide, and may be incomplete or incorrect. You remain responsible for verifying ingredients yourself.',
        ),
      ],
      tail:
          'Consult a qualified healthcare professional before making changes to your diet, and in particular if you are pregnant or breastfeeding, or if you have diabetes, kidney or liver disease, a history of disordered eating, or take medication on an ongoing basis. In a medical emergency, contact your local emergency services; do not rely on the Service.',
    ),
    LegalPart(
      h: 'Eligibility',
      p: 'The Service is available to individuals aged 13 years or over. By using the Service you represent that you meet this requirement. Accounts are not knowingly created or maintained for persons under 13, and any account identified as belonging to such a person will be deleted.',
      tail:
          'Where the law of your country sets a higher minimum age for consenting to online services on your own, that higher age applies to you, and below it the Service may only be used with the consent of a parent or guardian. Calorie tracking and weight management carry particular risks in adolescence, and the Service is not a substitute for the supervision of a physician.',
    ),
    LegalPart(
      h: 'Your account',
      list: [
        LegalItem(
          b: 'Automatic creation.',
          t: ' An account is created at first launch without an email address or registration step, so that the Service is usable immediately.',
        ),
        LegalItem(
          b: 'Optional sign-in.',
          t: ' Signing in with Google or Apple links that same account to your identity provider, so that it can be restored on another device.',
        ),
        LegalItem(
          b: 'Single user per account.',
          t: ' An account is intended for one individual. All entries are interpreted as relating to the same person.',
        ),
        LegalItem(
          b: 'Accounts without sign-in cannot be recovered.',
          t: ' If you do not sign in, the account exists only on that device and cannot be restored if the device is lost or reset.',
        ),
        LegalItem(
          b: 'Responsibility.',
          t: ' You are responsible for all activity conducted through your account.',
        ),
      ],
      tail:
          'You may delete your account at any time from within the Service. The consequences of deletion are described in the Privacy Policy.',
    ),
    LegalPart(
      h: 'Charges and the assistant allowance',
      p: 'The diary is provided free of charge and without any limit on the number of entries.',
      list: [
        LegalItem(
          b: 'Token allowance.',
          t: ' Use of the assistant consumes tokens. Tokens are granted on registration and replenished periodically at no cost.',
        ),
        LegalItem(
          b: 'Exhaustion of the allowance.',
          t: ' When the allowance is exhausted, the assistant becomes unavailable until the next grant. The diary continues to operate without restriction.',
        ),
        LegalItem(
          b: 'Paid plans.',
          t: ' Where a paid plan is offered, it is purchased and billed through the Apple App Store or Google Play, and the terms of the relevant store govern payment, renewal, cancellation and refunds.',
        ),
      ],
      tail:
          'Prices and the composition of any paid plan may change. Such changes do not apply to a subscription period already paid for.',
    ),
    LegalPart(
      h: 'Acceptable use',
      p: 'You agree that you will not:',
      list: [
        LegalItem(t: 'enter health information or photographs relating to another person;'),
        LegalItem(
          t: 'seek a diagnosis, prescription or dosage from the assistant, or rely upon its output as though it constituted one;',
        ),
        LegalItem(
          t: 'place an unreasonable load on the Service, or circumvent or attempt to circumvent the token allowance;',
        ),
        LegalItem(
          t: 'decompile or reverse engineer the application, or access the server other than through the application as provided;',
        ),
        LegalItem(
          t: 'use the Service unlawfully or in a manner that infringes the rights of others.',
        ),
      ],
      tail: 'Access to an account in breach of this section may be suspended or terminated.',
    ),
    LegalPart(
      h: 'Your content',
      p: 'You retain all rights in the information you enter. No ownership of it is claimed, and it is not sold to any third party.',
      tail:
          'You grant a limited licence to store your entries, display them to you, synchronise them between your devices, and transmit content you address to the assistant to the model provider that processes it. That licence exists solely to operate the Service and ends when you delete your account. Your content is not used to train our own models.',
    ),
    LegalPart(
      h: 'Intellectual property',
      p: 'The application, its interface, the design of the assistant and all associated materials remain the property of the operator or its licensors. These Terms grant you a personal, non-exclusive, non-transferable and revocable licence to use the Service, and transfer no intellectual property rights to you.',
    ),
    LegalPart(
      h: 'Third-party services',
      p: 'The Service depends on third parties, including a model provider that processes assistant requests, identity providers used for optional sign-in, and public food reference databases. Their availability, accuracy and continuity are outside the operator’s control, and their own terms govern their respective services.',
    ),
    LegalPart(
      h: 'Availability and modification of the Service',
      p: 'Any part of the Service may be modified, suspended or discontinued. Where a change materially reduces functionality on which you rely, notice will be given in the application where reasonably practicable. Uninterrupted or error-free operation is not guaranteed.',
    ),
    LegalPart(
      h: 'Disclaimer of warranties',
      p: 'To the fullest extent permitted by applicable law, the Service is provided on an "as is" and "as available" basis, without warranties of any kind, whether express, implied or statutory, including any implied warranties of merchantability, fitness for a particular purpose, accuracy or non-infringement. No warranty is given that nutritional estimates are accurate or that the Service will operate without interruption.',
    ),
    LegalPart(
      h: 'Limitation of liability',
      p: 'To the fullest extent permitted by applicable law, the operator shall not be liable for any indirect, incidental, special, consequential or punitive damages, nor for any loss of data, profits, revenue or goodwill, arising out of or in connection with the use of or inability to use the Service.',
      tail:
          'Nothing in these Terms excludes or limits liability for death or personal injury caused by negligence, for fraud or fraudulent misrepresentation, or for any other liability that cannot lawfully be excluded or limited.',
    ),
    LegalPart(
      h: 'Consumer rights',
      p: 'If you use the Service as a consumer, nothing in these Terms affects the mandatory rights available to you under the law of your country of residence, including your right to bring proceedings before the courts of that country.',
    ),
    LegalPart(
      h: 'Amendments to these Terms',
      p: 'These Terms may be amended. The date of the current revision appears at the head of this document, and material amendments will be notified within the application before they take effect. Continued use of the Service after the effective date constitutes acceptance of the amended Terms. If you do not accept a revised version, you may delete your account.',
    ),
    LegalPart(
      h: 'Contact and dispute resolution',
      p: 'Enquiries and complaints concerning these Terms may be addressed to calvi.labs@gmail.com.',
      tail:
          'The parties shall attempt in good faith to resolve any dispute arising out of these Terms by correspondence before commencing formal proceedings.',
    ),
  ],
);

const _privacy = LegalDoc(
  title: 'Privacy Policy',
  updated: '3 September 2026',
  lede:
      'Only the data the diary requires is collected, health data is processed on the basis of your explicit consent, photographs and conversations are not kept on our servers, and no personal data is sold or used for advertising.',
  parts: [
    LegalPart(
      h: 'Controller and contact details',
      p: 'This Privacy Policy describes how personal data is processed in connection with the Calvi application and the services provided through it. The controller of that data is Mykhailo Nahreba, who may be contacted at calvi.labs@gmail.com.',
    ),
    LegalPart(
      h: 'Categories of data processed',
      list: [
        LegalItem(
          b: 'Account data.',
          t: ' An identifier generated at first launch and, where you choose to sign in, the email address supplied by Google or Apple together with the identifier that provider uses for you. Your time zone and interface language are stored so that days and reminders fall where you are. Each signed-in session is recorded as a hashed credential with the times at which it was created and last used.',
        ),
        LegalItem(
          b: 'Profile data.',
          t: ' Sex, year of birth, height, starting and target weight, the direction and pace of your goal, activity level, daily energy and macronutrient targets, water target, preferred form of address, interface theme, and the body measurements you have chosen to track.',
        ),
        LegalItem(
          b: 'Diary data.',
          t: ' Meals with their descriptions, weights and nutritional values, the time and category of each entry, water intake, weigh-ins, body measurements and recorded physical activity. Where an entry is waiting for a weight you have not yet stated, the words you used to describe the dish are held until the entry is completed or discarded.',
        ),
        LegalItem(
          b: 'Health data.',
          t: ' Allergies you select and whether you have marked them as severe; medications with their form, dose, schedule and course dates, and the doses you record as taken.',
        ),
        LegalItem(
          b: 'Assistant data.',
          t: ' The notes the assistant retains about you, which you can read and delete within the application, and the weekly reviews it has produced at your request.',
        ),
        LegalItem(
          b: 'Recipes.',
          t: ' Recipes saved to your account, whether composed by the assistant or entered by you.',
        ),
        LegalItem(
          b: 'Nutritional corrections.',
          t: ' Where you correct the energy or macronutrients of a dish, or state the weight of a portion you use often, that correction is stored against your account so that it applies the next time the same dish is recorded.',
        ),
        LegalItem(
          b: 'Allowance data.',
          t: ' Your token balance and a record of grants and expenditure, and, where you hold a subscription, the period for which paid access applies.',
        ),
        LegalItem(
          b: 'Technical data.',
          t: ' Server request logs containing the time of the request, the endpoint addressed, the response status and the originating IP address. Request bodies are not written to the logs, and authorisation credentials are excluded from them.',
        ),
      ],
      tail:
          'The application contains no advertising and uses no advertising identifiers, and no third-party analytics or crash-reporting component is embedded in it. Reminders are raised by your own device, so no push notification identifier is created or held.',
    ),
    LegalPart(
      h: 'What is not retained',
      list: [
        LegalItem(
          b: 'Photographs.',
          t: ' A photograph submitted for analysis is transmitted for processing and discarded once a reply has been produced. It is not written to the database and not saved to disk.',
        ),
        LegalItem(
          b: 'Conversations.',
          t: ' The text of your conversations with the assistant is held on your device. Each request carries the recent part of the conversation with it so that a reply can be produced in context, and that content is not retained on the server afterwards. What persists is only the notes described above, which you can read and delete.',
        ),
        LegalItem(
          b: 'Audio.',
          t: ' Dictation is performed by the speech recognition built into your device, which returns text. Audio is never transmitted to us. That recognition is governed by the terms of your device operating system.',
        ),
      ],
    ),
    LegalPart(
      h: 'Purposes and legal bases of processing',
      list: [
        LegalItem(
          b: 'Provision of the Service, Article 6(1)(b) GDPR.',
          t: ' Storing your entries, displaying them to you, synchronising them between your devices, and producing the calculations shown in the application. This processing is necessary to perform the contract constituted by the Terms of Use.',
        ),
        LegalItem(
          b: 'Operation of the assistant, Article 6(1)(b) GDPR.',
          t: ' Transmitting the content you address to the assistant, together with the profile context required to answer it, so that a reply can be generated.',
        ),
        LegalItem(
          b: 'Administration of paid access, Article 6(1)(b) GDPR.',
          t: ' Recording that a subscription is active and for what period, so that the allowance limits do not apply to you.',
        ),
        LegalItem(
          b: 'Security and reliability, Article 6(1)(f) GDPR.',
          t: ' Retaining short-lived server logs and counting requests in aggregate in order to detect faults and abuse. The legitimate interest pursued is the secure and continuous operation of the Service.',
        ),
        LegalItem(
          b: 'Health data, Article 9(2)(a) GDPR.',
          t: ' Allergies and medication records are processed solely on the basis of your explicit consent, given by entering them. Consent may be withdrawn at any time by deleting those entries or your account.',
        ),
      ],
    ),
    LegalPart(
      h: 'Processing by the assistant',
      p: 'When you write to the assistant or submit a photograph, that content is transmitted to Google for processing by its Gemini models, together with the context required to produce a reply. That context comprises your daily targets, the allergies you have recorded, the notes the assistant retains, and the recent part of the conversation sent by your device.',
      tail:
          'The provider processes that content in order to return a reply, under the terms of the service tier through which the request is made, and those terms determine whether it may also be used to improve the services of that provider. No models are operated or trained by us. You should not submit information relating to other people to the assistant.',
    ),
    LegalPart(
      h: 'Recipients and processors',
      list: [
        LegalItem(
          b: 'Google.',
          t: ' Processes assistant messages and submitted photographs through its Gemini models.',
        ),
        LegalItem(
          b: 'Google and Apple.',
          t: ' Only where you choose to sign in, and only for the purpose of verifying your identity and supplying the email address associated with that account.',
        ),
        LegalItem(
          b: 'Apple and Google as store operators.',
          t: ' Where you purchase a subscription, the transaction is concluded with the store from which the application was obtained.',
        ),
        LegalItem(
          b: 'Hosting provider.',
          t: ' Operates the infrastructure on which the server and database run.',
        ),
        LegalItem(
          b: 'Public food reference databases.',
          t: ' Open Food Facts and USDA FoodData Central are queried for product information. A barcode or a search term is transmitted; your identity is not.',
        ),
      ],
      tail: 'Personal data is not sold and is not disclosed for advertising purposes.',
    ),
    LegalPart(
      h: 'Subscriptions and payment',
      p: 'Subscriptions are purchased through the store from which the application was obtained, and payment is handled entirely by that store. No card number, billing address or other payment detail is received or stored by us. What is recorded against your account is the period for which paid access applies.',
    ),
    LegalPart(
      h: 'Aggregate data',
      p: 'Counts of requests are kept in aggregate by hour, endpoint and response status, together with product barcodes that no reference database was able to name. These records carry no account identifier and cannot be attributed to a person. They are used to keep the Service running and to decide which products to describe next.',
    ),
    LegalPart(
      h: 'International transfers',
      p: 'Processing may take place outside your country of residence. Where personal data is transferred outside the European Economic Area, that transfer is made subject to the safeguards permitted by applicable data protection law, including standard contractual clauses concluded with the relevant processor.',
    ),
    LegalPart(
      h: 'Retention',
      list: [
        LegalItem(
          b: 'For the duration of the account.',
          t: ' Profile, diary, health, assistant and recipe data are retained until you delete them individually or delete your account.',
        ),
        LegalItem(
          b: 'Upon a deletion request.',
          t: ' When you ask to delete your account from the settings, all data held on your device is removed immediately and your sessions are ended. On the server the account is marked for deletion and placed in a queue; its records are neither used nor shown while it waits. Signing in with the same account before the deletion is carried out cancels the request and restores the account together with its data; a new request is then needed to delete it.',
        ),
        LegalItem(
          b: 'Upon deletion.',
          t: ' Deletion is carried out by us after the request is reviewed, within 30 business days of the request. All records associated with the account are then removed from the operational database: the account itself, sign-in identifiers, sessions, the diary, body measurements, workouts, medications, the assistant conversation and its notes, recipes and the assistant allowance. Residual copies held in system backups are overwritten in the ordinary course of their rotation.',
        ),
        LegalItem(
          b: 'Server logs.',
          t: ' Retained for a short operational period and then discarded.',
        ),
        LegalItem(
          b: 'Aggregate records.',
          t: ' Kept without limitation of time, as they contain no personal data and deletion of an account does not make them attributable.',
        ),
      ],
    ),
    LegalPart(
      h: 'Your rights',
      p: 'Where the General Data Protection Regulation applies to you, you have the right to obtain confirmation as to whether your personal data is processed and to receive a copy of it; to have inaccurate data rectified; to have your data erased; to restrict or object to processing; to receive your data in a structured, commonly used and machine-readable format; to withdraw consent at any time without affecting the lawfulness of processing carried out beforehand; and to lodge a complaint with your national supervisory authority.',
      tail:
          'Most of these rights may be exercised directly within the application: entries can be edited or deleted individually, the notes the assistant retains can be read and removed, and the deletion of the account together with all associated data can be requested from the settings, as described under Retention. For any other request, write to calvi.labs@gmail.com.',
    ),
    LegalPart(
      h: 'Security',
      p: 'Data is transmitted over encrypted connections and stored on access-controlled infrastructure. Session credentials are stored as hashes rather than in their original form, and authorisation headers are excluded from server logs. No system is entirely secure, and absolute security cannot be guaranteed.',
    ),
    LegalPart(
      h: 'Children',
      p: 'The Service is not directed to persons under 13 years of age, and their personal data is not knowingly processed. Any account identified as belonging to such a person will be deleted.',
      tail:
          'Where the law of your country sets a higher age at which a person may consent to the processing of their personal data, processing below that age is carried out only with the consent of a parent or guardian, who may exercise the rights set out below on behalf of the person concerned by writing to calvi.labs@gmail.com.',
    ),
    LegalPart(
      h: 'Amendments to this Policy',
      p: 'This Policy may be updated. The date of the current revision appears at the head of this document, and material amendments will be notified within the application before they take effect.',
    ),
    LegalPart(
      h: 'Contact',
      p: 'Enquiries and requests concerning personal data may be addressed to calvi.labs@gmail.com.',
    ),
  ],
);

/* Одна редакція, англійською, незалежно від мови інтерфейсу.
 *
 * Дві мовні редакції розходяться першою ж правкою, після якої англійська
 * обіцяє не те, що українська, і жодна з них уже не є документом. Юридичний
 * текст читають цілим, тому він тут один. */
const LegalDoc terms = _terms;

const LegalDoc privacy = _privacy;
