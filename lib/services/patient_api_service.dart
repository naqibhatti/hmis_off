import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/testing_config.dart';
import '../models/api_response.dart';
import '../models/patient_data.dart';
import 'auth_service.dart';
import 'patient_data_service.dart';

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
    // Check if we're in testing mode
    if (TestingConfig.isTestingMode) {
      _log('🧪 TESTING MODE: Using dummy patient search');
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Get dummy patients and apply filters
      List<PatientData> filteredPatients = PatientDataService.allPatients;
      
      // Apply search term filter
      if (searchTerm != null && searchTerm.isNotEmpty) {
        filteredPatients = PatientDataService.searchPatients(searchTerm);
      }
      
      // Apply gender filter
      if (gender != null && gender.isNotEmpty) {
        filteredPatients = filteredPatients.where((p) => 
          p.gender.toLowerCase() == gender.toLowerCase()).toList();
      }
      
      // Apply blood group filter
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        filteredPatients = filteredPatients.where((p) => 
          p.bloodGroup == bloodGroup).toList();
      }
      
      // Apply pagination
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      final paginatedPatients = filteredPatients.length > startIndex 
        ? filteredPatients.sublist(startIndex, endIndex > filteredPatients.length ? filteredPatients.length : endIndex)
        : <PatientData>[];
      
      final totalPages = (filteredPatients.length / pageSize).ceil();
      
      return ApiResponse<List<PatientData>>(
        success: true,
        message: 'Patients searched successfully (Testing Mode)',
        data: paginatedPatients,
        totalEntityCount: filteredPatients.length,
        totalPages: totalPages,
      );
    }
    
    // Normal API flow
    try {
      // Prefer the paged SP-based endpoint for predictable list shape
      final queryParams = <String, String>{
        'PageNumber': page.toString(),
        'PageSize': pageSize.toString(),
      };
      
      // Optional filters for the stored-proc endpoint
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['PatientName'] = searchTerm;
      }
      if (gender != null && gender.isNotEmpty) {
        // gender filter not supported on SP endpoint; keep only basic name/cnic/contact
      }
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        // not supported on SP endpoint
      }
      if (isActive != null) {
        // not supported on SP endpoint
      }

      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.searchPatients}')
          .replace(queryParameters: queryParams);
      final headers = await AuthService().getAuthHeaders();
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(responseData, (data) {
          if (data is List) {
            return data.map((item) => PatientData.fromJson(item)).toList();
          }
          if (data is Map<String, dynamic>) {
            // Fallback to EF search shape: data.patients
            final dynamic patientsNode = data['patients'] ?? data['Patients'];
            if (patientsNode is List) {
              return patientsNode.map((item) => PatientData.fromJson(item)).toList();
            }
          }
          return <PatientData>[];
        });

        return ApiResponse<List<PatientData>>(
          success: apiResponse.success,
          message: apiResponse.message,
          data: apiResponse.data ?? [],
          totalEntityCount: apiResponse.totalEntityCount,
          totalPages: apiResponse.totalPages,
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

  // Fetch all patients by paging through the search endpoint
  Future<ApiResponse<List<PatientData>>> fetchAllPatients({int pageSize = 50}) async {
    // Check if we're in testing mode
    if (TestingConfig.isTestingMode) {
      _log('🧪 TESTING MODE: Using dummy patient data');
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return dummy patients
      final dummyPatients = PatientDataService.allPatients;
      
      return ApiResponse<List<PatientData>>(
        success: true,
        message: 'Patients fetched successfully (Testing Mode)',
        data: dummyPatients,
        totalEntityCount: dummyPatients.length,
        totalPages: 1,
      );
    }
    
    // Normal API flow
    try {
      final List<PatientData> all = <PatientData>[];
      int page = 1;
      int safetyCounter = 0; // prevent infinite loops
      while (true) {
        final ApiResponse<List<PatientData>> pageResult = await searchPatients(page: page, pageSize: pageSize);
        if (!pageResult.success) {
          return ApiResponse<List<PatientData>>(
            success: false,
            message: pageResult.message,
            error: pageResult.error,
          );
        }
        final List<PatientData> items = pageResult.data ?? <PatientData>[];
        all.addAll(items);

        final int? totalPages = pageResult.totalPages;
        if (items.isEmpty || totalPages != null && page >= totalPages) {
          break;
        }
        page += 1;
        safetyCounter += 1;
        if (safetyCounter > 200) { // safeguard for extremely large data sets
          break;
        }
      }

      return ApiResponse<List<PatientData>>(
        success: true,
        message: 'All patients fetched',
        data: all,
      );
    } catch (e) {
      return ApiResponse<List<PatientData>>(
        success: false,
        message: 'Network error occurred',
        error: e.toString(),
      );
    }
  }
}
