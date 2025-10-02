import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({required this.baseUrl, http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await _http.get(Uri.parse('$baseUrl$path'));
    _ensureSuccess(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await _http.post(Uri.parse('$baseUrl$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    _ensureSuccess(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}


