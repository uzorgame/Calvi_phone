package com.calvi.calvi

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.os.Build

/* Живий запис дня в шторці і в рядку стану.
 *
 * **Чому своїм кодом, а не плагіном.** Усе інше застосунок кладе в чергу через
 * `flutter_local_notifications`, і живий запис довго йшов тією ж дорогою. Але
 * Android 16 приніс «Live Updates»: стійке сповіщення, позначене як таке,
 * отримує окрему фішку в рядку стану поруч із годинником, де видно, чиє воно.
 * Саме так у сусідів на телефоні стоїть їхнє імʼя цілий день, а наше ні. Плагін
 * цього API не знає, і ні `setShortCriticalText`, ні `FLAG_PROMOTED_ONGOING`
 * крізь нього не передати, тому це єдине сповіщення будується тут.
 *
 * Слова приходять готовими з Dart: там живуть усі вісім мов, і другий переклад
 * на цьому боці розійшовся б із першим на першій же правці.
 *
 * Канал навмисно найтихіший з можливих: це рядок стану, а не нагадування.
 * Служби переднього плану тут немає свідомо: з нею сповіщення не можна було б
 * змахнути, але вона коштує постійного значка, питань до батареї і окремого
 * пояснення для Google Play. Лічильник калорій цього не вартий.
 */
object LiveNotice {
  /// Свій номер, щоб оновлення заміняло попереднє, а не додавало друге.
  private const val ID = 7301

  /* Другий канал замість першого, і не задля краси.
   *
   * Перший заводився з найнижчою важливістю: живий запис це рядок стану, а не
   * нагадування, і будити людину після кожної записаної страви було б дико. Але
   * фішку в рядку стану система на такому каналі не показує взагалі: поруч із
   * годинником стоїть те, що вона вважає вартим уваги, а «найнижча важливість»
   * означає протилежне. Важливість наявного каналу застосунок підняти не може,
   * тільки завести новий, тому тут другий номер.
   *
   * Тиша при цьому нікуди не поділась: звуку немає, вібрації немає, значка на
   * іконці немає. Різниця рівно в тому, що запис більше не згорнутий у шторці. */
  private const val CHANNEL = "calvi.live.v2"

  /// Перший канал. Лишився в налаштуваннях телефона порожнім рядком, і його
  /// треба прибрати, інакше людина бачить два «лічильники дня» замість одного.
  private const val OLD_CHANNEL = "calvi.live"

  private fun manager(context: Context): NotificationManager =
    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

  private fun ensureChannel(context: Context, name: String, hint: String) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val channel = NotificationChannel(CHANNEL, name, NotificationManager.IMPORTANCE_DEFAULT).apply {
      description = hint
      setSound(null, null)
      enableVibration(false)
      enableLights(false)
      setShowBadge(false)
    }
    manager(context).createNotificationChannel(channel)
    manager(context).deleteNotificationChannel(OLD_CHANNEL)
  }

  fun show(
    context: Context,
    title: String,
    body: String,
    channelName: String,
    channelHint: String,
    progress: Int,
  ) {
    ensureChannel(context, channelName, channelHint)

    val open = PendingIntent.getActivity(
      context,
      0,
      Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
      },
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    val builder = Notification.Builder(context, CHANNEL)
      /* Силует, а не іконка застосунку.
       *
       * Рядок стану бере від значка лише прозорість і фарбує його сам, тому
       * кольорова іконка стає там суцільною плямою: саме такою білою крапкою
       * біля годинника стояв цей запис. */
      .setSmallIcon(R.drawable.ic_stat_calvi)
      /* Свій колір, і саме він фарбує фішку біля годинника.
       *
       * Без цього рядка тут лишався `COLOR_DEFAULT`, а це не «ніякий колір», це
       * «вибери сам». Система бере його з оформлення телефона, тобто зі шпалер:
       * на Pixel це Material You. Смуга поступу в фішці малюється саме цим
       * кольором, і в мить, коли застосунок іде у фон і фішка вʼїжджає в рядок
       * стану, навколо кільця спалахувало зелене. Видно це один кадр, і на
       * записі екрана його немає, бо рядок стану SystemUI малює своїм шаром.
       *
       * Біле навмисно: фішка темна, кільце в ній біле, і саме так воно виглядає
       * зараз. Колір тут задає не тло, а те, чим система фарбує значок і поступ,
       * тож білий лишає вигляд тим самим і забирає з нього шпалери. У шторці
       * система сама підбирає контраст до світлої картки. */
      .setColor(0xFFFFFFFF.toInt())
      .setContentTitle(title)
      .setContentText(body)
      .setContentIntent(open)
      .setOngoing(true)
      /* Тиша тут від каналу, а не від сповіщення. У платформного будівника
         `setSilent` немає взагалі, він є лише в сумісності; з часів каналів
         звуком і вібрацією розпоряджається канал, а наш заведений без звуку, без
         вібрації і найнижчої важливості. `setOnlyAlertOnce` лишається на випадок
         старих систем: запис оновлюється після кожної страви, і кожне оновлення
         дзвеніло б заново. */
      .setOnlyAlertOnce(true)
      .setShowWhen(false)
      .setCategory(Notification.CATEGORY_STATUS)
      /* Само зникає через шість годин.
       *
       * Застосунок, якого змахнули з нещодавніх, не отримує жодної миті, щоб
       * прибрати за собою: Android просто забирає процес. Без цієї межі запис
       * лишався б висіти з учорашніми числами, і нікому було б їх оновити. */
      .setTimeoutAfter(6L * 60L * 60L * 1000L)

    /* Смуга рахується у відсотках, а не в калоріях: перебір інакше вилітав би
       за межу, і система малювала б її порожньою замість повної. */
    val done = progress.coerceIn(0, 100)

    if (Build.VERSION.SDK_INT >= 36) {
      /* Новий вигляд смуги, і саме він робить запис придатним до фішки в рядку
         стану: система бере в неї стиль поступу, а не старий ProgressBar. */
      val style = Notification.ProgressStyle()
        .setProgress(done)
        .setProgressSegments(
          listOf(Notification.ProgressStyle.Segment(100).setColor(0xFF1A1A1C.toInt())),
        )

      /* Імʼя застосунку, і воно береться з нього самого.
       *
       * У фішці біля годинника має стояти те саме слово, що під іконкою на
       * робочому столі: людина бачить його цілий день і мусить одразу знати,
       * чиє це. Тому не свій рядок і не переклад, а рівно та назва, яку система
       * і так показує скрізь. */
      val name = context.applicationInfo.loadLabel(context.packageManager).toString()
      builder.setStyle(style).setShortCriticalText(name)
    } else {
      builder.setProgress(100, done, false)
    }

    val notice = builder.build()

    /* Прапорець ставиться на готовому сповіщенні: у будівника такого виклику
       немає. Система однаково вирішує сама, чи показувати фішку, і мовчки
       ігнорує прапорець, коли сповіщення для неї не годиться. */
    if (Build.VERSION.SDK_INT >= 36) {
      notice.flags = notice.flags or Notification.FLAG_PROMOTED_ONGOING
    }

    manager(context).notify(ID, notice)
  }

  fun hide(context: Context) = manager(context).cancel(ID)
}
