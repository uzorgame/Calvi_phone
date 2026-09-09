import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calvi/data/remote/api.dart';

/// A signed-looking token whose payload expires [inDays] from now.
String tokenExpiring({required int inDays}) {
  final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + inDays * 24 * 60 * 60;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': 'u1', 'exp': exp})));
  return 'h.${payload.replaceAll('=', '')}.s';
}

void main() {
  test('a token with under twenty days left is fading, a fresh one is not', () {
    expect(CalviApi.fading(tokenExpiring(inDays: 5)), isTrue);
    expect(CalviApi.fading(tokenExpiring(inDays: 25)), isFalse);
    // Unreadable tokens are left to the server to judge.
    expect(CalviApi.fading('not-a-jwt'), isFalse);
  });

  test('a 401 is retried once with the token the session renews', () async {
    final seen = <String?>[];
    var renewals = 0;
    final client = MockClient((req) async {
      if (req.url.path == '/v1/auth/refresh') {
        renewals++;
        expect(jsonDecode(req.body), {'refresh_token': 'session'});
        return http.Response(jsonEncode({'user_id': 'u1', 'access_token': 'new'}), 200);
      }
      final auth = req.headers['authorization'];
      seen.add(auth);
      if (auth == 'Bearer old') {
        return http.Response(jsonEncode({'error': {'code': 'unauthorized'}}), 401);
      }
      return http.Response(jsonEncode({'ok': true, 'complete': true, 'missing': <String>[]}), 200);
    });

    final api = CalviApi(base: Uri.parse('https://x.test'), client: client)
      ..token = 'old'
      ..refreshToken = 'session';
    final kept = <String>[];
    api.onAccess = (t) async => kept.add(t);

    await api.eraseDiary();

    expect(seen, ['Bearer old', 'Bearer new']);
    expect(renewals, 1);
    expect(api.token, 'new');
    expect(kept, ['new']);
  });

  test('a dead session leaves the original 401 with the caller', () async {
    final client = MockClient((req) async {
      if (req.url.path == '/v1/auth/refresh') {
        return http.Response(jsonEncode({'error': {'code': 'unauthorized'}}), 401);
      }
      return http.Response(jsonEncode({'error': {'code': 'unauthorized'}}), 401);
    });

    final api = CalviApi(base: Uri.parse('https://x.test'), client: client)
      ..token = 'old'
      ..refreshToken = 'session';

    await expectLater(
      api.eraseDiary(),
      throwsA(isA<ApiFailure>().having((f) => f.status, 'status', 401)),
    );
    expect(api.token, 'old');
  });
}
