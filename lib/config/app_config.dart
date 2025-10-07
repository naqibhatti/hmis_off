class AppConfig {
  // Backend API Configuration
  // Update this URL to match your backend server
  // For local development, use: 'http://localhost:7287/api' or 'http://10.0.2.2:7287/api' (Android emulator)
  // For production, use your actual server URL
  static const String backendBaseUrl = 'http://localhost:7287/api';
  
  // App Configuration
  static const String appName = 'HMS Offline';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableApiIntegration = true;
  static const bool enableOfflineMode = true;
  static const bool enableDebugLogging = true;
  
  // API Timeout Settings
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Validation Settings
  static const int minPasswordLength = 8;
  static const int maxFileSizeMB = 10;
  
  // UI Settings
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 100;
}
