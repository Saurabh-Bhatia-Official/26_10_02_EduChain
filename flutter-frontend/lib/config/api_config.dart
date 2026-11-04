import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base API URL for backend
  static String get baseUrl {
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
  static bool isOfflineFallbackEnabled = true;
}

