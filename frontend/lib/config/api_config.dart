import 'package:flutter/foundation.dart';

/// Available API environments for EduChain
enum ApiEnvironment {
  localhost,
  production,
  custom,
}

class ApiConfig {
  // Pre-configured URLs
  static const String localhostBaseUrl = 'http://localhost:5002/api';
  static const String localhostRootUrl = 'http://localhost:5002';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5002/api';
  static const String productionBaseUrl = 'https://two6-10-02-educhain.onrender.com/api';
  static const String productionRootUrl = 'https://two6-10-02-educhain.onrender.com';

  // Environment variables passed at compile/run time via --dart-define
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _configuredEnv = String.fromEnvironment('APP_ENV', defaultValue: '');
  static const bool _isProductionFlag = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool _useProductionFlag = bool.fromEnvironment('USE_PRODUCTION_API', defaultValue: false);

  // Runtime override (can be switched dynamically without source code edits)
  static String? _runtimeBaseUrl;
  static ApiEnvironment? _runtimeEnvironment;

  /// Set the active API environment at runtime
  static void setEnvironment(ApiEnvironment env) {
    _runtimeEnvironment = env;
    switch (env) {
      case ApiEnvironment.localhost:
        _runtimeBaseUrl = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            ? androidEmulatorBaseUrl
            : localhostBaseUrl;
        break;
      case ApiEnvironment.production:
        _runtimeBaseUrl = productionBaseUrl;
        break;
      case ApiEnvironment.custom:
        break;
    }
  }

  /// Explicitly set a custom base API URL at runtime
  static void setRuntimeBaseUrl(String url) {
    _runtimeEnvironment = ApiEnvironment.custom;
    _runtimeBaseUrl = url.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  /// Reset runtime overrides back to compile-time configuration
  static void resetToDefault() {
    _runtimeBaseUrl = null;
    _runtimeEnvironment = null;
  }

  /// Convenience helpers
  static void useProduction() => setEnvironment(ApiEnvironment.production);
  static void useLocalhost() => setEnvironment(ApiEnvironment.localhost);

  /// Current environment mode
  static ApiEnvironment get currentEnvironment {
    if (_runtimeEnvironment != null) return _runtimeEnvironment!;
    if (isProduction) return ApiEnvironment.production;
    if (_configuredBaseUrl.isNotEmpty) return ApiEnvironment.custom;
    return ApiEnvironment.localhost;
  }

  /// Whether the app is currently targeting the production backend
  static bool get isProduction {
    if (_runtimeEnvironment == ApiEnvironment.production) return true;
    if (_runtimeBaseUrl == productionBaseUrl) return true;
    if (_isProductionFlag || _useProductionFlag) return true;
    final env = _configuredEnv.toLowerCase();
    if (env == 'prod' || env == 'production') return true;
    final configured = _configuredBaseUrl.trim().toLowerCase();
    return configured.contains('onrender.com');
  }

  /// Base API URL, supplied at build/run time or resolved dynamically.
  /// Preserves existing localhost defaults while supporting production URL.
  static String get baseUrl {
    // 1. Runtime override takes highest precedence
    if (_runtimeBaseUrl != null && _runtimeBaseUrl!.isNotEmpty) {
      return _runtimeBaseUrl!;
    }

    // 2. Explicit compile-time URL flag (--dart-define=API_BASE_URL=...)
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }

    // 3. Environment or flag toggle (--dart-define=APP_ENV=production or PRODUCTION=true)
    if (isProduction) {
      return productionBaseUrl;
    }

    // 4. Default: localhost (mapped to 10.0.2.2 on Android emulator)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    // Web, Windows Desktop, macOS, Linux, iOS
    return localhostBaseUrl;
  }

  /// Root backend URL without '/api' suffix
  static String get rootUrl {
    final current = baseUrl;
    if (current.endsWith('/api')) {
      return current.substring(0, current.length - 4);
    }
    return current;
  }

  /// Timeout for HTTP requests
  static const Duration timeoutDuration = Duration(seconds: 8);

  /// Enable graceful offline mock fallback if backend server is unreachable
  static bool isOfflineFallbackEnabled = false;
}
