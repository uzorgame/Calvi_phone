import Foundation

/// Слова годинника всіма мовами застосунку.
///
/// Мова приходить із телефона разом із токеном: та сама, якою застосунок
/// говорить, а не системна мова годинника. Таблиця тут, а не в ресурсах
/// локалізації, з тієї ж причини: системна локалізація слухала б годинник, а
/// не телефон, і англійський застосунок міг би стояти поруч з українським
/// екраном на руці.
///
/// Вісім мов, ті самі, що в `LANGS` на сервері і в `l10n/` застосунку. Мова,
/// якої тут немає, дістає англійську, як і скрізь.
struct Words {
  let say: String
  let openPhone: String
  /// «Залишилось %@»: тільки число, без норми й одиниці. Довший рядок не
  /// вміщався на екрані годинника.
  let left: String
  /// Вирок дня замість залишку: план виконаний, план перевиконаний.
  let planDone: String
  let planOver: String
  let listening: String
  let done: String
  let analysing: String
  let logged: String
  let praise: String
  let dryHead: String
  let dryBody: String
  let queuedHead: String
  let queuedBody: String
  let failHead: String
  let notHeard: String
  let phoneFar: String
  let phoneSilent: String
  /// Телефон поруч, але сам без мережі: свіжий токен узяти нема звідки.
  let phoneOffline: String
  let serverSilent: String
  let micDenied: String
  let micFailed: String
  /// Екрани «Записала» для води, ваги і тренування. «%@» це число з одиницею.
  let water: String
  let perDay: String
  let toNorm: String
  let weight: String
  let perWeek: String
  let toGoal: String
  let minutes: String
  let burned: String
  let ml: String
  let kg: String
  let gram: String
  let kcal: String
  let kj: String

  static func of(_ lang: String) -> Words {
    all[lang] ?? all["en"]!
  }

  private static let all: [String: Words] = [
    "uk": Words(
      say: "Сказати",
      openPhone: "Відкрий Calvi на телефоні",
      left: "Залишилось %@",
      planDone: "План виконаний",
      planOver: "План перевиконаний",
      listening: "Слухаю…",
      done: "Готово",
      analysing: "Аналізую",
      logged: "Записала",
      praise: "Ти гарно йдеш до цілі!",
      dryHead: "Токени скінчились",
      dryBody: "Я поки мовчу. Запис рукою в телефоні працює й далі, він безкоштовний.",
      queuedHead: "У черзі",
      queuedBody: "Немає мережі. Надішлю сама, щойно вона зʼявиться.",
      failHead: "Не вийшло",
      notHeard: "Не почула. Скажи ще раз",
      phoneFar: "Телефон далеко. Підійди до нього і скажи ще раз",
      phoneSilent: "Телефон не відповів",
      phoneOffline: "Телефон без мережі",
      serverSilent: "Сервер не відповів",
      micDenied: "Дозволь мікрофон у налаштуваннях",
      micFailed: "Мікрофон не відповів",
      water: "Вода",
      perDay: "за день %@",
      toNorm: "Ще %@ до норми",
      weight: "Вага",
      perWeek: "%@ за тиждень",
      toGoal: "До цілі %@",
      minutes: "хв",
      burned: "Спалено %@",
      ml: "мл",
      kg: "кг",
      gram: "г", kcal: "ккал", kj: "кДж"
    ),
    "en": Words(
      say: "Speak",
      openPhone: "Open Calvi on your phone",
      left: "%@ left",
      planDone: "Plan done",
      planOver: "Plan exceeded",
      listening: "Listening…",
      done: "Done",
      analysing: "Analysing",
      logged: "Logged",
      praise: "You are on track!",
      dryHead: "Out of tokens",
      dryBody: "I am quiet for now. Logging by hand on the phone still works, and it is free.",
      queuedHead: "Queued",
      queuedBody: "No network. I will send it myself as soon as it is back.",
      failHead: "Did not work",
      notHeard: "Did not catch that. Say it again",
      phoneFar: "Phone is out of reach. Move closer and say it again",
      phoneSilent: "Phone did not answer",
      phoneOffline: "The phone has no network",
      serverSilent: "Server did not answer",
      micDenied: "Allow the microphone in Settings",
      micFailed: "Microphone did not respond",
      water: "Water",
      perDay: "%@ today",
      toNorm: "%@ to go",
      weight: "Weight",
      perWeek: "%@ this week",
      toGoal: "%@ to goal",
      minutes: "min",
      burned: "Burned %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "es": Words(
      say: "Hablar",
      openPhone: "Abre Calvi en el teléfono",
      left: "Quedan %@",
      planDone: "Plan cumplido",
      planOver: "Plan superado",
      listening: "Escucho…",
      done: "Listo",
      analysing: "Analizo",
      logged: "Anotado",
      praise: "¡Vas bien hacia tu meta!",
      dryHead: "Sin tokens",
      dryBody: "Por ahora callo. Anotar a mano en el teléfono sigue funcionando, y es gratis.",
      queuedHead: "En cola",
      queuedBody: "Sin red. Lo enviaré en cuanto vuelva.",
      failHead: "No salió",
      notHeard: "No te oí. Dilo otra vez",
      phoneFar: "El teléfono está lejos. Acércate y dilo otra vez",
      phoneSilent: "El teléfono no respondió",
      phoneOffline: "El teléfono no tiene red",
      serverSilent: "El servidor no respondió",
      micDenied: "Permite el micrófono en Ajustes",
      micFailed: "El micrófono no respondió",
      water: "Agua",
      perDay: "%@ hoy",
      toNorm: "Faltan %@",
      weight: "Peso",
      perWeek: "%@ esta semana",
      toGoal: "%@ hasta la meta",
      minutes: "min",
      burned: "Quemadas %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "it": Words(
      say: "Parla",
      openPhone: "Apri Calvi sul telefono",
      left: "Restano %@",
      planDone: "Piano completato",
      planOver: "Piano superato",
      listening: "Ascolto…",
      done: "Fatto",
      analysing: "Analizzo",
      logged: "Registrato",
      praise: "Stai andando bene!",
      dryHead: "Token finiti",
      dryBody: "Per ora taccio. Registrare a mano sul telefono funziona ancora, ed è gratis.",
      queuedHead: "In coda",
      queuedBody: "Niente rete. Lo invio da sola appena torna.",
      failHead: "Non è andata",
      notHeard: "Non ho sentito. Ripeti",
      phoneFar: "Il telefono è lontano. Avvicinati e ripeti",
      phoneSilent: "Il telefono non ha risposto",
      phoneOffline: "Il telefono è senza rete",
      serverSilent: "Il server non ha risposto",
      micDenied: "Consenti il microfono nelle Impostazioni",
      micFailed: "Il microfono non ha risposto",
      water: "Acqua",
      perDay: "%@ oggi",
      toNorm: "Mancano %@",
      weight: "Peso",
      perWeek: "%@ questa settimana",
      toGoal: "%@ all’obiettivo",
      minutes: "min",
      burned: "Bruciate %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "de": Words(
      say: "Sprechen",
      openPhone: "Öffne Calvi auf dem iPhone",
      left: "Noch %@",
      planDone: "Plan erfüllt",
      planOver: "Plan übertroffen",
      listening: "Ich höre…",
      done: "Fertig",
      analysing: "Analysiere",
      logged: "Eingetragen",
      praise: "Du bist gut auf Kurs!",
      dryHead: "Keine Token mehr",
      dryBody: "Ich bin vorerst still. Von Hand eintragen am iPhone geht weiter, und das ist kostenlos.",
      queuedHead: "In der Warteschlange",
      queuedBody: "Kein Netz. Ich sende es, sobald es zurück ist.",
      failHead: "Hat nicht geklappt",
      notHeard: "Nicht verstanden. Sag es noch einmal",
      phoneFar: "Das iPhone ist außer Reichweite. Geh näher und sag es noch einmal",
      phoneSilent: "Das iPhone hat nicht geantwortet",
      phoneOffline: "Das Telefon hat kein Netz",
      serverSilent: "Der Server hat nicht geantwortet",
      micDenied: "Erlaube das Mikrofon in den Einstellungen",
      micFailed: "Das Mikrofon hat nicht reagiert",
      water: "Wasser",
      perDay: "%@ heute",
      toNorm: "Noch %@",
      weight: "Gewicht",
      perWeek: "%@ diese Woche",
      toGoal: "%@ bis zum Ziel",
      minutes: "Min.",
      burned: "Verbrannt %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "fr": Words(
      say: "Parler",
      openPhone: "Ouvre Calvi sur le téléphone",
      left: "Il reste %@",
      planDone: "Plan atteint",
      planOver: "Plan dépassé",
      listening: "Je t’écoute…",
      done: "Terminé",
      analysing: "J’analyse",
      logged: "Noté",
      praise: "Tu es sur la bonne voie !",
      dryHead: "Plus de jetons",
      dryBody: "Je me tais pour l’instant. Noter à la main sur le téléphone marche toujours, et c’est gratuit.",
      queuedHead: "En attente",
      queuedBody: "Pas de réseau. Je l’enverrai dès son retour.",
      failHead: "Ça n’a pas marché",
      notHeard: "Je n’ai pas entendu. Répète",
      phoneFar: "Le téléphone est trop loin. Rapproche-toi et répète",
      phoneSilent: "Le téléphone n’a pas répondu",
      phoneOffline: "Le téléphone n’a pas de réseau",
      serverSilent: "Le serveur n’a pas répondu",
      micDenied: "Autorise le micro dans Réglages",
      micFailed: "Le micro n’a pas répondu",
      water: "Eau",
      perDay: "%@ aujourd’hui",
      toNorm: "Encore %@",
      weight: "Poids",
      perWeek: "%@ cette semaine",
      toGoal: "%@ avant l’objectif",
      minutes: "min",
      burned: "Brûlé %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "pt": Words(
      say: "Falar",
      openPhone: "Abra o Calvi no telefone",
      left: "Restam %@",
      planDone: "Plano cumprido",
      planOver: "Plano superado",
      listening: "Ouvindo…",
      done: "Pronto",
      analysing: "Analisando",
      logged: "Registrado",
      praise: "Você está no caminho certo!",
      dryHead: "Sem tokens",
      dryBody: "Fico em silêncio por ora. Registrar à mão no telefone continua funcionando, e é grátis.",
      queuedHead: "Na fila",
      queuedBody: "Sem rede. Envio assim que voltar.",
      failHead: "Não deu",
      notHeard: "Não ouvi. Diga de novo",
      phoneFar: "O telefone está longe. Aproxime-se e diga de novo",
      phoneSilent: "O telefone não respondeu",
      phoneOffline: "O telefone está sem rede",
      serverSilent: "O servidor não respondeu",
      micDenied: "Permita o microfone nos Ajustes",
      micFailed: "O microfone não respondeu",
      water: "Água",
      perDay: "%@ hoje",
      toNorm: "Faltam %@",
      weight: "Peso",
      perWeek: "%@ nesta semana",
      toGoal: "%@ até a meta",
      minutes: "min",
      burned: "Queimadas %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
    "pl": Words(
      say: "Powiedz",
      openPhone: "Otwórz Calvi na telefonie",
      left: "Zostało %@",
      planDone: "Plan wykonany",
      planOver: "Plan przekroczony",
      listening: "Słucham…",
      done: "Gotowe",
      analysing: "Analizuję",
      logged: "Zapisane",
      praise: "Dobrze idziesz do celu!",
      dryHead: "Brak tokenów",
      dryBody: "Na razie milczę. Ręczny zapis w telefonie nadal działa i jest bezpłatny.",
      queuedHead: "W kolejce",
      queuedBody: "Brak sieci. Wyślę sama, gdy wróci.",
      failHead: "Nie udało się",
      notHeard: "Nie usłyszałam. Powtórz",
      phoneFar: "Telefon jest daleko. Podejdź bliżej i powtórz",
      phoneSilent: "Telefon nie odpowiedział",
      phoneOffline: "Telefon bez sieci",
      serverSilent: "Serwer nie odpowiedział",
      micDenied: "Zezwól na mikrofon w Ustawieniach",
      micFailed: "Mikrofon nie odpowiedział",
      water: "Woda",
      perDay: "%@ dzisiaj",
      toNorm: "Jeszcze %@",
      weight: "Waga",
      perWeek: "%@ w tym tygodniu",
      toGoal: "%@ do celu",
      minutes: "min",
      burned: "Spalone %@",
      ml: "ml",
      kg: "kg",
      gram: "g", kcal: "kcal", kj: "kJ"
    ),
  ]
}
