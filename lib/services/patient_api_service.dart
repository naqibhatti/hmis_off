import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/patient_data.dart';

class PatientApiService {
  static final PatientApiService _instance = PatientApiService._internal();
  factory PatientApiService() => _instance;
  PatientApiService._internal();

  // Logging method
  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = isError ? '❌ API ERROR' : '📡 API LOG';
      print('[$timestamp] $prefix: $message');
    }
  }

  // Test API connectivity
  Future<bool> testConnection() async {
    try {
      _log('🔍 Testing API connectivity...');
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}');
      _log('📍 Testing URL: $url');
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));
      
      _log('📊 Connection test response: ${response.statusCode}');
      _log('📦 Response body: ${response.body}');
      
      return response.statusCode < 500; // Any response means server is reachable
    } catch (e) {
      _log('❌ Connection test failed: $e', isError: true);
      return false;
    }
  }

  // Create a new patient
  Future<ApiResponse<PatientData>> createPatient(PatientData patient) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}');
    final body = jsonEncode(patient.toCreateDto());
    
    _log('🚀 Starting patient creation request');
    _log('📍 URL: $url');
    _log('📋 Headers: ${ApiConfig.defaultHeaders}');
    _log('📦 Request Body: $body');
    _log('⏱️ Timeout: ${ApiConfig.timeout}');
    
    try {
      _log('🌐 Making HTTP POST request...');
      
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: body,
      ).timeout(ApiConfig.timeout);

      _log('📨 Response received');
      _log('📊 Status Code: ${response.statusCode}');
      _log('📋 Response Headers: ${response.headers}');
      _log('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _log('✅ HTTP 200 - Processing response...');
        
        try {
          final responseData = jsonDecode(response.body);
          _log('🔍 Parsed JSON: $responseData');
          
          final apiResponse = ApiResponse.fromJson(responseData, (data) => PatientData.fromJson(data));
          
          if (apiResponse.success && apiResponse.data != null) {
            _log('✅ Patient created successfully: ${apiResponse.data!.fullName}');
            return ApiResponse<PatientData>(
              success: true,
              message: apiResponse.message,
              data: apiResponse.data,
            );
          } else {
            _log('⚠️ API returned success=false: ${apiResponse.message}', isError: true);
            return ApiResponse<PatientData>(
              success: false,
              message: apiResponse.message,
              error: apiResponse.error,
            );
          }
        } catch (parseError) {
          _log('❌ JSON Parse Error: $parseError', isError: true);
          return ApiResponse<PatientData>(
            success: false,
            message: 'Failed to parse server response',
            error: 'JSON Parse Error: $parseError',
          );
        }
      } else {
        _log('❌ HTTP Error ${response.statusCode}: ${response.body}', isError: true);
        return ApiResponse<PatientData>(
          success: false,
          message: 'Failed to create patient',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      _log('⏰ Request timeout: $e', isError: true);
      return ApiResponse<PatientData>(
        success: false,
        message: 'Request timeout - server took too long to respond',
        error: 'Timeout: $e',
      );
    } on SocketException catch (e) {
      _log('🌐 Network connection error: $e', isError: true);
      return ApiResponse<PatientData>(
        success: false,
        message: 'Network connection failed - check your internet connection',
        error: 'Socket Error: $e',
      );
    } on HttpException catch (e) {
      _log('🌐 HTTP exception: $e', isError: true);
      return ApiResponse<PatientData>(
        success: false,
        message: 'HTTP request failed',
        error: 'HTTP Exception: $e',
      );
    } catch (e) {
      _log('💥 Unexpected error: $e', isError: true);
      return ApiResponse<PatientData>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Get patient by ID
  Future<ApiResponse<PatientData>> getPatientById(int patientId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}/$patientId');
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) => PatientData.fromJson(data));
        
        if (apiResponse.success && apiResponse.data != null) {
          return ApiResponse<PatientData>(
            success: true,
            message: apiResponse.message,
            data: apiResponse.data,
          );
        } else {
          return ApiResponse<PatientData>(
            success: false,
            message: apiResponse.message,
            error: apiResponse.error,
          );
        }
      } else if (response.statusCode == 404) {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Patient not found',
          error: 'Patient with ID $patientId not found',
        );
      } else {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Failed to get patient',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<PatientData>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }

  // Get patient by CNIC
  Future<ApiResponse<PatientData>> getPatientByCnic(String cnic) async {
    try {
      // Remove dashes from CNIC for API call
      final cleanCnic = cnic.replaceAll('-', '');
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patientByCnic}/$cleanCnic');
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) => PatientData.fromJson(data));
        
        if (apiResponse.success && apiResponse.data != null) {
          return ApiResponse<PatientData>(
            success: true,
            message: apiResponse.message,
            data: apiResponse.data,
          );
        } else {
          return ApiResponse<PatientData>(
            success: false,
            message: apiResponse.message,
            error: apiResponse.error,
          );
        }
      } else if (response.statusCode == 404) {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Patient not found',
          error: 'Patient with CNIC $cnic not found',
        );
      } else {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Failed to get patient',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<PatientData>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }

  // Check if patient exists by CNIC
  Future<ApiResponse<bool>> patientExists(String cnic) async {
    try {
      // Remove dashes from CNIC for API call
      final cleanCnic = cnic.replaceAll('-', '');
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patientExists}/$cleanCnic');
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) => data as bool);
        
        return ApiResponse<bool>(
          success: true,
          message: apiResponse.message,
          data: apiResponse.data ?? false,
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: 'Failed to check patient existence',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }

  // Update patient
  Future<ApiResponse<PatientData>> updatePatient(PatientData patient) async {
    try {
      if (patient.patientID == null) {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Patient ID is required for update',
          error: 'Patient ID is null',
        );
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}/${patient.patientID}');
      final body = jsonEncode(patient.toJson());
      
      final response = await http.put(
        url,
        headers: ApiConfig.defaultHeaders,
        body: body,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) => PatientData.fromJson(data));
        
        if (apiResponse.success && apiResponse.data != null) {
          return ApiResponse<PatientData>(
            success: true,
            message: apiResponse.message,
            data: apiResponse.data,
          );
        } else {
          return ApiResponse<PatientData>(
            success: false,
            message: apiResponse.message,
            error: apiResponse.error,
          );
        }
      } else if (response.statusCode == 404) {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Patient not found',
          error: 'Patient with ID ${patient.patientID} not found',
        );
      } else {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Failed to update patient',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<PatientData>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }

  // Search patients
  Future<ApiResponse<List<PatientData>>> searchPatients({
    String? searchTerm,
    String? gender,
    String? bloodGroup,
    bool? isActive,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }
      if (gender != null && gender.isNotEmpty) {
        queryParams['gender'] = gender;
      }
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        queryParams['bloodGroup'] = bloodGroup;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}').replace(queryParameters: queryParams);
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) {
          if (data is List) {
            return data.map((item) => PatientData.fromJson(item)).toList();
          }
          return <PatientData>[];
        });
        
        return ApiResponse<List<PatientData>>(
          success: true,
          message: apiResponse.message,
          data: apiResponse.data ?? [],
        );
      } else {
        return ApiResponse<List<PatientData>>(
          success: false,
          message: 'Failed to search patients',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<List<PatientData>>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }
}
