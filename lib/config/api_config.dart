import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';

class ApiConfig {
  // Resolve base URL per platform (emulator vs device)
  static String get baseUrl {
    final raw = AppConfig.backendBaseUrl;
    // Android emulator: map localhost -> 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      // If pointing to localhost, remap to Android emulator host
      if (raw.contains('http://localhost')) {
        return raw.replaceFirst('http://localhost', 'http://10.0.2.2');
      }
    }
    // Web: if configured to localhost but page is served from another host
    // (e.g., 127.0.0.1, custom domain, LAN IP), reuse the browser host.
    if (kIsWeb) {
      try {
        final uri = Uri.parse(raw);
        if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
          final browser = Uri.base; // current page URL
          final adjusted = uri.replace(host: browser.host);
          return adjusted.toString();
        }
      } catch (_) {}
    }
    return raw;
  }
  
  // API endpoints
  static const String patients = '/Patient';
  static const String patientByCnic = '/Patient/cnic';
  static const String patientExists = '/Patient/exists';
  static const String searchPatients = '/Patient/searchPatients';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout settings
  static const Duration timeout = Duration(seconds: 30);
}
