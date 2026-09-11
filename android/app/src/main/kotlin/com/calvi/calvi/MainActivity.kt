package com.calvi.calvi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/* Свій канал, окремий від iPhone.
 *
 * Живий запис дня є на обох системах, але просять вони різне: острівцю потрібні
 * числа, бо малює їх розширення на Swift, а сповіщенню потрібні готові слова,
 * бо малює його система. Одне імʼя каналу на два різні вантажі було б
 * запрошенням передати туди не те: обробники на різних системах ніколи не
 * перетнуться, а от людина, яка правитиме один бік, легко забуде про другий. */
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(engine: FlutterEngine) {
    super.configureFlutterEngine(engine)

    MethodChannel(engine.dartExecutor.binaryMessenger, "calvi/live.android").setMethodCallHandler {
      call,
      reply ->
      when (call.method) {
        "show" -> {
          LiveNotice.show(
            context = applicationContext,
            title = call.argument<String>("title") ?: "",
            body = call.argument<String>("body") ?: "",
            channelName = call.argument<String>("channel") ?: "",
            channelHint = call.argument<String>("channelHint") ?: "",
            progress = call.argument<Int>("progress") ?: 0,
          )
          reply.success(null)
        }

        "hide" -> {
          LiveNotice.hide(applicationContext)
          reply.success(null)
        }

        else -> reply.notImplemented()
      }
    }
  }
}
