import 'package:flutter_timezone/flutter_timezone.dart';

/* The phone's time zone, as the server wants it.
 *
 * It used to go out as `DateTime.timeZoneName`, an abbreviation like «EEST»
 * that names no place: the day boundary can be counted from it only by
 * guessing, and the admin panel had nothing to turn into a country. The IANA
 * name («Europe/Kyiv») is what the server stores and what the reminders
 * already use, so both now speak the same language. */

/// IANA name of the phone's zone: «Europe/Kyiv», never «EEST».
///
/// Falls back to the abbreviation when the plugin has nothing better: the
/// server knows how to read that one too, and an unknown zone is no reason to
/// skip registering.
Future<String> localZone() async {
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    if (zone.identifier.contains('/')) return zone.identifier;
  } catch (_) {
    // Fall through to the abbreviation.
  }
  return DateTime.now().timeZoneName;
}
