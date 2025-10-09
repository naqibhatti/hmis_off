import 'package:flutter/foundation.dart';

class TestingConfig {
  // Global flag to control testing mode
  // Set to true to disable API calls and authentication
  // Set to false to restore normal API functionality
  static bool _isTestingMode = true;
  
  // Getter for testing mode
  static bool get isTestingMode => _isTestingMode;
  
  // Method to enable testing mode (disable API calls)
  static void enableTestingMode() {
    _isTestingMode = true;
    if (kDebugMode) {
      print('🧪 TESTING MODE ENABLED - API calls disabled, using dummy data');
    }
  }
  
  // Method to disable testing mode (restore API calls)
  static void disableTestingMode() {
    _isTestingMode = false;
    if (kDebugMode) {
      print('🌐 PRODUCTION MODE ENABLED - API calls restored');
    }
  }
  
  // Method to toggle testing mode
  static void toggleTestingMode() {
    _isTestingMode = !_isTestingMode;
    if (kDebugMode) {
      print(_isTestingMode 
        ? '🧪 TESTING MODE ENABLED - API calls disabled, using dummy data'
        : '🌐 PRODUCTION MODE ENABLED - API calls restored');
    }
  }
  
  // Method to restore API functionality (called when user says "RESTORE")
  static void restoreApiLogic() {
    disableTestingMode();
    if (kDebugMode) {
      print('🔄 API LOGIC RESTORED - All API calls and authentication enabled');
    }
  }
}
