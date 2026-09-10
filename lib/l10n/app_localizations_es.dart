// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get aboutContact => 'Contacto';

  @override
  String get aboutDeveloper => 'Desarrollador';

  @override
  String get aboutText =>
      'Un diario de comidas que entiende frases normales. Nora hace las cuentas, las decisiones siguen siendo tuyas.';

  @override
  String get aboutTitle => 'Acerca de la app';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutWrite => 'Escríbenos';

  @override
  String get accessAsk => 'aún no se ha pedido';

  @override
  String get accessCamera => 'Cámara';

  @override
  String get accessMic => 'Micrófono';

  @override
  String get accessNote =>
      'El micrófono y el reconocimiento de voz hacen falta para dictar, y el reconocimiento también para el reloj: él graba lo que dices y el teléfono lo convierte en palabras. Toca una fila para conceder el acceso o abrir los ajustes del sistema y desactivarlo.';

  @override
  String get accessNotify => 'Notificaciones';

  @override
  String get accessOff => 'denegado';

  @override
  String get accessOn => 'permitido';

  @override
  String get accessSpeech => 'Reconocimiento de voz';

  @override
  String get accountBusy => 'Entrando…';

  @override
  String get accountGoogle => 'Continuar con Google';

  @override
  String get accountKeepCloud => 'El de la cuenta';

  @override
  String get accountNoAccountNote =>
      'El diario vive solo en este teléfono. Cambia de teléfono o quita la app y no habrá con qué recuperar los registros: no sabemos de quién son.';

  @override
  String get accountScopeNote =>
      'Pedimos solo el correo. Google no nos pasa el nombre, la foto de perfil ni los contactos.';

  @override
  String get accountSettingsDevice => 'ajustes';

  @override
  String get accountSignInFailed => 'No se pudo iniciar sesión.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'No se pudo iniciar sesión. $why';
  }

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutAction => 'Cerrar sesión';

  @override
  String get accountSignOutAsk => '¿Cerrar sesión?';

  @override
  String get accountSignOutBack =>
      'Vuelve a iniciar sesión con la misma cuenta y regresa todo. Lo escrito sin conexión que aún no haya llegado al servidor no se puede recuperar.';

  @override
  String get accountSignOutNote =>
      'Este teléfono se limpia: se van el diario, el perfil, los medicamentos y la conversación con Nora. Tus registros siguen en el servidor, bajo tu cuenta.';

  @override
  String get accountSince => 'En Calvi desde';

  @override
  String get accountTitle => 'Cuenta';

  @override
  String get accountVia => 'Sesión iniciada con Google';

  @override
  String get accountViaApple => 'Sesión iniciada con Apple';

  @override
  String get accountViaEmail => 'Sesión iniciada con correo';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => '¿Con qué diario nos quedamos?';

  @override
  String get accountWhichDiaryNote =>
      'Esta cuenta ya tiene registros, y el teléfono también. Solo puede quedarse uno: el de la cuenta o el del teléfono. El otro se va.';

  @override
  String get actBasketball => 'Baloncesto';

  @override
  String get actBike => 'Ciclismo';

  @override
  String get actDance => 'Baile';

  @override
  String get actFootball => 'Fútbol';

  @override
  String get actGym => 'Gimnasio';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Salto de cuerda';

  @override
  String get actRun => 'Correr';

  @override
  String get actSki => 'Esquí';

  @override
  String get actStretch => 'Estiramientos';

  @override
  String get actSwim => 'Natación';

  @override
  String get actTennis => 'Tenis';

  @override
  String get actWalk => 'Caminar';

  @override
  String get actYoga => 'Yoga';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionSave => 'Guardar';

  @override
  String get activityHigh => 'Alto';

  @override
  String get activityHighHint => '5-6 entrenamientos';

  @override
  String get activityLight => 'Poco activo';

  @override
  String get activityLightHint => '1-2 entrenamientos por semana';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityModerateHint => '3-4 entrenamientos';

  @override
  String get activitySedentary => 'Sedentario';

  @override
  String get activitySedentaryHint => 'casi sin movimiento';

  @override
  String get activityVeryHigh => 'Muy alto';

  @override
  String get activityVeryHighHint => 'trabajo físico o deporte a diario';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'hoy';

  @override
  String get agoWeek => 'hace una semana';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'hace $count semanas');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'ayer';

  @override
  String get allergyConfirm => 'Confirmar';

  @override
  String get allergyMild => 'Leve';

  @override
  String get allergyMildHint => 'Te aviso en el texto, sin bloquear el registro.';

  @override
  String get allergyMildShort => 'leve';

  @override
  String get allergyNote =>
      'Si la composición de un producto no está en la base, no me callo ni doy por seguro que no pasa nada: te digo aparte que la composición se desconoce.';

  @override
  String get allergyNothing =>
      'No se encontró nada. Si el alérgeno no está en la lista, díselo a Nora: lo añadiremos a la referencia para que funcione para todos, en vez de quedarse como texto para una sola persona.';

  @override
  String get allergyRemove => 'Quitar';

  @override
  String allergySearch(int count) {
    return 'Buscar entre $count alérgenos';
  }

  @override
  String get allergySevere => 'Grave';

  @override
  String get allergySevereHint => 'Me paro antes de registrarlo y te lo digo claro.';

  @override
  String get allergySevereShort => 'grave';

  @override
  String get allergyTitle => 'Alergias';

  @override
  String anChartGoal(String value) {
    return 'objetivo $value';
  }

  @override
  String get anDaysInNorm => 'días dentro del objetivo';

  @override
  String anDonePercent(int percent) {
    return '$percent% hecho';
  }

  @override
  String anEtaHead(String date) {
    return 'A este ritmo llegarás al objetivo hacia *$date*';
  }

  @override
  String get anForMonth => 'durante el mes';

  @override
  String get anForQuarter => 'durante 3 meses';

  @override
  String get anForYear => 'durante el año';

  @override
  String get anGoalProgress => 'Avance hacia el objetivo';

  @override
  String get anKcal => 'Calorías';

  @override
  String get anKcalAvg => 'de media al día';

  @override
  String get anKcalEmpty =>
      'Todavía no hay nada registrado en este periodo. Dile a Nora qué comiste y el gráfico se construye solo.';

  @override
  String anKcalTotal(Object u) {
    return 'en el periodo, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'norma $grams';
  }

  @override
  String get anMacrosAvg => 'Macros de media';

  @override
  String get anMacrosEmpty =>
      'La media aparece en cuanto hay algo que promediar: registra al menos un día.';

  @override
  String get anMeasures => 'Medidas';

  @override
  String anMeasuresChange(String period) {
    return 'cambio $period';
  }

  @override
  String get anMeasuresEmpty => 'Todavía no hay medidas.';

  @override
  String get anMeasuresEmptyHint => 'Mídete una vez al mes y te enseño qué se mueve';

  @override
  String get anMonth => 'Mes';

  @override
  String get anNow => 'ahora';

  @override
  String anNowKg(Object u) {
    return 'ahora, $u';
  }

  @override
  String get anOneReading => 'una medición';

  @override
  String get anOneWeighing =>
      'De momento solo hay una medición. La segunda marca la dirección, y la línea empieza ahí.';

  @override
  String get anPerDay => 'al día';

  @override
  String get anQuarter => '3 meses';

  @override
  String anShareOfNorm(int share) {
    return '$share% de la norma';
  }

  @override
  String anStartKg(Object u) {
    return 'inicio, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'objetivo, $u';
  }

  @override
  String get anTitle => 'Analítica';

  @override
  String get anWater => 'Hidratación';

  @override
  String anWaterAvg(Object u) {
    return 'de media, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'norma $ml';
  }

  @override
  String get anWeek => 'Semana';

  @override
  String get anWeightEmpty =>
      'La curva aparece con el segundo pesaje. Dile tu peso a Nora y ella lo anota.';

  @override
  String get anYear => 'Año';

  @override
  String get assistantAddMemory => 'Añadir a la memoria';

  @override
  String get assistantCollapse => 'Plegar';

  @override
  String get assistantExample => 'Por ejemplo, no como setas';

  @override
  String get assistantForget => 'Olvidar';

  @override
  String assistantHint(String name) {
    return '$name lleva el diario contigo y recuerda lo que le contaste sobre ti.';
  }

  @override
  String get assistantMemory => 'Memoria';

  @override
  String get assistantMemoryEmpty => 'Todavía no hay nada recordado.';

  @override
  String get assistantMemoryEmptyHint =>
      'La memoria sale de las conversaciones, o añade una a mano';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned fijadas';
  }

  @override
  String get assistantTitle => 'Asistente';

  @override
  String get assistantWhatToRemember => 'Qué recordar';

  @override
  String get authAgain => 'Confirmar contraseña';

  @override
  String get authAgainDiffers => 'Las contraseñas no coinciden';

  @override
  String get authAgainEmpty => 'Repite la contraseña';

  @override
  String get authAgainHint => 'otra vez';

  @override
  String authAgainIn(int sec) {
    return 'Puedes pedirlo otra vez en $sec s';
  }

  @override
  String get authCode => 'Código del correo';

  @override
  String get authCodeAction => 'Confirmar';

  @override
  String get authCodeBad => 'El código no coincide o ya caducó';

  @override
  String authCodeHint(String mail) {
    return 'Enviamos un código a $mail. Escribe los seis dígitos del correo.';
  }

  @override
  String get authCodeShort => 'El código tiene 6 dígitos';

  @override
  String get authCodeTitle => 'Confirma tu correo';

  @override
  String get authForgotAction => 'Enviar código';

  @override
  String get authForgotHint =>
      'Enviaremos un código a tu correo y luego eliges una nueva contraseña.';

  @override
  String get authForgotLink => '¿Olvidaste?';

  @override
  String get authForgotTitle => 'Nueva contraseña';

  @override
  String get authMail => 'Correo';

  @override
  String get authMailBad => 'Esa dirección parece incorrecta';

  @override
  String get authOr => 'o';

  @override
  String get authPass => 'Contraseña';

  @override
  String get authPassEmpty => 'Escribe tu contraseña';

  @override
  String get authPassHint => '5 letras y un signo';

  @override
  String get authPassNew => 'Nueva contraseña';

  @override
  String get authPassWeak => 'Contraseña débil: al menos 5 letras y un dígito o signo';

  @override
  String get authResetAction => 'Guardar contraseña';

  @override
  String get authSendAgain => 'Enviar de nuevo';

  @override
  String get authSignInAction => 'Entrar';

  @override
  String get authSignInTitle => 'Iniciar sesión';

  @override
  String get authSignUpAction => 'Crear cuenta';

  @override
  String get authSignUpLink => 'Registrarse';

  @override
  String get authSignUpTitle => 'Creemos una cuenta';

  @override
  String get barCamera => 'Cámara';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Hola, soy Nora. Escribe o habla como siempre, te entenderé.';

  @override
  String get barHintBorscht => 'Lentejas 300 g para el almuerzo';

  @override
  String get barHintDelete => 'Borra el último registro';

  @override
  String get barHintEggs => 'Dos huevos y una tostada';

  @override
  String get barHintMore =>
      '«dos huevos y una tostada», «bebí 300 de agua», «corrí 40 minutos»: lo interpreto y lo pongo en la tarjeta que toca';

  @override
  String get barHintProtein => '¿Cuánta proteína me queda?';

  @override
  String get barHintRun => 'Corrí 40 minutos';

  @override
  String get barHintWater => 'Bebí 500 ml de agua';

  @override
  String get barHintWeighed => 'Peso: 78,8';

  @override
  String get barHintYesterday => '¿Qué comí ayer?';

  @override
  String get barLogsInto => 'Registrando en ';

  @override
  String get barMic => 'Micrófono';

  @override
  String get barSend => 'Enviar';

  @override
  String get camAgain => 'Otra vez';

  @override
  String get camAllergen => '¡Alérgeno!';

  @override
  String camAllergyContains(String list) {
    return 'Contiene tu alérgeno: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Puede contener trazas de: $list';
  }

  @override
  String get camAskNoraInstead => 'Sin etiqueta, pregúntale a Nora';

  @override
  String get camBarcode => 'Código de barras';

  @override
  String get camBusy => 'La cámara no se abrió. Normalmente la está ocupando otra app.';

  @override
  String get camCouldNotRead => 'No se pudo leer la foto';

  @override
  String get camDish => 'Foto';

  @override
  String camEstimate(Object u) {
    return ' $u, estimado';
  }

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Cifras del envase. Registrarlo no cuesta tokens.';

  @override
  String get camGallery => 'De la galería';

  @override
  String get camGapNote => 'Ninguna base conoce esta cifra. Fotografía la etiqueta y la relleno.';

  @override
  String get camHintBarcode => 'el código dentro del marco';

  @override
  String get camHintDish => 'apunta a un plato o a un paquete';

  @override
  String camIngredients(String text) {
    return 'Ingredientes: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'en $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u en $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u por $grams';
  }

  @override
  String get camLabelAim => 'apunta a la tabla nutricional';

  @override
  String get camLabelNoShot => 'La foto no salió. Prueba a fotografiar la etiqueta otra vez.';

  @override
  String get camLabelReading => 'Copiando las cifras del paquete…';

  @override
  String camLogInto(String slotInto) {
    return 'Registrarlo $slotInto';
  }

  @override
  String get camNoPermission => 'Sin permiso de cámara. Puedes darlo en los ajustes del teléfono.';

  @override
  String get camNoScanner => 'Este teléfono no puede leer códigos con la cámara.';

  @override
  String get camNoTokens => 'Sin tokens';

  @override
  String get camNotAProduct => 'Eso no es un código de producto';

  @override
  String get camNotAProductNote =>
      'Se ha leído un enlace o un código interno. Apunta a las barras que llevan dígitos debajo.';

  @override
  String get camNotRead => 'No se pudo distinguir';

  @override
  String get camOffline =>
      'El código se ha leído, pero no hay a quién preguntar. Inténtalo cuando vuelvas a tener red.';

  @override
  String get camOfflineShot => 'Sin conexión. Puedes enviarle la foto a Nora más tarde';

  @override
  String get camOfflineTitle => 'Sin red';

  @override
  String get camPer100 => 'El envase no da un peso exacto: las cifras son por 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Ración del envase: $g. Las cifras son por ración.';
  }

  @override
  String get camReading => 'Leyendo…';

  @override
  String get camSendToNora => 'Enviar a Nora';

  @override
  String get camServerDown => 'No es cosa del código ni de la cámara. Prueba dentro de un minuto.';

  @override
  String get camServerDownTitle => 'Nuestro servidor no respondió';

  @override
  String get camShoot => 'Hacer una foto';

  @override
  String get camShootLabel => 'Fotografiar la etiqueta';

  @override
  String get camShotFailed => 'La foto no salió';

  @override
  String get camShotReady => 'La foto está lista';

  @override
  String get camShotReadyNote =>
      'Nora la leerá y responderá en el chat: dirá qué plato es, estimará la ración y mostrará de dónde sale la cifra. Cuesta dos tokens.';

  @override
  String get camSignedOut =>
      'La sesión ya no vale, así que la base no nos reconoce. Inicia sesión otra vez y el escáner funcionará.';

  @override
  String get camSignedOutTitle => 'Vuelve a iniciar sesión';

  @override
  String get camSlow => 'El código se ha leído y la base tardó demasiado. Inténtalo otra vez.';

  @override
  String get camSlowTitle => 'La respuesta no llegó';

  @override
  String get camStillWorks => 'Las fotos de comida y la galería funcionan como siempre.';

  @override
  String get camTitle => 'Escáner';

  @override
  String get camTookTooLong => 'Tardó demasiado en leerse. Inténtalo otra vez';

  @override
  String get camUnknownCode => 'Este producto no está en ninguna base';

  @override
  String get camUnknownCodeNote =>
      'Ni en la nuestra ni en la abierta. Fotografía la tabla nutricional del paquete y copio las cifras de ahí. Es gratis.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Este teléfono se limpia en el acto: el diario, el perfil, la conversación con Nora y la sesión. La app vuelve a la primera pantalla.';

  @override
  String get deleteAskBody2 =>
      'En el servidor la cuenta queda en cola para su eliminación definitiva, que tarda hasta 30 días hábiles. Hasta que lo confirmemos, iniciar sesión con la misma cuenta lo devuelve todo y anula la solicitud.';

  @override
  String get deleteAskCta => 'Sí, eliminar';

  @override
  String get deleteAskTitle => '¿Eliminar la cuenta?';

  @override
  String get deleteConfirm =>
      'Entiendo que los datos se eliminarán para siempre y no se podrán recuperar.';

  @override
  String get deleteDays => 'Días con Calvi';

  @override
  String get deleteEntries => 'Registros en el diario';

  @override
  String deleteFailed(String why) {
    return 'No se pudo eliminar: $why';
  }

  @override
  String get deleteForever => 'Eliminar para siempre';

  @override
  String get deleteNote =>
      'Se va todo: el diario, el peso, las medidas, las alergias, los medicamentos y el historial de conversación. No hay vuelta atrás.';

  @override
  String get deleteProManage => 'Gestionar la suscripción';

  @override
  String deleteProNote(String store) {
    return 'Eliminar la cuenta no cancela Calvi Pro. $store seguirá cobrando hasta que se cancele la propia suscripción, así que cancélala antes de eliminar la cuenta.';
  }

  @override
  String get deleteProStoreAny => 'La tienda';

  @override
  String get deleteSubNote =>
      'Si la cosa va por la suscripción, se puede cancelar aparte en la App Store o en Google Play, sin eliminar la cuenta.';

  @override
  String get deleteTitle => 'Eliminar la cuenta';

  @override
  String get deleteWeighings => 'Mediciones de peso';

  @override
  String get dictationBusy => 'El micrófono está ocupado. Inténtalo otra vez';

  @override
  String get dictationFailed => 'El dictado no funcionó';

  @override
  String get dictationNoMatch => 'No he oído nada que pudiera entender';

  @override
  String get dictationNoNetwork => 'El reconocimiento necesita red';

  @override
  String get dictationNoPermission => 'Sin permiso de micrófono';

  @override
  String get dictationSilence => 'Silencio. Inténtalo otra vez, más cerca del micrófono';

  @override
  String get dictationUnavailable => 'El dictado no está disponible en este teléfono';

  @override
  String get doseCapFew => 'cápsulas';

  @override
  String get doseCapMany => 'cápsulas';

  @override
  String get doseCapOne => 'cápsula';

  @override
  String get doseDropFew => 'gotas';

  @override
  String get doseDropMany => 'gotas';

  @override
  String get doseDropOne => 'gota';

  @override
  String get doseMlFew => 'ml';

  @override
  String get doseMlMany => 'ml';

  @override
  String get doseMlOne => 'ml';

  @override
  String get doseShotFew => 'inyecciones';

  @override
  String get doseShotMany => 'inyecciones';

  @override
  String get doseShotOne => 'inyección';

  @override
  String get doseTabFew => 'comprimidos';

  @override
  String get doseTabMany => 'comprimidos';

  @override
  String get doseTabOne => 'comprimido';

  @override
  String entries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
      zero: '0 registros',
    );
    return '$_temp0';
  }

  @override
  String get eraseAskBody1 =>
      'Se va el diario entero, de todo el tiempo: comidas, agua, peso, medidas, entrenamientos, medicamentos y la conversación con Nora. En todos los dispositivos, porque la copia del servidor también se borra.';

  @override
  String get eraseAskBody2 =>
      'Lo que se queda: la cuenta, la sesión, los tokens con su saldo y los ajustes del perfil. Esto no es cerrar sesión, es empezar de cero dentro de la misma cuenta.';

  @override
  String get eraseAskCta => 'Eliminar todo';

  @override
  String get eraseAskTitle => '¿Eliminar todos los registros?';

  @override
  String get eraseDataTitle => 'Eliminar los datos';

  @override
  String get eraseDone => 'El diario está borrado. Borrón y cuenta nueva.';

  @override
  String eraseFailed(String why) {
    return 'No se pudo borrar: $why';
  }

  @override
  String get eraseNoNet => 'sin red. Enciende internet e inténtalo otra vez';

  @override
  String get eraseSlow => 'el servidor tarda demasiado. Prueba dentro de un minuto';

  @override
  String get eraseSureBody =>
      'Esto no se puede deshacer. El diario desaparece para siempre, y no podremos recuperarlo ni tú ni nosotros.';

  @override
  String get eraseSureCta => 'Sí, eliminar para siempre';

  @override
  String get eraseSureTitle => '¿Seguro que lo elimino?';

  @override
  String get eveningAnd => ' y ';

  @override
  String get eveningBreakfastAcc => 'el desayuno';

  @override
  String get eveningDinnerAcc => 'la cena';

  @override
  String get eveningEmptyDay => 'El día está vacío. ¿Qué comiste hoy?';

  @override
  String eveningLogged(String slot) {
    return '¿Registraste $slot?';
  }

  @override
  String get eveningLunchAcc => 'el almuerzo';

  @override
  String eveningMissing(String list) {
    return '$list todavía sin registrar. ¿Cuáles hubo?';
  }

  @override
  String get eveningWater => '¿En cuánta agua se quedó el día?';

  @override
  String get fieldBiceps => 'Bíceps';

  @override
  String get fieldChest => 'Pecho';

  @override
  String get fieldHips => 'Cadera';

  @override
  String get fieldNeck => 'Cuello';

  @override
  String get fieldThigh => 'Muslo';

  @override
  String get fieldWaist => 'Cintura';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get fieldWrist => 'Muñeca';

  @override
  String get goalBecomes => 'Pasa a ser';

  @override
  String get goalCurrent => 'Objetivo actual ';

  @override
  String get goalDailyNorm => 'Norma diaria';

  @override
  String goalDiff(String kg) {
    return '$kg de diferencia';
  }

  @override
  String get goalDirection => 'Dirección';

  @override
  String get goalEta => 'Objetivo hacia';

  @override
  String goalFromStart(String kg) {
    return ' desde $kg al empezar. ';
  }

  @override
  String get goalFromToday => 'El nuevo objetivo empieza desde el peso de hoy.';

  @override
  String get goalKeepNote => 'La norma sostiene tu peso actual: repones justo lo que gastas.';

  @override
  String get goalKeepShort => 'Mantener';

  @override
  String get goalNew => 'Fijar un nuevo objetivo';

  @override
  String get goalNewTitle => 'Nuevo objetivo';

  @override
  String get goalPace => 'Ritmo';

  @override
  String get goalPaceFast => 'Rápido';

  @override
  String get goalPaceOk => 'Este es el ritmo que la mayoría sostiene sin romperse.';

  @override
  String get goalPaceSlow => 'Lento';

  @override
  String goalPaceUnit(Object u) {
    return '$u por semana';
  }

  @override
  String get goalPaceUsual => 'Recomendado';

  @override
  String goalRange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get goalReplaceNote =>
      'Un objetivo no se edita, se sustituye. El avance contará desde el peso de hoy, y el objetivo anterior queda en el historial. ¿Confirmas el cambio?';

  @override
  String get goalSet => 'Fijar';

  @override
  String get goalTarget => 'Peso objetivo';

  @override
  String get goalWas => 'Era';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Pan de centeno';

  @override
  String get helloDishEggs => 'Huevos revueltos';

  @override
  String get helloSaid => 'dos huevos y una tostada';

  @override
  String get helloSlotSub => 'dos elementos';

  @override
  String get helloStepCount => 'Cuento las calorías';

  @override
  String get helloStepLog => 'Lo anoto en tu día';

  @override
  String get helloStepSay => 'Di qué comiste';

  @override
  String heroBurned(String kcal) {
    return '-$kcal del entrenamiento';
  }

  @override
  String get heroDays => 'días';

  @override
  String heroFrom(String kcal) {
    return ' de $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'objetivo, $u';
  }

  @override
  String heroKcal(Object u) {
    return ' $u';
  }

  @override
  String heroKg(Object u) {
    return ' $u';
  }

  @override
  String get heroLeft => 'quedan ';

  @override
  String heroOf(String kcal) {
    return ' de $kcal';
  }

  @override
  String get heroOver => 'te pasaste en ';

  @override
  String get heroWeekOpen => 'La semana entera';

  @override
  String heroWeightFrom(String kg) {
    return 'ahora, desde $kg al empezar el objetivo';
  }

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Idioma de la interfaz';

  @override
  String get langSystem => 'Idioma del dispositivo';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'Google no devolvió un token';

  @override
  String get loginNotConfigured => 'el inicio de sesión no está configurado en esta compilación';

  @override
  String get loginNotSynced =>
      'Todavía no han llegado al servidor todos los registros. Prueba dentro de un minuto: iniciar sesión no borra nada hasta que todo esté guardado';

  @override
  String loginServer(String why) {
    return 'servidor: $why';
  }

  @override
  String get loginSlow => 'Google no respondió en un minuto. Inténtalo otra vez';

  @override
  String get macroCNone => 'C ?';

  @override
  String macroCShort(int value) {
    return 'C $value';
  }

  @override
  String get macroCarbs => 'Carbohidratos';

  @override
  String get macroCarbsCaps => 'HIDRATOS';

  @override
  String get macroCarbsLetter => 'C';

  @override
  String get macroFNone => 'G ?';

  @override
  String macroFShort(int value) {
    return 'G $value';
  }

  @override
  String get macroFat => 'Grasas';

  @override
  String get macroFatCaps => 'GRASAS';

  @override
  String get macroFatLetter => 'G';

  @override
  String get macroMedsCaps => 'FÁRMACOS';

  @override
  String macroOfGrams(String goal) {
    return ' / $goal';
  }

  @override
  String get macroPNone => 'P ?';

  @override
  String macroPShort(int value) {
    return 'P $value';
  }

  @override
  String get macroProtein => 'Proteínas';

  @override
  String get macroProteinCaps => 'PROTEÍNAS';

  @override
  String get macroProteinLetter => 'P';

  @override
  String get mealAuto => 'auto ';

  @override
  String get mealEditDelete => 'Eliminar el registro';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Guardar';

  @override
  String get mealEmpty => 'Aquí no hay nada todavía. Escribe qué fue y lo registro.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'Nora está contando…';

  @override
  String get measureAdd => 'Añadir una medida';

  @override
  String get measureCollapse => 'Plegar';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mediciones',
      one: '1 medición',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'la última $ago';
  }

  @override
  String get measureNever => 'sin medir todavía';

  @override
  String get measureNothing => 'nada todavía';

  @override
  String get measurePick => 'Elige qué vas a medir. Con una basta si el resto no te interesa.';

  @override
  String get measureSave => 'Guardar las mediciones';

  @override
  String get measureStats => 'Estadística de medidas';

  @override
  String get measureTitle => 'Medidas';

  @override
  String get medsAdd => 'Añadir un medicamento';

  @override
  String get medsAllTaken => 'Todo lo de hoy está tomado';

  @override
  String get medsAt => 'A las';

  @override
  String get medsCourse => 'Tratamiento';

  @override
  String get medsDose => 'Dosis';

  @override
  String get medsEmpty => 'Aquí no hay nada todavía. Añade un medicamento y te aviso a su hora.';

  @override
  String get medsEmptyHint => 'Llevo el registro de las tomas, la dosis no la calculo';

  @override
  String get medsFinish => 'Terminar el tratamiento';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, primera toma $day a las $at';
  }

  @override
  String get medsHours => 'Horas';

  @override
  String get medsHowOften => 'Cada cuánto';

  @override
  String get medsMine => 'Mis medicamentos';

  @override
  String get medsName => 'Nombre';

  @override
  String get medsNameExample => 'Por ejemplo, Magnesio B6';

  @override
  String get medsNew => 'Nuevo medicamento';

  @override
  String get medsNextAt => 'Siguiente a las ';

  @override
  String get medsNoneToday => 'Hoy no hay tomas';

  @override
  String get medsNote => 'Nota';

  @override
  String get medsNow => 'AHORA';

  @override
  String get medsOne => 'Medicamento';

  @override
  String get medsPast => 'Pasados';

  @override
  String get medsPastEmpty =>
      'Aquí estarán los tratamientos que ya no tomas. Un medicamento retirado de la lista sigue en los días en que lo tomaste.';

  @override
  String get medsPerTake => 'Cuánto por toma';

  @override
  String get medsRemind => 'Avisarme';

  @override
  String get medsRemindHint => 'a las horas elegidas';

  @override
  String get medsResume => 'Retomar el tratamiento';

  @override
  String get medsSchedule => 'Horario';

  @override
  String medsSince(String date) {
    return 'desde $date';
  }

  @override
  String get medsTime => 'Hora';

  @override
  String get medsTitle => 'Medicamentos';

  @override
  String get medsTomorrow => 'mañana';

  @override
  String get medsUnmarked => 'Todavía sin marcar: ';

  @override
  String medsUntil(String date) {
    return 'hasta $date';
  }

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuAllergy => 'Alergias';

  @override
  String get menuAnalytics => 'Analítica';

  @override
  String get menuDiary => 'Diario';

  @override
  String get menuHintFree => 'gratuito';

  @override
  String menuHintKcal(String n) {
    return 'hoy $n';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'ninguna';

  @override
  String get menuHintNoMeds => 'sin pautas';

  @override
  String get menuHintNothing => 'aún nada registrado';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'en meta $ok de $total';
  }

  @override
  String get menuHintRecipes => 'de Nora, a tu medida';

  @override
  String get menuHintWeekFriday => 'desde el viernes, 18:00';

  @override
  String get menuHintWeekOpen => 'abierto hasta el domingo';

  @override
  String get menuHintWeekYoung => 'la semana acaba de empezar';

  @override
  String get menuMeds => 'Medicamentos';

  @override
  String get menuPlan => 'Suscripción';

  @override
  String get menuRecipes => 'Recetas';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuTitle => 'Menú';

  @override
  String get menuWeek => 'Resumen semanal';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Calcularla automáticamente';

  @override
  String get normAutoFrom =>
      'A partir del peso al empezar el objetivo, la altura, la edad, la actividad y el ritmo: ';

  @override
  String normAutoHint(String kcal) {
    return 'a partir del peso, la altura, la edad, la actividad y el objetivo: $kcal';
  }

  @override
  String get normAutoShort => 'Automática';

  @override
  String get normByHand => 'Ponerla a mano';

  @override
  String get normByHandHint => 'la analítica contará contra esta cifra';

  @override
  String get normByHandShort => 'A mano';

  @override
  String get normCalculatedHead => 'El valor calculado es ';

  @override
  String get normCalculatedTail => '. Puedes volver a él eligiendo «Automática».';

  @override
  String get normFitCarbs => 'Ajustar los carbohidratos a la norma';

  @override
  String get normFits => 'El reparto cuadra con la norma';

  @override
  String normGrams(String grams) {
    return '$grams';
  }

  @override
  String normKcalOf(String kcal) {
    return '$kcal';
  }

  @override
  String normMacroSplit(int protein, int fat, String carbs) {
    return '$protein / $fat / $carbs';
  }

  @override
  String get normMacros => 'Macros';

  @override
  String get normManual => 'puesta a mano';

  @override
  String normOf(String kcal) {
    return 'de $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'El reparto da $sum, $off por encima de la norma';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'El reparto da $sum, $off por debajo de la norma';
  }

  @override
  String normPerDay(Object u) {
    return '$u al día';
  }

  @override
  String get normTitle => 'Norma';

  @override
  String get normWater => 'Agua';

  @override
  String get normWaterHead => 'Eso es ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' por kilo de peso. El rango aproximado habitual es de 30 a 40 ml, pero depende del calor y del entrenamiento, así que la cifra de aquí no es rígida.';

  @override
  String get normWhere => 'De dónde sale esta cifra';

  @override
  String get notifyChannel => 'Recordatorios';

  @override
  String get notifyChannelHint => 'Recordatorios de comida, agua, medicamentos y pesajes';

  @override
  String get notifyDenied =>
      'El teléfono rechazó las notificaciones. Actívalas en los ajustes del sistema y los recordatorios funcionarán.';

  @override
  String get photoDish => 'Plato';

  @override
  String get photoNotRecognized => 'No he podido reconocer el plato en esta foto';

  @override
  String get planBuy => 'Suscribirme';

  @override
  String get planClose => 'Cerrar';

  @override
  String get planCurrent => 'actual';

  @override
  String get planFailed => 'La compra no salió adelante';

  @override
  String get planFree => 'Gratis';

  @override
  String planFrom(String plan, String date) {
    return '$plan desde $date';
  }

  @override
  String planFromShort(String date) {
    return 'desde $date';
  }

  @override
  String get planLater => 'Ahora no';

  @override
  String get planManage => 'Gestionar en la tienda';

  @override
  String get planMonth => 'Mes';

  @override
  String get planMonthBilled => 'cobro mensual';

  @override
  String get planMonthly => 'Pro mensual';

  @override
  String get planNext => 'Después';

  @override
  String get planNothingToRestore => 'No hay compras en esta cuenta';

  @override
  String get planNow => 'Ahora';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mes';

  @override
  String get planPerkChat => 'Conversaciones con Nora sin límite';

  @override
  String get planPerkChatSub => 'hoy un mensaje cuesta un token';

  @override
  String get planPerkMemory => 'Nora se acuerda de ti';

  @override
  String get planPerkMemorySub => 'aprende cosas nuevas en la conversación, y eso cuesta un token';

  @override
  String get planPerkPhoto => 'Fotos de comida sin límite';

  @override
  String get planPerkPhotoSub => 'hoy una foto cuesta dos tokens';

  @override
  String get planPerkRecipes => 'Recetas de Nora sin límite';

  @override
  String get planPerkRecipesSub => 'hoy una propuesta cuesta un token';

  @override
  String get planPerkWeek => 'Resumen semanal cuando quieras';

  @override
  String get planPerkWeekSub => 'hoy un resumen cuesta dos tokens';

  @override
  String get planPerks => 'Qué da la suscripción';

  @override
  String get planPlan => 'Plan';

  @override
  String get planPrivacy => 'Política de privacidad';

  @override
  String get planRenewal =>
      'La suscripción se renueva automáticamente hasta que se cancele. Puedes cancelarla cuando quieras en los ajustes de la tienda donde la compraste.';

  @override
  String get planRenews => 'Se renueva';

  @override
  String get planRestore => 'Restaurar compras';

  @override
  String get planSignInGo => 'Iniciar sesión';

  @override
  String get planSignInNote =>
      'La suscripción va ligada a una cuenta con correo. Así sobrevive a un teléfono nuevo y funciona en todos tus dispositivos.';

  @override
  String get planSignInTitle => 'Primero inicia sesión';

  @override
  String get planStoreAsking => 'Pidiendo los precios a la tienda…';

  @override
  String get planStoreOffline => 'La tienda no responde. Comprueba tu conexión a internet';

  @override
  String get planStoreQuiet => 'La tienda no responde. Inténtalo más tarde';

  @override
  String get planSwitchMonth => 'Cambiar a mensual';

  @override
  String get planSwitchYear => 'Cambiar a anual';

  @override
  String get planTariffs => 'Planes';

  @override
  String get planTerms => 'Condiciones de uso';

  @override
  String get planTitle => 'Suscripción';

  @override
  String get planTokens => 'Tokens';

  @override
  String get planTokensFree => '40 al mes';

  @override
  String get planTokensPro => 'Sin límite';

  @override
  String get planUntil => 'Activa hasta';

  @override
  String get planYear => 'Año';

  @override
  String planYearBilled(String price) {
    return '$price una vez al año';
  }

  @override
  String get planYearly => 'Pro anual';

  @override
  String plateFor(String grams) {
    return 'en $grams';
  }

  @override
  String plateGrams(Object u) {
    return ' $u';
  }

  @override
  String plateKcal(Object u) {
    return '$u';
  }

  @override
  String get plateThinking => 'pensando';

  @override
  String get plateTotal => 'total';

  @override
  String get privacyCrash => 'Informes de fallos';

  @override
  String get privacyCrashHint => 'la traza del error, sin datos del diario';

  @override
  String get privacyDiaryHead => 'Tu diario sigue siendo tuyo';

  @override
  String get privacyDiarySub => 'ni las comidas ni el peso van a la analítica';

  @override
  String get privacyHealthHead => 'Los datos de salud no van a nadie';

  @override
  String get privacyHealthSub => 'las alergias y los medicamentos no salen de la app';

  @override
  String get privacyNoPhotosHead => 'Las fotos de comida no se guardan';

  @override
  String get privacyNoPhotosSub => 'la foto se lee y desaparece';

  @override
  String get privacyNotCollected => 'Qué no recogemos';

  @override
  String get privacyOptional => 'Qué puedes desactivar';

  @override
  String get privacyPhotosBold => 'no se guardan';

  @override
  String get privacyPhotosHead => 'Las fotos de comida ';

  @override
  String get privacyPhotosTail =>
      ': la foto va a procesarse y desaparece. La analítica no ve nunca platos, peso, alergias ni medicamentos. Eso es una categoría especial de datos personales, y entregarla a un tercero no es una opción, por cómodo que resultara.';

  @override
  String get privacyStats => 'Estadística anónima';

  @override
  String get privacyStatsHint => 'qué pantallas se abren, sin el contenido de los registros';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get profileActivity => 'Actividad';

  @override
  String get profileAge => 'Edad';

  @override
  String get profileHeight => 'Altura';

  @override
  String get profileSex => 'Sexo';

  @override
  String rcAllergyWarn(String names) {
    return 'Contiene $names, que está en tu lista de alergias. Ten cuidado con esta.';
  }

  @override
  String get rcAsk => 'Pídele una receta a Nora';

  @override
  String get rcAskAbout => 'Pregúntale a Nora por esta receta';

  @override
  String get rcAskCancel => 'Cancelar';

  @override
  String get rcAskGo => 'Preguntar';

  @override
  String get rcAskPlaceholder => 'pollo, brócoli, arroz';

  @override
  String get rcAskTitle => '¿Qué hay en la cocina?';

  @override
  String get rcAsking => 'Pensando…';

  @override
  String rcChatGreet(String name) {
    return 'Pregunta sobre «$name»: qué cambiar, cómo no estropearlo, qué dejar hecho antes.';
  }

  @override
  String get rcChatPlaceholder => 'Pregunta sobre esta receta';

  @override
  String rcCount(int n) {
    return '$n recetas';
  }

  @override
  String rcCountFew(int n) {
    return '$n recetas';
  }

  @override
  String get rcCountOne => '1 receta';

  @override
  String rcDeleteBody(String name) {
    return '«$name» saldrá del recetario. Los registros del diario hechos desde ella se quedan.';
  }

  @override
  String get rcDeleteCta => 'Eliminar';

  @override
  String get rcDeleteFailed => 'No se pudo eliminar. Inténtalo otra vez.';

  @override
  String get rcDeleteTitle => '¿Eliminar esta receta?';

  @override
  String get rcEmpty =>
      'Aquí no hay nada todavía. Dile a Nora qué hay en la cocina y aparece la primera receta.';

  @override
  String get rcEmptyMine =>
      'Todavía no hay recetas tuyas. Dictale cualquiera a Nora y aterriza aquí.';

  @override
  String get rcEyebrow => 'La cocina';

  @override
  String get rcFromMine => 'Mía';

  @override
  String get rcFromNora => 'De Nora';

  @override
  String get rcHeroA => 'Qué cocinar';

  @override
  String get rcHeroB => 'hoy';

  @override
  String get rcHeroLede =>
      'Di qué tienes en casa. Nora propone y calcula la ración; tu propia receta también vale.';

  @override
  String get rcItemsHead => 'Productos';

  @override
  String rcItemsTotal(String g) {
    return 'en total $g';
  }

  @override
  String get rcJustNow => 'ahora mismo';

  @override
  String get rcLoadFailed => 'El recetario no se cargó. Tira para reintentar.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Nada más que un cuchillo y un bol';

  @override
  String rcOfDay(int p) {
    return 'eso es el $p% de la norma diaria';
  }

  @override
  String get rcPerServing => 'por ración';

  @override
  String get rcPerServingHead => 'Por ración';

  @override
  String get rcPickTitle => 'Elige un plato';

  @override
  String rcPortion(String g) {
    return 'ración $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n raciones';
  }

  @override
  String rcServingsMany(int n) {
    return '$n raciones';
  }

  @override
  String get rcServingsOne => '1 ración';

  @override
  String get rcStepsHead => 'Cómo cocinarlo';

  @override
  String get rcSuggestFailed => 'Nora no pudo componer recetas. Inténtalo otra vez.';

  @override
  String get rcTabAll => 'Todas';

  @override
  String get rcTabMine => 'Mías';

  @override
  String get rcTabNora => 'De Nora';

  @override
  String get rcTitle => 'Recetas';

  @override
  String get rcToolBlender => 'Batidora';

  @override
  String get rcToolGrill => 'Parrilla';

  @override
  String get rcToolMixer => 'Mezcladora';

  @override
  String get rcToolOven => 'Horno';

  @override
  String get rcToolPan => 'Sartén';

  @override
  String get rcToolPot => 'Olla';

  @override
  String get rcToolsHead => 'Qué hace falta en la cocina';

  @override
  String rcWhole(String kcal, String g) {
    return 'Plato entero: $kcal, $g';
  }

  @override
  String get remAbout => 'Sobre qué';

  @override
  String get remAdd => 'Añadir un recordatorio';

  @override
  String get remAt => 'A las';

  @override
  String get remDelete => 'Eliminar el recordatorio';

  @override
  String get remEdit => 'Recordatorio';

  @override
  String get remEmpty => 'Todavía no hay recordatorios.';

  @override
  String get remEmptyHint => 'Añade lo único que de verdad se te olvida, no todo de golpe';

  @override
  String get remHowOften => 'Cada cuánto';

  @override
  String get remName => 'Nombre';

  @override
  String get remNew => 'Nuevo recordatorio';

  @override
  String get remOpenMeds => 'Abrir medicamentos';

  @override
  String get remTime => 'Hora';

  @override
  String get remTitle => 'Recordatorios';

  @override
  String get reminderBodyMeal => 'Registra qué fue';

  @override
  String get reminderBodyMeds => 'Toca según el horario';

  @override
  String get reminderBodySummary => '¿Qué no registraste hoy?';

  @override
  String get reminderBodyWater => 'Hora de beber';

  @override
  String get reminderBodyWeigh => 'Por la mañana, antes de comer';

  @override
  String get reminderBodyWorkout => 'Regístralo si lo hiciste';

  @override
  String get reminderMeal => 'Comida';

  @override
  String get reminderMealHint => 'te recuerdo que registres la comida';

  @override
  String get reminderMeds => 'Medicamentos';

  @override
  String get reminderMedsHint => 'según el horario del registro';

  @override
  String get reminderSummary => 'Resumen del día';

  @override
  String get reminderSummaryHint => 'en corto sobre el día antes de dormir';

  @override
  String get reminderWater => 'Agua';

  @override
  String get reminderWaterHint => 'te recuerdo que bebas';

  @override
  String get reminderWeigh => 'Pesaje';

  @override
  String get reminderWeighHint => 'para que la curva del peso no se rompa';

  @override
  String get reminderWorkout => 'Entrenamiento';

  @override
  String get reminderWorkoutHint => 'te recuerdo el que tenías previsto';

  @override
  String get repDaily => 'todos los días';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'cada $count días');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'un día sí y otro no';

  @override
  String get repPickDaily => 'Todos los días';

  @override
  String get repPickFromToday => 'Se cuenta desde hoy.';

  @override
  String get repPickInterval => 'Un día sí y otro no';

  @override
  String get repPickNoDays => 'No hay ningún día elegido, así que el aviso no sonará nunca.';

  @override
  String get repPickWeekdays => 'Días de la semana';

  @override
  String get repWeekdays => 'entre semana';

  @override
  String get repWeekends => 'los fines de semana';

  @override
  String get repWeekly => 'una vez por semana';

  @override
  String get restoredBody1 =>
      'Esta cuenta estaba esperando a ser eliminada. Iniciar sesión lo ha anulado: el diario, el perfil y los ajustes están otra vez en este teléfono.';

  @override
  String get restoredBody2 =>
      'Si sigues queriendo que la cuenta desaparezca, pide la eliminación otra vez en Ajustes. Cualquier inicio de sesión antes de que lo confirmemos anula la solicitud igual.';

  @override
  String get restoredOk => 'Entendido';

  @override
  String get restoredTitle => 'Tus datos han vuelto';

  @override
  String get setAbout => 'Acerca de la app';

  @override
  String get setAccess => 'Acceso';

  @override
  String get setAllergies => 'Alergias';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count en memoria';
  }

  @override
  String get setDeleteAccount => 'Eliminar la cuenta y los datos';

  @override
  String get setFreeTierHead =>
      'Para los defensores de Ucrania, y para quienes sirven en las Fuerzas Armadas, el Servicio Estatal de Emergencias, DTEK, personal médico, voluntarios y docentes en zonas de primera línea, el plan de pago es ';

  @override
  String get setFreeTierHow => ' Cómo conseguirlo';

  @override
  String get setFreeTierShort =>
      'Para los defensores de Ucrania, y para quienes sirven en las Fuerzas Armadas, el Servicio Estatal de Emergencias, DTEK, personal médico, voluntarios y docentes en zonas de primera línea, el plan de pago es GRATIS';

  @override
  String get setFreeTierTelegram => 'Escribir por Telegram';

  @override
  String get setFreeTierTitle => 'Plan gratuito';

  @override
  String get setFreeTierWord => 'GRATIS';

  @override
  String get setFreeTierWrite =>
      'Escribe al desarrollador y el plan de pago se te activa el mismo día.';

  @override
  String get setGoal => 'Objetivo';

  @override
  String get setGoalKeep => 'mantener el peso';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/semana';
  }

  @override
  String get setGroupAbout => 'Sobre ti';

  @override
  String get setGroupAccount => 'Cuenta';

  @override
  String get setGroupAssistant => 'Asistente';

  @override
  String get setGroupDocs => 'Documentos';

  @override
  String get setGroupHealth => 'Salud';

  @override
  String get setLang => 'Idioma';

  @override
  String get setMedical => 'Aviso médico';

  @override
  String get setMeds => 'Medicamentos';

  @override
  String get setNorm => 'Norma';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setPlan => 'Suscripción';

  @override
  String get setPlanFree => 'Gratis';

  @override
  String get setPolicy => 'Política de privacidad';

  @override
  String get setPrivacy => 'Datos y analítica';

  @override
  String get setProfile => 'Perfil';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Recordatorios';

  @override
  String get setRemindersOff => 'desactivados';

  @override
  String get setTerms => 'Condiciones de uso';

  @override
  String get setTheme => 'Tema';

  @override
  String get setTitle => 'Ajustes';

  @override
  String get setUnits => 'Unidades';

  @override
  String get setUnset => 'sin definir';

  @override
  String get sexOther => 'Otro';

  @override
  String get sexShortFemale => 'M';

  @override
  String get sexShortMale => 'H';

  @override
  String get slotBreakfast => 'Desayuno';

  @override
  String get slotByHand => 'Pon los números tú';

  @override
  String get slotCancel => 'Cancelar';

  @override
  String get slotDinner => 'Cena';

  @override
  String slotEraseBody(String name) {
    return '«$name» todavía no tiene números. La fila saldrá del día.';
  }

  @override
  String get slotEraseDo => 'Quitar';

  @override
  String get slotEraseTitle => '¿Quitar el borrador?';

  @override
  String slotGrams(Object u) {
    return 'PESO, $u';
  }

  @override
  String get slotIntoBreakfast => 'en el desayuno';

  @override
  String get slotIntoDinner => 'en la cena';

  @override
  String get slotIntoLunch => 'en el almuerzo';

  @override
  String slotIntoOther(String name) {
    return 'en «$name»';
  }

  @override
  String get slotIntoSnack => 'en el snack';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Registrar';

  @override
  String get slotLunch => 'Almuerzo';

  @override
  String get slotSnack => 'Snack';

  @override
  String get slotWriteWhat => 'Escribe qué fue';

  @override
  String get startAbout => 'Sobre ti';

  @override
  String get startAge => 'Edad';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' y la ';

  @override
  String get startAgreeHead => 'Acepto las ';

  @override
  String get startAgreePrivacy => 'política de privacidad';

  @override
  String get startAgreeTerms => 'condiciones de uso';

  @override
  String get startDeviceFirstRun => 'primer inicio';

  @override
  String get startDocs => 'Documentos';

  @override
  String get startGoal => 'Hacia dónde vamos';

  @override
  String get startGoalGain => 'Subir de peso';

  @override
  String get startGoalGainHint => 'un superávit al ritmo que elijas';

  @override
  String get startGoalKeep => 'Mantener el peso';

  @override
  String get startGoalKeepHint => 'repones justo lo que gastas';

  @override
  String get startGoalLose => 'Bajar de peso';

  @override
  String get startGoalLoseHint => 'un déficit al ritmo que elijas';

  @override
  String get startHeight => 'Altura';

  @override
  String get startHiHello => 'Te damos la bienvenida a';

  @override
  String get startHiNote => 'Seis preguntas cortas, un minuto. El resto lo calcula Nora.';

  @override
  String get startLife => 'Estilo de vida';

  @override
  String get startNorm => 'Tu norma';

  @override
  String get startNormCounting => 'calculando…';

  @override
  String get startNormHold => 'manteniendo';

  @override
  String get startNormNote =>
      'Esta es la fórmula de Mifflin-St Jeor, no un consejo médico. Si tienes alguna condición, estás embarazada o sigues una dieta pautada, consúltalo con tu médico.';

  @override
  String startNormPerDay(Object u) {
    return '$u al día';
  }

  @override
  String get startNormWeeks => 'semanas';

  @override
  String get startPace => 'A qué ritmo';

  @override
  String get startPaceEtaHead => 'Objetivo hacia ';

  @override
  String get startPaceEtaTail => ', o sea ';

  @override
  String get startPaceFast => 'rápido';

  @override
  String get startPaceSlow => 'lento';

  @override
  String startPaceUnit(Object u) {
    return '$u por semana';
  }

  @override
  String get startPaceUsual => 'constante';

  @override
  String get startPaceWarning =>
      'Un ritmo así cuesta sostenerlo y suele romperse. Por debajo de 0,8 kg por semana el resultado llega más despacio, pero se queda.';

  @override
  String startPaceWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String get startSex => 'Sexo';

  @override
  String get startSexFemale => 'Mujer';

  @override
  String get startSexMale => 'Hombre';

  @override
  String get startSexOther => 'Otro';

  @override
  String get startSignInApple => 'Continuar con Apple';

  @override
  String get startSignInBackText =>
      'Inicia sesión con la misma cuenta y vuelve todo: el diario, el objetivo, la norma y las medidas. No hay que rellenar nada otra vez.';

  @override
  String get startSignInBackTitle => 'Bienvenido de nuevo';

  @override
  String get startSignInBusy => 'Entrando…';

  @override
  String get startSignInFailed =>
      'No se pudo iniciar sesión. Inténtalo otra vez o sigue sin cuenta.';

  @override
  String startSignInFailedWhy(String why) {
    return 'No se pudo iniciar sesión. $why';
  }

  @override
  String get startSignInGoogle => 'Continuar con Google';

  @override
  String get startSignInSkip => 'Continuar sin cuenta';

  @override
  String get startSignInText =>
      'La norma está calculada. Inicia sesión para conservarla: el historial, las medidas y los registros estarán en todos tus dispositivos, no solo aquí.';

  @override
  String get startSignInTitle => 'Guardemos esto';

  @override
  String get startTargetWeight => 'Peso objetivo';

  @override
  String get startWeightNow => 'Peso actual';

  @override
  String get startYearsShort => 'años';

  @override
  String get storageBroken =>
      'No se pudo abrir el almacenamiento. Tus registros están a salvo, pero ahora mismo no hay con qué mostrarlos.';

  @override
  String get themeAquarelle => 'Acuarela';

  @override
  String get themeAquarelleHint => 'clara, con nubes pastel sobre el fondo';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDarkHint => 'siempre la interfaz oscura';

  @override
  String get themeDawn => 'Amanecer';

  @override
  String get themeDawnHint => 'clara, con luz cálida de lado';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightHint => 'siempre la interfaz clara';

  @override
  String get themeSectionLook => 'Apariencia';

  @override
  String get themeSystem => 'Tema del dispositivo';

  @override
  String get themeSystemHint => 'sigue el ajuste del sistema';

  @override
  String get todayBarcode => 'Código de barras';

  @override
  String todayCodeTalk(String code) {
    return 'He escaneado el código de barras $code y ninguna base lo conoce. No registres nada: pregúntame por este producto o dime cómo contarlo.';
  }

  @override
  String get todayDone => 'Listo.';

  @override
  String get todayFailedRetry => 'No salió. Prueba dentro de un minuto.';

  @override
  String get todayGoalMet =>
      '¡Enhorabuena! 🎉 El peso que querías ya es tuyo y el objetivo está cerrado. Y lo has hecho tú, no la app. Ahora paso tu norma a mantenimiento, para que el resultado se quede.';

  @override
  String todayHowManyGrams(String dish) {
    return '¿Cuántos gramos eran de $dish?';
  }

  @override
  String get todayLogFailed => 'No se pudo registrar. Inténtalo otra vez.';

  @override
  String get todayLogged => 'Registrado.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Registrado $slotInto. Dime el peso si lo quieres exacto.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Registrado. Dime el peso si lo quieres exacto.';

  @override
  String todayLoggedCount(int count) {
    return '$count registrados';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Registrado $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Registrado $slotInto: $dish, $kcal por $grams.';
  }

  @override
  String get todayNoraSlow =>
      'Nora está pensando más de lo normal. Inténtalo otra vez, el token no se gastó.';

  @override
  String get todayOffline => 'Sin conexión. Inténtalo cuando vuelva.';

  @override
  String get todayOfflineSaved =>
      'Sin conexión. El registro se queda en el teléfono y sube cuando vuelva.';

  @override
  String get todayOutOfBody =>
      'De momento callo, pero apuntar a mano se puede siempre, y es gratis. La suscripción me vuelve a encender y cuesta como tres cafés al mes.';

  @override
  String get todayOutOfPlan => 'Suscripción';

  @override
  String get todayOutOfTokens => 'Se acabaron los tokens.';

  @override
  String get todayPhotoMeal => 'Foto';

  @override
  String get todayQuestionClosed =>
      'Esa pregunta ya está cerrada. Di el peso con palabras si hace falta.';

  @override
  String get tourCamera => 'Cámara';

  @override
  String get tourCameraHow => 'un plato, una etiqueta o un código de barras';

  @override
  String get tourDiary => 'Memoria del diario';

  @override
  String get tourDiaryHow => 'di «borsch» y toma tu porción de siempre';

  @override
  String get tourGuide => 'Guía de la app';

  @override
  String get tourGuideHow => 'pregunta dónde está cada cosa y cómo se hace';

  @override
  String get tourMemory => 'Memoria permanente';

  @override
  String get tourMemoryHow => '«no como cerdo» basta decirlo una vez';

  @override
  String get tourMore => 'No solo comida';

  @override
  String get tourMoreHow => 'agua, entrenamientos, medidas, recetas';

  @override
  String get tourTitle => 'Qué sabe hacer Nora';

  @override
  String get tourVoice => 'Voz o texto';

  @override
  String get tourVoiceHow => '«dos huevos y una tostada», y ya está anotado';

  @override
  String get tourWeek => 'Análisis del día y la semana';

  @override
  String get tourWeekHow => 'qué salió bien y qué conviene ajustar';

  @override
  String get unitCm => 'cm';

  @override
  String get unitG => 'g';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitKg => 'kg';

  @override
  String get unitKj => 'kJ';

  @override
  String get unitMl => 'ml';

  @override
  String get unitsEnergy => 'Energía';

  @override
  String get unitsLength => 'Altura y medidas';

  @override
  String get unitsMass => 'Peso corporal';

  @override
  String get unitsPortion => 'Porciones de comida';

  @override
  String get unitsTitle => 'Qué unidades';

  @override
  String get unitsVolume => 'Agua';

  @override
  String get watchLinked => 'conectado';

  @override
  String waterGlasses(int glasses) {
    return 'unos $glasses vasos';
  }

  @override
  String waterLess(String step) {
    return '$step menos';
  }

  @override
  String waterMore(String step) {
    return '$step más';
  }

  @override
  String get waterNone => 'nada bebido';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% del objetivo diario';
  }

  @override
  String get waterTitle => 'Agua';

  @override
  String get wcNoTime => 'sin duración';

  @override
  String get wdFri => 'Vie';

  @override
  String get wdMon => 'Lun';

  @override
  String get wdSat => 'Sáb';

  @override
  String get wdSun => 'Dom';

  @override
  String get wdThu => 'Jue';

  @override
  String get wdTue => 'Mar';

  @override
  String get wdWed => 'Mié';

  @override
  String get weightHint => 'Lo que pesas hoy. El objetivo y el ritmo hacia él viven aparte.';

  @override
  String get weightNote =>
      'Pésate por la mañana, antes de comer: así los vaivenes del día no convierten el gráfico en ruido. Una medición por semana ya es una tendencia.';

  @override
  String get weightTitle => 'Peso';

  @override
  String get welEggs => 'Dos huevos fritos';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Ya tengo cuenta';

  @override
  String get welLead => 'Cuenta las calorías con tus propias palabras';

  @override
  String get welSaid => 'Comí dos huevos y una tostada';

  @override
  String get welStart => 'Empezar';

  @override
  String get welToast => 'Tostada con mantequilla';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'En total';

  @override
  String wfBurned(Object u) {
    return 'Quemadas, $u';
  }

  @override
  String get wfDuration => 'Duración';

  @override
  String get wfDurationCap => 'Duración, min';

  @override
  String get wfEstimate => 'Una estimación a partir de tu peso y del tipo de actividad';

  @override
  String get wfFromWatch => 'De un reloj o de una máquina';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Registrar';

  @override
  String wfManualKcal(Object u) {
    return '$u a mano';
  }

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minutos';

  @override
  String get wfNote => 'Nota';

  @override
  String get wfNoteExample => 'Piernas, duro';

  @override
  String get wfOptional => '  opcional';

  @override
  String get wheelLess => 'Menos';

  @override
  String get wheelMore => 'Más';

  @override
  String get wkDaysOk => 'días en objetivo';

  @override
  String get wkEmpty =>
      'Esta semana todavía no hay nada registrado. Registra el primer día y aparece la imagen.';

  @override
  String get wkFactsHead => 'La semana en total';

  @override
  String get wkKcalHead => 'Calorías';

  @override
  String get wkLoggedCap => 'días registrados';

  @override
  String wkLoggedValue(int n) {
    return '$n de 7';
  }

  @override
  String get wkMacroHead => 'Macros';

  @override
  String get wkNoWeight => 'peso: sin pesajes';

  @override
  String get wkNoraBtn => 'Crear el análisis';

  @override
  String wkNoraFailed(String why) {
    return 'No se pudo crear el análisis: $why';
  }

  @override
  String get wkNoraGreet =>
      'Pregunta lo que quieras de esta lectura: un plato, un hábito o qué arreglar primero.';

  @override
  String get wkNoraLoading => 'Nora está leyendo la semana…';

  @override
  String get wkNoraLocked => 'El análisis se abre el viernes';

  @override
  String get wkNoraNoNet => 'sin red';

  @override
  String get wkNoraNoTokens => 'sin tokens';

  @override
  String get wkNoraP1 =>
      'Tu base es sana, y eso es raro: casi todo es casero. Sopa, huevos revueltos, avena: sobre una base así lo demás se arregla rápido.';

  @override
  String get wkNoraP2 =>
      'Ahora, con franqueza. La verdura apenas apareció en toda la semana, y el dulce apareció a diario: tortitas con miel, compota. Las proteínas se quedan cortas no porque comas poco, sino porque el plato va cargado de carbohidratos y flojo de carne, pescado o queso. Y tres cenas de siete cayeron después de las diez.';

  @override
  String get wkNoraP3 =>
      'Todavía no hay nada grave, pero esta es justo la dieta que sorprende en los análisis a los cuarenta. Un paso para la semana que viene, sin cambiar nada más: algo verde en cada almuerzo, y agua en lugar de la compota.';

  @override
  String get wkNoraPlaceholder => 'Pregunta sobre esta semana';

  @override
  String get wkNoraPromise =>
      'Una lectura honesta de tu semana: qué funcionó, qué se escapó y un paso para la siguiente.';

  @override
  String get wkNoraReply1 =>
      'El cambio más fácil de esta semana: agua en lugar de la compota. Una cucharada de azúcar menos cada vez, y la sopa no pierde nada.';

  @override
  String get wkNoraReply2 =>
      'Verde en el almuerzo no tiene que significar ensalada. Un pepino o medio pimiento al lado del plato ya cumplen.';

  @override
  String get wkNoraSlow => 'el servidor tarda demasiado';

  @override
  String get wkNoraTalk => 'Coméntalo con Nora';

  @override
  String get wkNoraTitle => 'Nora sobre tu semana';

  @override
  String get wkNorm => 'objetivo';

  @override
  String wkOffNorm(String n) {
    return '$n del objetivo';
  }

  @override
  String get wkPastEmpty =>
      'Todavía no hay análisis anteriores. El primero aparecerá aquí el lunes que viene.';

  @override
  String wkPastRow(String day) {
    return 'Semana del $day';
  }

  @override
  String get wkPastTitle => 'Semanas anteriores';

  @override
  String wkPerDay(Object u) {
    return '$u al día de media';
  }

  @override
  String get wkPerDayAside => 'al día de media';

  @override
  String get wkTitle => 'La semana';

  @override
  String wkTotalCap(Object u) {
    return '$u en la semana';
  }

  @override
  String get wkWaterCap => 'de agua al día';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'peso esta semana';

  @override
  String get workoutAdd => 'Añadir un entrenamiento';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Plegar';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'nada registrado';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Entrenamiento';
}
