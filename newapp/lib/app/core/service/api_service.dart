import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/api_response.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic)? fromJson) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.apiKey}',
        },
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> data, T Function(dynamic)? fromJson) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.apiKey}',
        },
        body: jsonEncode(data),
      ).timeout(AppConstants.timeoutDuration);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = jsonDecode(response.body);
      return ApiResponse.fromJson(jsonData, fromJson);
    } else {
      return ApiResponse.error('HTTP ${response.statusCode}: ${response.body}', statusCode: response.statusCode);
    }
  }
}
