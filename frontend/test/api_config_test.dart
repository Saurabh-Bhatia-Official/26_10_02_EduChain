import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/config/api_config.dart';
import 'package:flutter_frontend/constants/api_constants.dart';

void main() {
  group('ApiConfig and ApiConstants Tests', () {
    tearDown(() {
      ApiConfig.resetToDefault();
    });

    test('default environment returns localhost baseUrl without modifications', () {
      expect(ApiConfig.baseUrl, contains('5002/api'));
      expect(ApiConfig.isProduction, isFalse);
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.localhost));
      expect(ApiConstants.localhostBaseUrl, equals('http://localhost:5002/api'));
      expect(ApiConstants.productionBaseUrl, equals('https://two6-10-02-educhain.onrender.com/api'));
    });

    test('switching to production dynamically changes baseUrl to Render endpoint', () {
      ApiConfig.useProduction();

      expect(ApiConfig.baseUrl, equals('https://two6-10-02-educhain.onrender.com/api'));
      expect(ApiConfig.rootUrl, equals('https://two6-10-02-educhain.onrender.com'));
      expect(ApiConfig.isProduction, isTrue);
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.production));
      expect(ApiConstants.baseUrl, equals('https://two6-10-02-educhain.onrender.com/api'));
    });

    test('switching back to localhost restores default', () {
      ApiConfig.useProduction();
      expect(ApiConfig.baseUrl, equals('https://two6-10-02-educhain.onrender.com/api'));

      ApiConfig.useLocalhost();
      expect(ApiConfig.baseUrl, contains('5002/api'));
      expect(ApiConfig.isProduction, isFalse);
    });

    test('custom URL override works and handles trailing slashes', () {
      ApiConfig.setRuntimeBaseUrl('https://custom-api.example.com/api///');
      expect(ApiConfig.baseUrl, equals('https://custom-api.example.com/api'));
      expect(ApiConfig.currentEnvironment, equals(ApiEnvironment.custom));
    });
  });
}
