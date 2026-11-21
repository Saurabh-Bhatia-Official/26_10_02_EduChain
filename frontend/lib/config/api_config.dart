import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Base API URL, supplied at build/run time for deployed clients.
  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }

    // If running on Android emulator, localhost is mapped to 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    // Web, Windows Desktop, macOS, Linux, iOS
    return 'http://localhost:5000/api';
  }

  /// Timeout for HTTP requests
  static const Duration timeoutDuration = Duration(seconds: 8);

  /// Enable graceful offline mock fallback if backend server is unreachable
  static bool isOfflineFallbackEnabled = false;
}
