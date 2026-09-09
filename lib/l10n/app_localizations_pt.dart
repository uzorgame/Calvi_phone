// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutContact => 'Contato';

  @override
  String get aboutDeveloper => 'Desenvolvedor';

  @override
  String get aboutText =>
      'Um diário alimentar que entende frases normais. A Nora faz as contas, as decisões continuam suas.';

  @override
  String get aboutTitle => 'Sobre o app';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutWrite => 'Escreva para a gente';

  @override
  String get accessAsk => 'ainda não pedido';

  @override
  String get accessCamera => 'Câmera';

  @override
  String get accessMic => 'Microfone';

  @override
  String get accessNote =>
      'O microfone e o reconhecimento de fala são necessários para ditar, e o reconhecimento também para o relógio: ele grava o que você diz e o telefone transforma em palavras. Toque numa linha para conceder o acesso ou abrir os ajustes do sistema e desativá-lo.';

  @override
  String get accessNotify => 'Notificações';

  @override
  String get accessOff => 'negado';

  @override
  String get accessOn => 'permitido';

  @override
  String get accessSpeech => 'Reconhecimento de fala';

  @override
  String get accountBusy => 'Entrando…';

  @override
  String get accountGoogle => 'Continuar com o Google';

  @override
  String get accountKeepCloud => 'O da conta';

  @override
  String get accountNoAccountNote =>
      'O diário vive só neste telefone. Troque de telefone ou apague o app e não vai haver com o que trazer os registros de volta: a gente não sabe de quem eles são.';

  @override
  String get accountScopeNote =>
      'A gente pede só o e-mail. O Google não passa o nome, a foto do perfil nem os contatos.';

  @override
  String get accountSettingsDevice => 'configurações';

  @override
  String get accountSignInFailed => 'Não deu para entrar.';

  @override
  String accountSignInFailedWhy(String why) {
    return 'Não deu para entrar. $why';
  }

  @override
  String get accountSignOut => 'Sair';

  @override
  String get accountSignOutAction => 'Sair';

  @override
  String get accountSignOutAsk => 'Sair da conta?';

  @override
  String get accountSignOutBack =>
      'Entre de novo com a mesma conta e tudo volta. O que foi escrito sem internet e ainda não chegou ao servidor não dá para recuperar.';

  @override
  String get accountSignOutNote =>
      'Este telefone fica limpo: vão embora o diário, o perfil, os medicamentos e a conversa com a Nora. Seus registros continuam no servidor, na sua conta.';

  @override
  String get accountSince => 'No Calvi desde';

  @override
  String get accountTitle => 'Conta';

  @override
  String get accountVia => 'Entrou com o Google';

  @override
  String get accountViaApple => 'Entrou com a Apple';

  @override
  String get accountViaEmail => 'Entrou com e-mail';

  @override
  String get accountWatch => 'Apple Watch';

  @override
  String get accountWhichDiary => 'Com qual diário a gente fica?';

  @override
  String get accountWhichDiaryNote =>
      'Esta conta já tem registros, e o telefone também. Só um pode ficar: o da conta ou o do telefone. O outro vai embora.';

  @override
  String get actBasketball => 'Basquete';

  @override
  String get actBike => 'Bicicleta';

  @override
  String get actDance => 'Dança';

  @override
  String get actFootball => 'Futebol';

  @override
  String get actGym => 'Academia';

  @override
  String get actHiit => 'HIIT';

  @override
  String get actJumprope => 'Pular corda';

  @override
  String get actRun => 'Corrida';

  @override
  String get actSki => 'Esqui';

  @override
  String get actStretch => 'Alongamento';

  @override
  String get actSwim => 'Natação';

  @override
  String get actTennis => 'Tênis';

  @override
  String get actWalk => 'Caminhada';

  @override
  String get actYoga => 'Ioga';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionDone => 'Pronto';

  @override
  String get actionNext => 'Avançar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get activityHigh => 'Alto';

  @override
  String get activityHighHint => '5-6 treinos';

  @override
  String get activityLight => 'Pouco ativo';

  @override
  String get activityLightHint => '1-2 treinos por semana';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityModerateHint => '3-4 treinos';

  @override
  String get activitySedentary => 'Sedentário';

  @override
  String get activitySedentaryHint => 'quase nenhum movimento';

  @override
  String get activityVeryHigh => 'Muito alto';

  @override
  String get activityVeryHighHint => 'trabalho físico ou esporte todo dia';

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get agoToday => 'hoje';

  @override
  String get agoWeek => 'há uma semana';

  @override
  String agoWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'há $count semanas');
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'ontem';

  @override
  String get allergyConfirm => 'Confirmar';

  @override
  String get allergyMild => 'Leve';

  @override
  String get allergyMildHint => 'Eu aviso no texto, sem bloquear o registro.';

  @override
  String get allergyMildShort => 'leve';

  @override
  String get allergyNote =>
      'Se a composição de um produto não está no catálogo, eu não fico calada nem trato isso como seguro: eu digo à parte que a composição é desconhecida.';

  @override
  String get allergyNothing =>
      'Nada encontrado. Se o alérgeno não está na lista, diga para a Nora: a gente coloca no catálogo para funcionar para todo mundo, em vez de ficar como texto para uma pessoa só.';

  @override
  String get allergyRemove => 'Tirar';

  @override
  String allergySearch(int count) {
    return 'Buscar entre $count alérgenos';
  }

  @override
  String get allergySevere => 'Grave';

  @override
  String get allergySevereHint => 'Eu paro antes de anotar e digo com todas as letras.';

  @override
  String get allergySevereShort => 'grave';

  @override
  String get allergyTitle => 'Alergias';

  @override
  String anChartGoal(String value) {
    return 'meta $value';
  }

  @override
  String get anDaysInNorm => 'dias dentro da meta';

  @override
  String anDonePercent(int percent) {
    return '$percent% feito';
  }

  @override
  String anEtaHead(String date) {
    return 'Nesse ritmo você chega à meta por volta de *$date*';
  }

  @override
  String get anForMonth => 'no mês';

  @override
  String get anForQuarter => 'em 3 meses';

  @override
  String get anForYear => 'no ano';

  @override
  String get anGoalProgress => 'Progresso até a meta';

  @override
  String get anKcal => 'Calorias';

  @override
  String get anKcalAvg => 'em média por dia';

  @override
  String get anKcalEmpty =>
      'Ainda não há nada anotado neste período. Diga para a Nora o que você comeu e o gráfico se monta sozinho.';

  @override
  String anKcalTotal(Object u) {
    return 'no período, $u';
  }

  @override
  String anMacroGoal(String grams) {
    return 'referência $grams';
  }

  @override
  String get anMacrosAvg => 'Macros em média';

  @override
  String get anMacrosEmpty =>
      'A média aparece assim que houver o que calcular: anote pelo menos um dia.';

  @override
  String get anMeasures => 'Medidas';

  @override
  String anMeasuresChange(String period) {
    return 'variação $period';
  }

  @override
  String get anMeasuresEmpty => 'Ainda não há medidas.';

  @override
  String get anMeasuresEmptyHint => 'Meça uma vez por mês e eu mostro o que está se mexendo';

  @override
  String get anMonth => 'Mês';

  @override
  String get anNow => 'agora';

  @override
  String anNowKg(Object u) {
    return 'agora, $u';
  }

  @override
  String get anOneReading => 'uma medição';

  @override
  String get anOneWeighing =>
      'Por enquanto há só uma medição. A segunda mostra a direção, e a linha começa nela.';

  @override
  String get anPerDay => 'por dia';

  @override
  String get anQuarter => '3 meses';

  @override
  String anShareOfNorm(int share) {
    return '$share% da referência';
  }

  @override
  String anStartKg(Object u) {
    return 'início, $u';
  }

  @override
  String anTargetKg(Object u) {
    return 'meta, $u';
  }

  @override
  String get anTitle => 'Estatísticas';

  @override
  String get anWater => 'Hidratação';

  @override
  String anWaterAvg(Object u) {
    return 'em média, $u';
  }

  @override
  String anWaterGoal(String ml) {
    return 'referência $ml';
  }

  @override
  String get anWeek => 'Semana';

  @override
  String get anWeightEmpty =>
      'A curva aparece a partir da segunda pesagem. Diga seu peso para a Nora e ela anota sozinha.';

  @override
  String get anYear => 'Ano';

  @override
  String get assistantAddMemory => 'Adicionar à memória';

  @override
  String get assistantCollapse => 'Recolher';

  @override
  String get assistantExample => 'Por exemplo, eu não como cogumelos';

  @override
  String get assistantForget => 'Esquecer';

  @override
  String assistantHint(String name) {
    return 'A $name leva o diário com você e lembra o que você contou sobre si.';
  }

  @override
  String get assistantMemory => 'Memória';

  @override
  String get assistantMemoryEmpty => 'Ainda não há nada guardado.';

  @override
  String get assistantMemoryEmptyHint => 'A memória nasce das conversas, ou adicione algo na mão';

  @override
  String assistantPinned(int count, int pinned) {
    return '$count, $pinned fixadas';
  }

  @override
  String get assistantTitle => 'Assistente';

  @override
  String get assistantWhatToRemember => 'O que lembrar';

  @override
  String get authAgain => 'Confirmar palavra-passe';

  @override
  String get authAgainDiffers => 'As palavras-passe não coincidem';

  @override
  String get authAgainEmpty => 'Repete a palavra-passe';

  @override
  String get authAgainHint => 'outra vez';

  @override
  String authAgainIn(int sec) {
    return 'Podes pedir de novo em $sec s';
  }

  @override
  String get authCode => 'Código do e-mail';

  @override
  String get authCodeAction => 'Confirmar';

  @override
  String get authCodeBad => 'O código não serve ou já expirou';

  @override
  String authCodeHint(String mail) {
    return 'Enviámos um código para $mail. Escreve os seis dígitos.';
  }

  @override
  String get authCodeShort => 'O código tem 6 dígitos';

  @override
  String get authCodeTitle => 'Confirma o teu e-mail';

  @override
  String get authForgotAction => 'Enviar código';

  @override
  String get authForgotHint =>
      'Enviamos um código para o teu e-mail e depois escolhes uma nova palavra-passe.';

  @override
  String get authForgotLink => 'Esqueceste?';

  @override
  String get authForgotTitle => 'Nova palavra-passe';

  @override
  String get authMail => 'E-mail';

  @override
  String get authMailBad => 'Este endereço parece errado';

  @override
  String get authOr => 'ou';

  @override
  String get authPass => 'Palavra-passe';

  @override
  String get authPassEmpty => 'Escreve a palavra-passe';

  @override
  String get authPassHint => '5 letras e um sinal';

  @override
  String get authPassNew => 'Nova palavra-passe';

  @override
  String get authPassWeak => 'Palavra-passe fraca: pelo menos 5 letras e um dígito ou sinal';

  @override
  String get authResetAction => 'Guardar';

  @override
  String get authSendAgain => 'Enviar de novo';

  @override
  String get authSignInAction => 'Entrar';

  @override
  String get authSignInTitle => 'Entrar';

  @override
  String get authSignUpAction => 'Criar conta';

  @override
  String get authSignUpLink => 'Registar';

  @override
  String get authSignUpTitle => 'Vamos criar uma conta';

  @override
  String get barCamera => 'Câmera';

  @override
  String barGrams(String grams) {
    return '$grams';
  }

  @override
  String get barHint => 'Olá, sou a Nora. Escreve ou fala como de costume, que eu percebo.';

  @override
  String get barHintBorscht => 'Feijoada 300 g no almoço';

  @override
  String get barHintDelete => 'Apague o último registro';

  @override
  String get barHintEggs => 'Dois ovos e uma torrada';

  @override
  String get barHintMore =>
      '«dois ovos e uma torrada», «bebi 300 de água», «corri 40 minutos»: eu entendo e coloco no cartão certo';

  @override
  String get barHintProtein => 'Quanta proteína ainda falta?';

  @override
  String get barHintRun => 'Corri 40 minutos';

  @override
  String get barHintWater => 'Bebi 500 ml de água';

  @override
  String get barHintWeighed => 'Peso: 78,8';

  @override
  String get barHintYesterday => 'O que eu comi ontem?';

  @override
  String get barLogsInto => 'Anotando em ';

  @override
  String get barMic => 'Microfone';

  @override
  String get barSend => 'Enviar';

  @override
  String get camAgain => 'De novo';

  @override
  String get camAllergen => 'Alérgeno!';

  @override
  String camAllergyContains(String list) {
    return 'Contém o seu alérgeno: $list';
  }

  @override
  String camAllergyTraces(String list) {
    return 'Pode conter traços de: $list';
  }

  @override
  String get camAskNoraInstead => 'Sem rótulo, pergunte à Nora';

  @override
  String get camBarcode => 'Código de barras';

  @override
  String get camBusy => 'A câmera não abriu. Normalmente outro app está usando ela.';

  @override
  String get camCouldNotRead => 'Não consegui ler a foto';

  @override
  String get camDish => 'Foto';

  @override
  String camEstimate(Object u) {
    return ' $u, estimativa';
  }

  @override
  String get camFlash => 'Flash';

  @override
  String get camFromPack => 'Números da embalagem. Anotar isso não custa tokens.';

  @override
  String get camGallery => 'Da galeria';

  @override
  String get camGapNote => 'Nenhuma base conhece esse número. Fotografe o rótulo e eu completo.';

  @override
  String get camHintBarcode => 'o código dentro da moldura';

  @override
  String get camHintDish => 'aponte para um prato ou um pacote';

  @override
  String camIngredients(String text) {
    return 'Ingredientes: $text';
  }

  @override
  String camIntoSlot(String slot) {
    return 'em $slot';
  }

  @override
  String camKcalFor(String grams, Object u) {
    return ' $u em $grams';
  }

  @override
  String camKcalPer(String grams, Object u) {
    return ' $u por $grams';
  }

  @override
  String get camLabelAim => 'aponte para a tabela nutricional';

  @override
  String get camLabelNoShot => 'A foto não saiu. Tente fotografar o rótulo de novo.';

  @override
  String get camLabelReading => 'Copiando os números do pacote…';

  @override
  String camLogInto(String slotInto) {
    return 'Anotar $slotInto';
  }

  @override
  String get camNoPermission =>
      'Sem permissão para a câmera. Você pode liberar nas configurações do telefone.';

  @override
  String get camNoScanner => 'Este telefone não consegue ler códigos com a câmera.';

  @override
  String get camNoTokens => 'Sem tokens';

  @override
  String get camNotAProduct => 'Isso não é um código de produto';

  @override
  String get camNotAProductNote =>
      'Foi lido um link ou um código interno. Aponte para as barras com os dígitos embaixo.';

  @override
  String get camNotRead => 'Não consegui distinguir';

  @override
  String get camOffline =>
      'O código foi lido, mas não há a quem perguntar. Tente de novo quando voltar a rede.';

  @override
  String get camOfflineShot => 'Sem conexão. Você pode enviar a foto para a Nora mais tarde';

  @override
  String get camOfflineTitle => 'Sem rede';

  @override
  String get camPer100 => 'A embalagem não traz um peso exato: os números são por 100 g.';

  @override
  String camPortionPack(String g) {
    return 'Porção da embalagem: $g. Os números são por porção.';
  }

  @override
  String get camReading => 'Lendo…';

  @override
  String get camSendToNora => 'Enviar para a Nora';

  @override
  String get camServerDown => 'Não é o código nem a câmera. Tente daqui a um minuto.';

  @override
  String get camServerDownTitle => 'Nosso servidor não respondeu';

  @override
  String get camShoot => 'Tirar uma foto';

  @override
  String get camShootLabel => 'Fotografar o rótulo';

  @override
  String get camShotFailed => 'A foto não saiu';

  @override
  String get camShotReady => 'A foto está pronta';

  @override
  String get camShotReadyNote =>
      'A Nora lê e responde no chat: diz que prato é, estima a porção e mostra de onde vem o número. Custa dois tokens.';

  @override
  String get camSignedOut =>
      'A sessão não vale mais, então a base não nos reconhece. Entre de novo e o scanner volta a funcionar.';

  @override
  String get camSignedOutTitle => 'Entre de novo';

  @override
  String get camSlow => 'O código foi lido e a base demorou demais. Tente de novo.';

  @override
  String get camSlowTitle => 'A resposta não chegou';

  @override
  String get camStillWorks => 'Fotos de pratos e a galeria funcionam como sempre.';

  @override
  String get camTitle => 'Scanner';

  @override
  String get camTookTooLong => 'A leitura demorou demais. Tente de novo';

  @override
  String get camUnknownCode => 'Este produto não está em nenhuma base';

  @override
  String get camUnknownCodeNote =>
      'Nem na nossa nem na aberta. Fotografe a tabela nutricional do pacote e eu copio os números de lá. É de graça.';

  @override
  String get chatPro => 'Pro';

  @override
  String get deleteAskBody1 =>
      'Este telefone fica limpo na hora: o diário, o perfil, a conversa com a Nora e a entrada. O app volta para a primeira tela.';

  @override
  String get deleteAskBody2 =>
      'No servidor a conta entra na fila para a exclusão definitiva, e isso leva até 30 dias úteis. Enquanto a gente não confirmar, entrar com a mesma conta traz tudo de volta e cancela o pedido.';

  @override
  String get deleteAskCta => 'Sim, excluir';

  @override
  String get deleteAskTitle => 'Excluir a conta?';

  @override
  String get deleteConfirm =>
      'Entendo que os dados serão excluídos para sempre e não dá para recuperar.';

  @override
  String get deleteDays => 'Dias com o Calvi';

  @override
  String get deleteEntries => 'Registros no diário';

  @override
  String deleteFailed(String why) {
    return 'Não consegui excluir: $why';
  }

  @override
  String get deleteForever => 'Excluir para sempre';

  @override
  String get deleteNote =>
      'Vai tudo: o diário, o peso, as medidas, as alergias, os medicamentos e o histórico das conversas. Não tem volta.';

  @override
  String get deleteProManage => 'Gerenciar a assinatura';

  @override
  String deleteProNote(String store) {
    return 'Excluir a conta não cancela o Calvi Pro. A $store continua cobrando até a própria assinatura ser cancelada, então cancele antes de excluir a conta.';
  }

  @override
  String get deleteProStoreAny => 'loja';

  @override
  String get deleteSubNote =>
      'Se o assunto é a assinatura, dá para cancelar à parte na App Store ou no Google Play, sem excluir a conta.';

  @override
  String get deleteTitle => 'Excluir a conta';

  @override
  String get deleteWeighings => 'Pesagens';

  @override
  String get dictationBusy => 'O microfone está ocupado. Tente de novo';

  @override
  String get dictationFailed => 'O ditado não funcionou';

  @override
  String get dictationNoMatch => 'Não ouvi nada que desse para entender';

  @override
  String get dictationNoNetwork => 'O reconhecimento precisa de rede';

  @override
  String get dictationNoPermission => 'Sem permissão para o microfone';

  @override
  String get dictationSilence => 'Silêncio. Tente de novo, mais perto do microfone';

  @override
  String get dictationUnavailable => 'O ditado não está disponível neste telefone';

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
  String get doseShotFew => 'injeções';

  @override
  String get doseShotMany => 'injeções';

  @override
  String get doseShotOne => 'injeção';

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
      'Vai o diário inteiro, de todo o tempo: refeições, água, peso, medidas, treinos, medicamentos e a conversa com a Nora. Em todos os aparelhos, porque a cópia do servidor também é apagada.';

  @override
  String get eraseAskBody2 =>
      'O que fica: a conta, a entrada, os tokens com o saldo e as configurações do perfil. Isso não é sair da conta, é começar do zero dentro da mesma conta.';

  @override
  String get eraseAskCta => 'Excluir tudo';

  @override
  String get eraseAskTitle => 'Excluir todos os registros?';

  @override
  String get eraseDataTitle => 'Excluir os dados';

  @override
  String get eraseDone => 'O diário foi apagado. Começando do zero.';

  @override
  String eraseFailed(String why) {
    return 'Não consegui apagar: $why';
  }

  @override
  String get eraseNoNet => 'sem rede. Ligue a internet e tente de novo';

  @override
  String get eraseSlow => 'o servidor está demorando demais. Tente daqui a um minuto';

  @override
  String get eraseSureBody =>
      'Isso não dá para desfazer. O diário some para sempre, e nem você nem a gente traz de volta.';

  @override
  String get eraseSureCta => 'Sim, excluir para sempre';

  @override
  String get eraseSureTitle => 'Excluir mesmo?';

  @override
  String get eveningAnd => ' e ';

  @override
  String get eveningBreakfastAcc => 'o café da manhã';

  @override
  String get eveningDinnerAcc => 'o jantar';

  @override
  String get eveningEmptyDay => 'O dia está vazio. O que você comeu hoje?';

  @override
  String eveningLogged(String slot) {
    return 'Você anotou $slot?';
  }

  @override
  String get eveningLunchAcc => 'o almoço';

  @override
  String eveningMissing(String list) {
    return '$list ainda sem anotar. Quais aconteceram?';
  }

  @override
  String get eveningWater => 'Em quanta água o dia ficou?';

  @override
  String get fieldBiceps => 'Bíceps';

  @override
  String get fieldChest => 'Peito';

  @override
  String get fieldHips => 'Quadril';

  @override
  String get fieldNeck => 'Pescoço';

  @override
  String get fieldThigh => 'Coxa';

  @override
  String get fieldWaist => 'Cintura';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get fieldWrist => 'Punho';

  @override
  String get goalBecomes => 'Fica';

  @override
  String get goalCurrent => 'Meta atual ';

  @override
  String get goalDailyNorm => 'Referência do dia';

  @override
  String goalDiff(String kg) {
    return '$kg de diferença';
  }

  @override
  String get goalDirection => 'Direção';

  @override
  String get goalEta => 'Meta por volta de';

  @override
  String goalFromStart(String kg) {
    return ' desde $kg no começo. ';
  }

  @override
  String get goalFromToday => 'A nova meta começa a partir do peso de hoje.';

  @override
  String get goalKeepNote =>
      'A referência segura o seu peso atual: você repõe exatamente o que gasta.';

  @override
  String get goalKeepShort => 'Manter';

  @override
  String get goalNew => 'Definir uma nova meta';

  @override
  String get goalNewTitle => 'Nova meta';

  @override
  String get goalPace => 'Ritmo';

  @override
  String get goalPaceFast => 'Rápido';

  @override
  String get goalPaceOk => 'Esse é o ritmo que a maioria mantém sem quebrar.';

  @override
  String get goalPaceSlow => 'Devagar';

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
      'Uma meta não se edita, se substitui. O progresso passa a contar do peso de hoje, e a meta antiga fica no histórico. Confirma a troca?';

  @override
  String get goalSet => 'Definir';

  @override
  String get goalTarget => 'Peso desejado';

  @override
  String get goalWas => 'Era';

  @override
  String gramsUnit(String grams) {
    return '$grams';
  }

  @override
  String get helloDishBread => 'Pão de centeio';

  @override
  String get helloDishEggs => 'Ovos mexidos';

  @override
  String get helloSaid => 'dois ovos e uma torrada';

  @override
  String get helloSlotSub => 'dois itens';

  @override
  String get helloStepCount => 'Eu conto as calorias';

  @override
  String get helloStepLog => 'Eu anoto no seu dia';

  @override
  String get helloStepSay => 'Diga o que você comeu';

  @override
  String heroBurned(String kcal) {
    return '-$kcal do treino';
  }

  @override
  String get heroDays => 'dias';

  @override
  String heroFrom(String kcal) {
    return ' de $kcal';
  }

  @override
  String heroGoalKg(Object u) {
    return 'meta, $u';
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
  String get heroLeft => 'faltam ';

  @override
  String heroOf(String kcal) {
    return ' de $kcal';
  }

  @override
  String get heroOver => 'passou em ';

  @override
  String get heroWeekOpen => 'A semana inteira';

  @override
  String heroWeightFrom(String kg) {
    return 'agora, desde $kg no início da meta';
  }

  @override
  String kcalUnit(String kcal) {
    return '$kcal';
  }

  @override
  String get langSection => 'Idioma da interface';

  @override
  String get langSystem => 'Idioma do aparelho';

  @override
  String get legalOnTheWeb => 'Open on the web';

  @override
  String legalUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get loginNoToken => 'O Google não devolveu um token';

  @override
  String get loginNotConfigured => 'a entrada não está configurada nesta build';

  @override
  String get loginNotSynced =>
      'Nem todos os registros chegaram ao servidor. Tente daqui a um minuto: entrar não apaga nada enquanto tudo não estiver salvo';

  @override
  String loginServer(String why) {
    return 'servidor: $why';
  }

  @override
  String get loginSlow => 'O Google não respondeu em um minuto. Tente de novo';

  @override
  String get macroCNone => 'C ?';

  @override
  String macroCShort(int value) {
    return 'C $value';
  }

  @override
  String get macroCarbs => 'Carboidratos';

  @override
  String get macroCarbsCaps => 'CARBOS';

  @override
  String get macroCarbsLetter => 'C';

  @override
  String get macroFNone => 'G ?';

  @override
  String macroFShort(int value) {
    return 'G $value';
  }

  @override
  String get macroFat => 'Gorduras';

  @override
  String get macroFatCaps => 'GORDURAS';

  @override
  String get macroFatLetter => 'G';

  @override
  String get macroMedsCaps => 'REMÉDIOS';

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
  String get mealEditDelete => 'Excluir o registro';

  @override
  String mealEditKcal(Object u) {
    return '$u';
  }

  @override
  String get mealEditSave => 'Salvar';

  @override
  String get mealEmpty => 'Ainda não há nada aqui. Escreva o que foi e eu anoto.';

  @override
  String mealGrams(String grams) {
    return '$grams';
  }

  @override
  String get mealThinking => 'A Nora está contando…';

  @override
  String get measureAdd => 'Adicionar uma medida';

  @override
  String get measureCollapse => 'Recolher';

  @override
  String measureCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medições',
      one: '1 medição',
    );
    return '$_temp0';
  }

  @override
  String measureLast(String ago) {
    return 'a última $ago';
  }

  @override
  String get measureNever => 'ainda sem medir';

  @override
  String get measureNothing => 'ainda nada';

  @override
  String get measurePick =>
      'Escolha o que você vai medir. Uma já basta se o resto não te interessa.';

  @override
  String get measureSave => 'Salvar as medições';

  @override
  String get measureStats => 'Estatísticas das medidas';

  @override
  String get measureTitle => 'Medidas';

  @override
  String get medsAdd => 'Adicionar um medicamento';

  @override
  String get medsAllTaken => 'Tudo de hoje já foi tomado';

  @override
  String get medsAt => 'Às';

  @override
  String get medsCourse => 'Tratamento';

  @override
  String get medsDose => 'Dose';

  @override
  String get medsEmpty =>
      'Ainda não há nada aqui. Adicione um medicamento e eu lembro você na hora certa.';

  @override
  String get medsEmptyHint => 'Eu registro as tomadas, a dose eu não calculo';

  @override
  String get medsFinish => 'Encerrar o tratamento';

  @override
  String medsFirstDose(String name, String day, String at) {
    return '$name, primeira tomada $day às $at';
  }

  @override
  String get medsHours => 'Horários';

  @override
  String get medsHowOften => 'Com que frequência';

  @override
  String get medsMine => 'Meus medicamentos';

  @override
  String get medsName => 'Nome';

  @override
  String get medsNameExample => 'Por exemplo, Magnésio B6';

  @override
  String get medsNew => 'Novo medicamento';

  @override
  String get medsNextAt => 'A próxima às ';

  @override
  String get medsNoneToday => 'Hoje não há tomadas';

  @override
  String get medsNote => 'Observação';

  @override
  String get medsNow => 'AGORA';

  @override
  String get medsOne => 'Medicamento';

  @override
  String get medsPast => 'Encerrados';

  @override
  String get medsPastEmpty =>
      'Aqui ficam os tratamentos que você não faz mais. Um medicamento tirado da lista continua nos dias em que você tomou.';

  @override
  String get medsPerTake => 'Quanto por vez';

  @override
  String get medsRemind => 'Me lembrar';

  @override
  String get medsRemindHint => 'nos horários escolhidos';

  @override
  String get medsResume => 'Retomar o tratamento';

  @override
  String get medsSchedule => 'Programação';

  @override
  String medsSince(String date) {
    return 'desde $date';
  }

  @override
  String get medsTime => 'Horário';

  @override
  String get medsTitle => 'Medicamentos';

  @override
  String get medsTomorrow => 'amanhã';

  @override
  String get medsUnmarked => 'Ainda sem marcar: ';

  @override
  String medsUntil(String date) {
    return 'até $date';
  }

  @override
  String get menuAbout => 'Sobre o app';

  @override
  String get menuAllergy => 'Alergias';

  @override
  String get menuAnalytics => 'Estatísticas';

  @override
  String get menuDiary => 'Diário';

  @override
  String get menuHintFree => 'gratuito';

  @override
  String menuHintKcal(String n) {
    return 'hoje $n';
  }

  @override
  String menuHintMore(int n) {
    return '+$n';
  }

  @override
  String get menuHintNoAllergy => 'nenhuma';

  @override
  String get menuHintNoMeds => 'sem cursos';

  @override
  String get menuHintNothing => 'ainda nada registado';

  @override
  String menuHintOnGoal(int ok, int total) {
    return 'na meta $ok de $total';
  }

  @override
  String get menuHintRecipes => 'da Nora, à medida da tua norma';

  @override
  String get menuHintWeekFriday => 'a partir de sexta, 18:00';

  @override
  String get menuHintWeekOpen => 'aberto até domingo';

  @override
  String get menuHintWeekYoung => 'a semana acabou de começar';

  @override
  String get menuMeds => 'Medicamentos';

  @override
  String get menuPlan => 'Assinatura';

  @override
  String get menuRecipes => 'Receitas';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuWeek => 'Resumo da semana';

  @override
  String get noraName => 'Nora';

  @override
  String get normAuto => 'Calcular automaticamente';

  @override
  String get normAutoFrom =>
      'A partir do peso no início da meta, da altura, da idade, da atividade e do ritmo: ';

  @override
  String normAutoHint(String kcal) {
    return 'a partir do peso, da altura, da idade, da atividade e da meta: $kcal';
  }

  @override
  String get normAutoShort => 'Automática';

  @override
  String get normByHand => 'Definir na mão';

  @override
  String get normByHandHint => 'as estatísticas vão contar contra esse número';

  @override
  String get normByHandShort => 'Na mão';

  @override
  String get normCalculatedHead => 'O valor calculado é ';

  @override
  String get normCalculatedTail => '. Você volta para ele escolhendo «Automática».';

  @override
  String get normFitCarbs => 'Ajustar os carboidratos à referência';

  @override
  String get normFits => 'A divisão bate com a referência';

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
  String get normManual => 'definida na mão';

  @override
  String normOf(String kcal) {
    return 'de $kcal';
  }

  @override
  String normOffOver(String sum, int off) {
    return 'A divisão dá $sum, $off acima da referência';
  }

  @override
  String normOffUnder(String sum, int off) {
    return 'A divisão dá $sum, $off abaixo da referência';
  }

  @override
  String normPerDay(Object u) {
    return '$u por dia';
  }

  @override
  String get normTitle => 'Referência';

  @override
  String get normWater => 'Água';

  @override
  String get normWaterHead => 'Isso dá ';

  @override
  String normWaterPerKg(String ml) {
    return '$ml';
  }

  @override
  String get normWaterTail =>
      ' por quilo de peso. A faixa aproximada costuma ser de 30 a 40 ml, mas depende do calor e dos treinos, então o número aqui não é rígido.';

  @override
  String get normWhere => 'De onde vem esse número';

  @override
  String get notifyChannel => 'Lembretes';

  @override
  String get notifyChannelHint => 'Lembretes de comida, água, medicamentos e pesagens';

  @override
  String get notifyDenied =>
      'O telefone recusou as notificações. Ative nas configurações do sistema e os lembretes voltam a funcionar.';

  @override
  String get photoDish => 'Prato';

  @override
  String get photoNotRecognized => 'Não consegui reconhecer o prato nesta foto';

  @override
  String get planBuy => 'Assinar';

  @override
  String get planClose => 'Fechar';

  @override
  String get planCurrent => 'atual';

  @override
  String get planFailed => 'A compra não passou';

  @override
  String get planFree => 'Grátis';

  @override
  String planFrom(String plan, String date) {
    return '$plan a partir de $date';
  }

  @override
  String planFromShort(String date) {
    return 'a partir de $date';
  }

  @override
  String get planLater => 'Agora não';

  @override
  String get planManage => 'Gerenciar na loja';

  @override
  String get planMonth => 'Mês';

  @override
  String get planMonthBilled => 'cobrança mensal';

  @override
  String get planMonthly => 'Pro mensal';

  @override
  String get planNext => 'Depois';

  @override
  String get planNothingToRestore => 'Nenhuma compra nesta conta';

  @override
  String get planNow => 'Agora';

  @override
  String get planOn => 'Pro';

  @override
  String get planPerMonth => '/mês';

  @override
  String get planPerkChat => 'Conversas com a Nora sem limite';

  @override
  String get planPerkChatSub => 'hoje uma mensagem custa um token';

  @override
  String get planPerkMemory => 'A Nora lembra de você';

  @override
  String get planPerkMemorySub => 'ela aprende coisas novas na conversa, e isso custa um token';

  @override
  String get planPerkPhoto => 'Fotos de comida sem limite';

  @override
  String get planPerkPhotoSub => 'hoje uma foto custa dois tokens';

  @override
  String get planPerkRecipes => 'Receitas da Nora sem limite';

  @override
  String get planPerkRecipesSub => 'hoje uma sugestão custa um token';

  @override
  String get planPerkWeek => 'Resumo da semana quando você quiser';

  @override
  String get planPerkWeekSub => 'hoje um resumo custa dois tokens';

  @override
  String get planPerks => 'O que a assinatura dá';

  @override
  String get planPlan => 'Plano';

  @override
  String get planPrivacy => 'Política de privacidade';

  @override
  String get planRenewal =>
      'A assinatura se renova sozinha até você cancelar. Dá para cancelar quando quiser nas configurações da loja onde foi comprada.';

  @override
  String get planRenews => 'Renova';

  @override
  String get planRestore => 'Restaurar compras';

  @override
  String get planSignInGo => 'Entrar';

  @override
  String get planSignInNote =>
      'A assinatura fica ligada a uma conta com e-mail. Assim ela sobrevive a um telefone novo e funciona em todos os seus aparelhos.';

  @override
  String get planSignInTitle => 'Entre primeiro';

  @override
  String get planStoreAsking => 'Perguntando os preços para a loja…';

  @override
  String get planStoreOffline => 'A loja não responde. Verifique sua conexão com a internet';

  @override
  String get planStoreQuiet => 'A loja não responde. Tente mais tarde';

  @override
  String get planSwitchMonth => 'Mudar para o mensal';

  @override
  String get planSwitchYear => 'Mudar para o anual';

  @override
  String get planTariffs => 'Planos';

  @override
  String get planTerms => 'Termos de uso';

  @override
  String get planTitle => 'Assinatura';

  @override
  String get planTokens => 'Tokens';

  @override
  String get planTokensFree => '40 por mês';

  @override
  String get planTokensPro => 'Sem limite';

  @override
  String get planUntil => 'Ativo até';

  @override
  String get planYear => 'Ano';

  @override
  String planYearBilled(String price) {
    return '$price uma vez por ano';
  }

  @override
  String get planYearly => 'Pro anual';

  @override
  String plateFor(String grams) {
    return 'em $grams';
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
  String get privacyCrash => 'Relatórios de erro';

  @override
  String get privacyCrashHint => 'o rastro do erro, sem dados do diário';

  @override
  String get privacyDiaryHead => 'Seu diário continua seu';

  @override
  String get privacyDiarySub => 'nem as refeições nem o peso vão para as estatísticas';

  @override
  String get privacyHealthHead => 'Os dados de saúde não vão para ninguém';

  @override
  String get privacyHealthSub => 'alergias e medicamentos não saem do app';

  @override
  String get privacyNoPhotosHead => 'As fotos de comida não são guardadas';

  @override
  String get privacyNoPhotosSub => 'a foto é lida e some';

  @override
  String get privacyNotCollected => 'O que a gente não coleta';

  @override
  String get privacyOptional => 'O que você pode desligar';

  @override
  String get privacyPhotosBold => 'não são guardadas';

  @override
  String get privacyPhotosHead => 'As fotos de comida ';

  @override
  String get privacyPhotosTail =>
      ': a foto vai para processamento e some. As estatísticas nunca veem pratos, peso, alergias ou medicamentos. Isso é uma categoria especial de dados pessoais, e entregar isso a terceiros está fora de questão, por mais cômodo que fosse.';

  @override
  String get privacyStats => 'Estatísticas anônimas';

  @override
  String get privacyStatsHint => 'quais telas são abertas, sem o conteúdo dos registros';

  @override
  String get privacyTitle => 'Privacidade';

  @override
  String get profileActivity => 'Atividade';

  @override
  String get profileAge => 'Idade';

  @override
  String get profileHeight => 'Altura';

  @override
  String get profileSex => 'Sexo';

  @override
  String rcAllergyWarn(String names) {
    return 'Contém $names, que está na sua lista de alergias. Cuidado com esta.';
  }

  @override
  String get rcAsk => 'Pedir uma receita para a Nora';

  @override
  String get rcAskAbout => 'Perguntar à Nora sobre esta receita';

  @override
  String get rcAskCancel => 'Cancelar';

  @override
  String get rcAskGo => 'Perguntar';

  @override
  String get rcAskPlaceholder => 'frango, brócolis, arroz';

  @override
  String get rcAskTitle => 'O que tem na cozinha?';

  @override
  String get rcAsking => 'Pensando…';

  @override
  String rcChatGreet(String name) {
    return 'Pergunte sobre «$name»: o que dá para trocar, como não estragar, o que deixar pronto antes.';
  }

  @override
  String get rcChatPlaceholder => 'Pergunte sobre esta receita';

  @override
  String rcCount(int n) {
    return '$n receitas';
  }

  @override
  String rcCountFew(int n) {
    return '$n receitas';
  }

  @override
  String get rcCountOne => '1 receita';

  @override
  String rcDeleteBody(String name) {
    return '«$name» sai do livro. Os registros do diário feitos a partir dela ficam.';
  }

  @override
  String get rcDeleteCta => 'Excluir';

  @override
  String get rcDeleteFailed => 'Não consegui excluir. Tente de novo.';

  @override
  String get rcDeleteTitle => 'Excluir esta receita?';

  @override
  String get rcEmpty =>
      'Ainda não há nada aqui. Diga para a Nora o que tem na cozinha e a primeira receita aparece.';

  @override
  String get rcEmptyMine =>
      'Ainda não há receitas suas. Dite qualquer uma para a Nora e ela cai aqui.';

  @override
  String get rcEyebrow => 'A cozinha';

  @override
  String get rcFromMine => 'Minha';

  @override
  String get rcFromNora => 'Da Nora';

  @override
  String get rcHeroA => 'O que cozinhar';

  @override
  String get rcHeroB => 'hoje';

  @override
  String get rcHeroLede =>
      'Diga o que você tem em casa. A Nora sugere e calcula a porção; sua própria receita também vale.';

  @override
  String get rcItemsHead => 'Ingredientes';

  @override
  String rcItemsTotal(String g) {
    return 'no total $g';
  }

  @override
  String get rcJustNow => 'agora mesmo';

  @override
  String get rcLoadFailed => 'O livro de receitas não carregou. Puxe para tentar de novo.';

  @override
  String rcMinutes(int n) {
    return '$n min';
  }

  @override
  String get rcNoTools => 'Nada além de uma faca e uma tigela';

  @override
  String rcOfDay(int p) {
    return 'isso é $p% da referência do dia';
  }

  @override
  String get rcPerServing => 'por porção';

  @override
  String get rcPerServingHead => 'Por porção';

  @override
  String get rcPickTitle => 'Escolha um prato';

  @override
  String rcPortion(String g) {
    return 'porção $g';
  }

  @override
  String rcServingsFew(int n) {
    return '$n porções';
  }

  @override
  String rcServingsMany(int n) {
    return '$n porções';
  }

  @override
  String get rcServingsOne => '1 porção';

  @override
  String get rcStepsHead => 'Como fazer';

  @override
  String get rcSuggestFailed => 'A Nora não conseguiu montar as receitas. Tente de novo.';

  @override
  String get rcTabAll => 'Todas';

  @override
  String get rcTabMine => 'Minhas';

  @override
  String get rcTabNora => 'Da Nora';

  @override
  String get rcTitle => 'Receitas';

  @override
  String get rcToolBlender => 'Liquidificador';

  @override
  String get rcToolGrill => 'Grelha';

  @override
  String get rcToolMixer => 'Batedeira';

  @override
  String get rcToolOven => 'Forno';

  @override
  String get rcToolPan => 'Frigideira';

  @override
  String get rcToolPot => 'Panela';

  @override
  String get rcToolsHead => 'O que a cozinha precisa';

  @override
  String rcWhole(String kcal, String g) {
    return 'Prato inteiro: $kcal, $g';
  }

  @override
  String get remAbout => 'Sobre o quê';

  @override
  String get remAdd => 'Adicionar um lembrete';

  @override
  String get remAt => 'Às';

  @override
  String get remDelete => 'Excluir o lembrete';

  @override
  String get remEdit => 'Lembrete';

  @override
  String get remEmpty => 'Ainda não há lembretes.';

  @override
  String get remEmptyHint =>
      'Adicione a única coisa que você realmente esquece, não tudo de uma vez';

  @override
  String get remHowOften => 'Com que frequência';

  @override
  String get remName => 'Nome';

  @override
  String get remNew => 'Novo lembrete';

  @override
  String get remOpenMeds => 'Abrir os medicamentos';

  @override
  String get remTime => 'Horário';

  @override
  String get remTitle => 'Lembretes';

  @override
  String get reminderBodyMeal => 'Anote o que foi';

  @override
  String get reminderBodyMeds => 'Pela programação';

  @override
  String get reminderBodySummary => 'O que você não anotou hoje?';

  @override
  String get reminderBodyWater => 'Hora de beber';

  @override
  String get reminderBodyWeigh => 'De manhã, antes de comer';

  @override
  String get reminderBodyWorkout => 'Anote se aconteceu';

  @override
  String get reminderMeal => 'Comida';

  @override
  String get reminderMealHint => 'eu lembro você de anotar a refeição';

  @override
  String get reminderMeds => 'Medicamentos';

  @override
  String get reminderMedsHint => 'pela programação do registro';

  @override
  String get reminderSummary => 'Resumo do dia';

  @override
  String get reminderSummaryHint => 'em poucas palavras sobre o dia antes de dormir';

  @override
  String get reminderWater => 'Água';

  @override
  String get reminderWaterHint => 'eu lembro você de beber';

  @override
  String get reminderWeigh => 'Pesagem';

  @override
  String get reminderWeighHint => 'para a curva do peso não ficar cortada';

  @override
  String get reminderWorkout => 'Treino';

  @override
  String get reminderWorkoutHint => 'eu lembro você do que estava planejado';

  @override
  String get repDaily => 'todos os dias';

  @override
  String repEveryN(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'a cada $count dias');
    return '$_temp0';
  }

  @override
  String get repEveryOther => 'dia sim, dia não';

  @override
  String get repPickDaily => 'Todos os dias';

  @override
  String get repPickFromToday => 'Contado a partir de hoje.';

  @override
  String get repPickInterval => 'Dia sim, dia não';

  @override
  String get repPickNoDays => 'Nenhum dia foi escolhido, então o lembrete nunca vai tocar.';

  @override
  String get repPickWeekdays => 'Dias da semana';

  @override
  String get repWeekdays => 'nos dias úteis';

  @override
  String get repWeekends => 'no fim de semana';

  @override
  String get repWeekly => 'uma vez por semana';

  @override
  String get restoredBody1 =>
      'Esta conta estava esperando para ser excluída. A entrada cancelou isso: o diário, o perfil e as configurações estão de novo neste telefone.';

  @override
  String get restoredBody2 =>
      'Se você ainda quiser que a conta suma, peça a exclusão de novo nas Configurações. Qualquer entrada antes da nossa confirmação cancela o pedido do mesmo jeito.';

  @override
  String get restoredOk => 'Entendi';

  @override
  String get restoredTitle => 'Seus dados voltaram';

  @override
  String get setAbout => 'Sobre o app';

  @override
  String get setAccess => 'Acesso';

  @override
  String get setAllergies => 'Alergias';

  @override
  String setAssistantLine(String name, int count) {
    return '$name, $count na memória';
  }

  @override
  String get setDeleteAccount => 'Excluir a conta e os dados';

  @override
  String get setFreeTierHead =>
      'Para os defensores da Ucrânia e para quem serve nas Forças Armadas, no Serviço Estatal de Emergência, na DTEK, para profissionais de saúde, voluntários e professores nas zonas de linha de frente, o plano pago é ';

  @override
  String get setFreeTierHow => ' Como conseguir';

  @override
  String get setFreeTierShort =>
      'Para os defensores da Ucrânia e para quem serve nas Forças Armadas, no Serviço Estatal de Emergência, na DTEK, para profissionais de saúde, voluntários e professores nas zonas de linha de frente, o plano pago é GRÁTIS';

  @override
  String get setFreeTierTelegram => 'Escrever no Telegram';

  @override
  String get setFreeTierTitle => 'Plano grátis';

  @override
  String get setFreeTierWord => 'GRÁTIS';

  @override
  String get setFreeTierWrite =>
      'Escreva para o desenvolvedor e o plano pago é liberado no mesmo dia.';

  @override
  String get setGoal => 'Meta';

  @override
  String get setGoalKeep => 'manter o peso';

  @override
  String setGoalLine(String kg, String pace) {
    return '$kg, $pace/semana';
  }

  @override
  String get setGroupAbout => 'Sobre você';

  @override
  String get setGroupAccount => 'Conta';

  @override
  String get setGroupAssistant => 'Assistente';

  @override
  String get setGroupDocs => 'Documentos';

  @override
  String get setGroupHealth => 'Saúde';

  @override
  String get setLang => 'Idioma';

  @override
  String get setMedical => 'Aviso médico';

  @override
  String get setMeds => 'Medicamentos';

  @override
  String get setNorm => 'Referência';

  @override
  String setNormLine(String kcal) {
    return '$kcal';
  }

  @override
  String get setPlan => 'Assinatura';

  @override
  String get setPlanFree => 'Grátis';

  @override
  String get setPolicy => 'Política de privacidade';

  @override
  String get setPrivacy => 'Dados e estatísticas';

  @override
  String get setProfile => 'Perfil';

  @override
  String setProfileLine(String sex, int age, String height) {
    return '$sex, $age, $height';
  }

  @override
  String get setReminders => 'Lembretes';

  @override
  String get setRemindersOff => 'desativados';

  @override
  String get setTerms => 'Termos de uso';

  @override
  String get setTheme => 'Tema';

  @override
  String get setTitle => 'Configurações';

  @override
  String get setUnits => 'Unidades';

  @override
  String get setUnset => 'não definido';

  @override
  String get sexOther => 'Outro';

  @override
  String get sexShortFemale => 'M';

  @override
  String get sexShortMale => 'H';

  @override
  String get slotBreakfast => 'Café da manhã';

  @override
  String get slotByHand => 'Coloque os números você';

  @override
  String get slotCancel => 'Cancelar';

  @override
  String get slotDinner => 'Jantar';

  @override
  String slotEraseBody(String name) {
    return '«$name» ainda não tem números. A linha sai do dia.';
  }

  @override
  String get slotEraseDo => 'Tirar';

  @override
  String get slotEraseTitle => 'Tirar o rascunho?';

  @override
  String slotGrams(Object u) {
    return 'PESO, $u';
  }

  @override
  String get slotIntoBreakfast => 'no café da manhã';

  @override
  String get slotIntoDinner => 'no jantar';

  @override
  String get slotIntoLunch => 'no almoço';

  @override
  String slotIntoOther(String name) {
    return 'em «$name»';
  }

  @override
  String get slotIntoSnack => 'no lanche';

  @override
  String slotKcal(Object u) {
    return '$u';
  }

  @override
  String get slotLog => 'Anotar';

  @override
  String get slotLunch => 'Almoço';

  @override
  String get slotSnack => 'Lanche';

  @override
  String get slotWriteWhat => 'Escreva o que foi';

  @override
  String get startAbout => 'Sobre você';

  @override
  String get startAge => 'Idade';

  @override
  String startAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String get startAgreeAnd => ' e a ';

  @override
  String get startAgreeHead => 'Eu aceito os ';

  @override
  String get startAgreePrivacy => 'política de privacidade';

  @override
  String get startAgreeTerms => 'termos de uso';

  @override
  String get startDeviceFirstRun => 'primeira abertura';

  @override
  String get startGoal => 'Para onde vamos';

  @override
  String get startGoalGain => 'Ganhar peso';

  @override
  String get startGoalGainHint => 'um superávit no ritmo que você escolher';

  @override
  String get startGoalKeep => 'Manter o peso';

  @override
  String get startGoalKeepHint => 'você repõe exatamente o que gasta';

  @override
  String get startGoalLose => 'Emagrecer';

  @override
  String get startGoalLoseHint => 'um déficit no ritmo que você escolher';

  @override
  String get startHeight => 'Altura';

  @override
  String get startLife => 'Estilo de vida';

  @override
  String get startNorm => 'Sua referência';

  @override
  String get startNormCounting => 'a calcular…';

  @override
  String get startNormHold => 'mantendo';

  @override
  String get startNormNote =>
      'Esta é a fórmula de Mifflin-St Jeor, não é orientação médica. Se você tem alguma condição, está grávida ou segue uma dieta prescrita, converse com seu médico.';

  @override
  String startNormPerDay(Object u) {
    return '$u por dia';
  }

  @override
  String get startNormWeeks => 'semanas';

  @override
  String get startPace => 'Em que ritmo';

  @override
  String get startPaceEtaHead => 'Meta por volta de ';

  @override
  String get startPaceEtaTail => ', ou seja ';

  @override
  String get startPaceFast => 'rápido';

  @override
  String get startPaceSlow => 'devagar';

  @override
  String startPaceUnit(Object u) {
    return '$u por semana';
  }

  @override
  String get startPaceUsual => 'constante';

  @override
  String get startPaceWarning =>
      'Um ritmo desses é difícil de manter e costuma quebrar. Abaixo de 0,8 kg por semana o resultado vem mais devagar, mas fica.';

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
  String get startSexFemale => 'Mulher';

  @override
  String get startSexMale => 'Homem';

  @override
  String get startSexOther => 'Outro';

  @override
  String get startSignInApple => 'Continuar com a Apple';

  @override
  String get startSignInBackText =>
      'Entre com a mesma conta e tudo volta: o diário, a meta, a referência e as medidas. Não precisa preencher nada de novo.';

  @override
  String get startSignInBackTitle => 'Que bom te ver de novo';

  @override
  String get startSignInBusy => 'Entrando…';

  @override
  String get startSignInFailed => 'Não deu para entrar. Tente de novo ou siga sem conta.';

  @override
  String startSignInFailedWhy(String why) {
    return 'Não deu para entrar. $why';
  }

  @override
  String get startSignInGoogle => 'Continuar com o Google';

  @override
  String get startSignInSkip => 'Continuar sem conta';

  @override
  String get startSignInText =>
      'A referência está calculada. Entre para guardá-la: histórico, medidas e registros vão estar em todos os aparelhos, não só aqui.';

  @override
  String get startSignInTitle => 'Vamos guardar isso';

  @override
  String get startTargetWeight => 'Peso desejado';

  @override
  String get startWeightNow => 'Peso agora';

  @override
  String get startYearsShort => 'anos';

  @override
  String get storageBroken =>
      'Não consegui abrir o armazenamento. Seus registros estão a salvo, mas agora não há com o que mostrar eles.';

  @override
  String get themeAquarelle => 'Aquarela';

  @override
  String get themeAquarelleHint => 'clara, com nuvens em tom pastel ao fundo';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeDarkHint => 'sempre a interface escura';

  @override
  String get themeDawn => 'Amanhecer';

  @override
  String get themeDawnHint => 'clara, com luz quente de lado';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightHint => 'sempre a interface clara';

  @override
  String get themeSectionLook => 'Aparência';

  @override
  String get themeSystem => 'Tema do aparelho';

  @override
  String get themeSystemHint => 'segue a configuração do sistema';

  @override
  String get todayBarcode => 'Código de barras';

  @override
  String todayCodeTalk(String code) {
    return 'Escaneei o código de barras $code e nenhuma base conhece ele. Não anote nada: me pergunte sobre este produto ou diga como contar.';
  }

  @override
  String get todayDone => 'Pronto.';

  @override
  String get todayFailedRetry => 'Não deu certo. Tente daqui a um minuto.';

  @override
  String get todayGoalMet =>
      'Parabéns! 🎉 O peso que você queria é seu e a meta está fechada. E foi você que conseguiu, não o app. Agora passo a sua norma para manutenção, para o resultado ficar.';

  @override
  String todayHowManyGrams(String dish) {
    return 'Quantos gramas eram de $dish?';
  }

  @override
  String get todayLogFailed => 'Não consegui anotar. Tente de novo.';

  @override
  String get todayLogged => 'Anotado.';

  @override
  String todayLoggedAskWeight(String slotInto) {
    return 'Anotado $slotInto. Me diga o peso se quiser exato.';
  }

  @override
  String get todayLoggedAskWeightShort => 'Anotado. Me diga o peso se quiser exato.';

  @override
  String todayLoggedCount(int count) {
    return '$count anotados';
  }

  @override
  String todayLoggedInto(String slotInto, String dish) {
    return 'Anotado $slotInto: $dish.';
  }

  @override
  String todayLoggedIntoWithNumbers(String slotInto, String dish, String kcal, String grams) {
    return 'Anotado $slotInto: $dish, $kcal em $grams.';
  }

  @override
  String get todayNoraSlow =>
      'A Nora está pensando mais que o normal. Tente de novo, o token não foi gasto.';

  @override
  String get todayOffline => 'Sem conexão. Tente de novo quando ela voltar.';

  @override
  String get todayOfflineSaved =>
      'Sem conexão. O registro fica no telefone e sobe assim que ela voltar.';

  @override
  String get todayOutOfBody =>
      'Por enquanto fico quieta, mas anotar na mão dá sempre, e é de graça. A assinatura me liga de volta e custa como três cafés por mês.';

  @override
  String get todayOutOfPlan => 'Assinatura';

  @override
  String get todayOutOfTokens => 'Os tokens acabaram.';

  @override
  String get todayPhotoMeal => 'Foto';

  @override
  String get todayQuestionClosed =>
      'Essa pergunta já está fechada. Diga o peso em palavras, se precisar.';

  @override
  String get tourCamera => 'Câmara';

  @override
  String get tourCameraHow => 'um prato, um rótulo ou um código de barras';

  @override
  String get tourDiary => 'Memória do diário';

  @override
  String get tourDiaryHow => 'diz «borscht» e leva a porção do costume';

  @override
  String get tourGuide => 'Guia da aplicação';

  @override
  String get tourGuideHow => 'pergunta onde está o quê e como se faz';

  @override
  String get tourMemory => 'Memória permanente';

  @override
  String get tourMemoryHow => '«não como porco» basta dizer uma vez';

  @override
  String get tourMore => 'Não só comida';

  @override
  String get tourMoreHow => 'água, treinos, medidas, receitas';

  @override
  String get tourTitle => 'O que a Nora sabe fazer';

  @override
  String get tourVoice => 'Voz ou texto';

  @override
  String get tourVoiceHow => '«dois ovos e uma torrada», e fica registado';

  @override
  String get tourWeek => 'Análise do dia e da semana';

  @override
  String get tourWeekHow => 'o que correu bem e o que ajustar';

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
  String get unitsEnergy => 'Energia';

  @override
  String get unitsLength => 'Altura e medidas';

  @override
  String get unitsMass => 'Peso do corpo';

  @override
  String get unitsPortion => 'Porções';

  @override
  String get unitsTitle => 'Que unidades';

  @override
  String get unitsVolume => 'Água';

  @override
  String get watchLinked => 'conectado';

  @override
  String waterGlasses(int glasses) {
    return 'cerca de $glasses copos';
  }

  @override
  String waterLess(String step) {
    return '$step a menos';
  }

  @override
  String waterMore(String step) {
    return '$step a mais';
  }

  @override
  String get waterNone => 'nada bebido';

  @override
  String waterOf(String ml) {
    return ' / $ml';
  }

  @override
  String waterShare(int pct) {
    return '$pct% da meta do dia';
  }

  @override
  String get waterTitle => 'Água';

  @override
  String get wcNoTime => 'sem duração';

  @override
  String get wdFri => 'Sex';

  @override
  String get wdMon => 'Seg';

  @override
  String get wdSat => 'Sáb';

  @override
  String get wdSun => 'Dom';

  @override
  String get wdThu => 'Qui';

  @override
  String get wdTue => 'Ter';

  @override
  String get wdWed => 'Qua';

  @override
  String get weightHint => 'Quanto você pesa hoje. A meta e o ritmo até ela ficam em outro lugar.';

  @override
  String get weightNote =>
      'Pese-se de manhã, antes de comer: assim as oscilações do dia não transformam o gráfico em ruído. Uma medição por semana já é uma tendência.';

  @override
  String get weightTitle => 'Peso';

  @override
  String get welEggs => 'Dois ovos fritos';

  @override
  String get welEggsGrams => '120 g';

  @override
  String get welHaveAccount => 'Já tenho conta';

  @override
  String get welLead => 'Conta calorias com as suas próprias palavras';

  @override
  String get welSaid => 'Comi dois ovos e uma torrada';

  @override
  String get welStart => 'Começar';

  @override
  String get welToast => 'Torrada com manteiga';

  @override
  String get welToastGrams => '50 g';

  @override
  String get welTotal => 'No total';

  @override
  String wfBurned(Object u) {
    return 'Queimadas, $u';
  }

  @override
  String get wfDuration => 'Duração';

  @override
  String get wfDurationCap => 'Duração, min';

  @override
  String get wfEstimate => 'Uma estimativa a partir do seu peso e do tipo de atividade';

  @override
  String get wfFromWatch => 'De um relógio ou de um aparelho';

  @override
  String wfKcal(Object u) {
    return ' $u';
  }

  @override
  String get wfLog => 'Anotar';

  @override
  String wfManualKcal(Object u) {
    return '$u na mão';
  }

  @override
  String wfMin(int min) {
    return '$min min';
  }

  @override
  String get wfMinutes => 'Minutos';

  @override
  String get wfNote => 'Observação';

  @override
  String get wfNoteExample => 'Pernas, pesado';

  @override
  String get wfOptional => '  opcional';

  @override
  String get wheelLess => 'Menos';

  @override
  String get wheelMore => 'Mais';

  @override
  String get wkDaysOk => 'dias dentro da meta';

  @override
  String get wkEmpty =>
      'Esta semana ainda não tem nada anotado. Anote o primeiro dia e o quadro aparece.';

  @override
  String get wkFactsHead => 'A semana no total';

  @override
  String get wkKcalHead => 'Calorias';

  @override
  String get wkLoggedCap => 'dias anotados';

  @override
  String wkLoggedValue(int n) {
    return '$n de 7';
  }

  @override
  String get wkMacroHead => 'Macros';

  @override
  String get wkNoWeight => 'peso: nenhuma pesagem';

  @override
  String get wkNoraBtn => 'Montar a análise';

  @override
  String wkNoraFailed(String why) {
    return 'Não consegui montar a análise: $why';
  }

  @override
  String get wkNoraGreet =>
      'Pergunte o que quiser sobre esta leitura: um prato, um hábito ou o que ajustar primeiro.';

  @override
  String get wkNoraLoading => 'A Nora está lendo a semana…';

  @override
  String get wkNoraLocked => 'A análise abre na sexta';

  @override
  String get wkNoraNoNet => 'sem rede';

  @override
  String get wkNoraNoTokens => 'sem tokens';

  @override
  String get wkNoraP1 =>
      'Sua base é saudável, e isso é raro: quase tudo é feito em casa. Sopa, ovos mexidos, aveia: com uma base dessas o resto se ajusta rápido.';

  @override
  String get wkNoraP2 =>
      'Agora, com sinceridade. Verdura quase não apareceu a semana toda, e doce apareceu todo dia: panquecas com mel, compota. A proteína fica curta não porque você come pouco, mas porque o prato é pesado em carboidrato e leve em carne, peixe ou queijo. E três jantares de sete caíram depois das dez.';

  @override
  String get wkNoraP3 =>
      'Nada grave ainda, mas é exatamente essa alimentação que surpreende nos exames aos quarenta. Um passo para a semana que vem, sem mudar mais nada: algo verde em todo almoço, e água no lugar da compota.';

  @override
  String get wkNoraPlaceholder => 'Pergunte sobre esta semana';

  @override
  String get wkNoraPromise =>
      'Uma leitura honesta da sua semana: o que funcionou, o que escapou e um passo para a próxima.';

  @override
  String get wkNoraReply1 =>
      'A troca mais fácil desta semana: água no lugar da compota. Uma colher de açúcar a menos toda vez, e a sopa não perde nada com isso.';

  @override
  String get wkNoraReply2 =>
      'Verde no almoço não precisa ser salada. Um pepino ou meio pimentão ao lado do prato já resolvem.';

  @override
  String get wkNoraSlow => 'o servidor está demorando demais';

  @override
  String get wkNoraTalk => 'Conversar com a Nora sobre isso';

  @override
  String get wkNoraTitle => 'A Nora sobre a sua semana';

  @override
  String get wkNorm => 'meta';

  @override
  String wkOffNorm(String n) {
    return '$n fora da meta';
  }

  @override
  String get wkPastEmpty =>
      'Ainda não há análises anteriores. A primeira aparece aqui na segunda-feira que vem.';

  @override
  String wkPastRow(String day) {
    return 'Semana de $day';
  }

  @override
  String get wkPastTitle => 'Semanas anteriores';

  @override
  String wkPerDay(Object u) {
    return '$u por dia em média';
  }

  @override
  String get wkPerDayAside => 'por dia em média';

  @override
  String get wkTitle => 'A semana';

  @override
  String wkTotalCap(Object u) {
    return '$u na semana';
  }

  @override
  String get wkWaterCap => 'de água por dia';

  @override
  String wkWaterValue(String l) {
    return '$l l';
  }

  @override
  String get wkWeightCap => 'peso nesta semana';

  @override
  String get workoutAdd => 'Adicionar um treino';

  @override
  String workoutBurned(String kcal) {
    return '−$kcal';
  }

  @override
  String get workoutCollapse => 'Recolher';

  @override
  String get workoutMinUnit => 'min';

  @override
  String get workoutNone => 'nada anotado';

  @override
  String workoutSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '1 sessão',
    );
    return '$_temp0';
  }

  @override
  String get workoutTitle => 'Treino';
}
