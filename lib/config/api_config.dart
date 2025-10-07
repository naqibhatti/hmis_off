import 'app_config.dart';

class ApiConfig {
  // Use the backend URL from app configuration
  static String get baseUrl => AppConfig.backendBaseUrl;
  
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
