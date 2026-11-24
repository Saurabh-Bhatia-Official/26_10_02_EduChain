import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'portal_token': 'signed-in-token'});
  });

  test('loads announcements from the authenticated portal endpoint', () async {
    final api = ApiService.withClient(
      MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/portal/announcements');
        expect(request.headers['authorization'], 'Bearer signed-in-token');
        return http.Response('[]', 200);
      }),
    );
    final announcements = await api.getAnnouncements();
    expect(announcements, isEmpty);
  });

  test(
    'does not replace an unavailable announcement API with mock data',
    () async {
      final api = ApiService.withClient(
        MockClient((request) async {
          throw http.ClientException('Failed to fetch', request.url);
        }),
      );
      await expectLater(
        api.getAnnouncements(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Could not connect to the announcements service'),
          ),
        ),
      );
    },
  );

  test('reports expired authentication and server failures clearly', () async {
    for (final failure in [
      (401, 'Your session is invalid. Please sign in again.'),
      (
        503,
        'The announcements service is temporarily unavailable. Please try again.',
      ),
    ]) {
      final api = ApiService.withClient(
        MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'backend details'}),
            failure.$1,
          );
        }),
      );
      await expectLater(
        api.getAnnouncements(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains(failure.$2),
          ),
        ),
      );
      if (failure.$1 == 401) {
        expect(
          await SharedPreferences.getInstance().then(
            (prefs) => prefs.getString('portal_token'),
          ),
          isNull,
        );
      }
    }
  });

  test('rejects unexpected announcement response shapes', () async {
    final api = ApiService.withClient(
      MockClient((request) async {
        return http.Response('{"announcements":[]}', 200);
      }),
    );
    await expectLater(
      api.getAnnouncements(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('returned an invalid response'),
        ),
      ),
    );
  });

  test(
    'does not turn a rejected login into a mock authenticated session',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService.withClient(
        MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Invalid email or password.'}),
            401,
          );
        }),
      );

      await expectLater(
        api.loginAdmin(email: 'admin@example.test', password: 'wrong-password'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Invalid email or password.'),
          ),
        ),
      );
      expect(
        await SharedPreferences.getInstance().then(
          (prefs) => prefs.getString('portal_token'),
        ),
        isNull,
      );
    },
  );
}
