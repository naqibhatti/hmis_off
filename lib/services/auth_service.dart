import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Logging method
  void _log(String message, {bool isError = false}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = isError ? '❌ AUTH ERROR' : '🔐 AUTH LOG';
      print('[$timestamp] $prefix: $message');
    }
  }

  // Login with CNIC and password
  Future<ApiResponse<Map<String, dynamic>>> login(String cnic, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Auth/login');
    final body = jsonEncode({
      'cnic': _formatCnicForApi(cnic), // Remove dashes for API
      'password': password,
    });
    
    _log('🚀 Starting login request');
    _log('📍 URL: $url');
    _log('📦 Request Body: $body');
    
    try {
      _log('🌐 Making HTTP POST request...');
      
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: body,
      ).timeout(ApiConfig.timeout);

      _log('📨 Response received');
      _log('📊 Status Code: ${response.statusCode}');
      _log('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _log('✅ HTTP 200 - Processing response...');
        
        try {
          final responseData = jsonDecode(response.body);
          _log('🔍 Parsed JSON: $responseData');
          
          final apiResponse = ApiResponse.fromJson(responseData, (data) => data as Map<String, dynamic>);
          
          if (apiResponse.success && apiResponse.data != null) {
            _log('✅ Login successful for user: ${apiResponse.data!['user']?['name'] ?? 'Unknown'}');
            
            // Store token and user info
            await _storeAuthData(apiResponse.data!);
            
            return ApiResponse<Map<String, dynamic>>(
              success: true,
              message: apiResponse.message,
              data: apiResponse.data,
            );
          } else {
            _log('⚠️ API returned success=false: ${apiResponse.message}', isError: true);
            return ApiResponse<Map<String, dynamic>>(
              success: false,
              message: apiResponse.message,
              error: apiResponse.error,
            );
          }
        } catch (parseError) {
          _log('❌ JSON Parse Error: $parseError', isError: true);
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: 'Failed to parse server response',
            error: 'JSON Parse Error: $parseError',
          );
        }
      } else {
        _log('❌ HTTP Error ${response.statusCode}: ${response.body}', isError: true);
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Login failed',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      _log('⏰ Request timeout: $e', isError: true);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Request timeout - server took too long to respond',
        error: 'Timeout: $e',
      );
    } on SocketException catch (e) {
      _log('🌐 Network connection error: $e', isError: true);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network connection failed - check your internet connection',
        error: 'Socket Error: $e',
      );
    } on HttpException catch (e) {
      _log('🌐 HTTP exception: $e', isError: true);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'HTTP request failed',
        error: 'HTTP Exception: $e',
      );
    } catch (e) {
      _log('💥 Unexpected error: $e', isError: true);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred',
        error: e.toString(),
      );
    }
  }

  // Store authentication data
  Future<void> _storeAuthData(Map<String, dynamic> authData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store token
      if (authData['token'] != null) {
        await prefs.setString('auth_token', authData['token']);
        _log('💾 Token stored successfully');
      }
      
      // Store user data
      if (authData['user'] != null) {
        final userData = authData['user'] as Map<String, dynamic>;
        await prefs.setString('user_data', jsonEncode(userData));
        _log('💾 User data stored: ${userData['name'] ?? 'Unknown'}');
      }
      
      // Store login timestamp
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      _log('❌ Failed to store auth data: $e', isError: true);
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      _log('❌ Failed to get token: $e', isError: true);
      return null;
    }
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _log('❌ Failed to get user data: $e', isError: true);
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Check if user has doctor role
  Future<bool> isDoctor() async {
    final userData = await getUserData();
    if (userData != null) {
      final roles = userData['roles'] as List<dynamic>?;
      return roles?.contains('Doctor') ?? false;
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('login_timestamp');
      _log('🚪 Logout successful');
    } catch (e) {
      _log('❌ Failed to logout: $e', isError: true);
    }
  }

  // Helper method to format CNIC for API (remove dashes)
  String _formatCnicForApi(String cnic) {
    return cnic.replaceAll('-', '');
  }

  // Get authorization headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
