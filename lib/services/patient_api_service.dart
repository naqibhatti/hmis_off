import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/patient_data.dart';

class PatientApiService {
  static final PatientApiService _instance = PatientApiService._internal();
  factory PatientApiService() => _instance;
  PatientApiService._internal();

  // Create a new patient
  Future<ApiResponse<PatientData>> createPatient(PatientData patient) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.patients}');
      final body = jsonEncode(patient.toCreateDto());
      
      final response = await http.post(
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
      } else {
        return ApiResponse<PatientData>(
          success: false,
          message: 'Failed to create patient',
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
