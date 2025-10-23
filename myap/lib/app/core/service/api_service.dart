import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../utils/api_response.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: AppConstants.timeoutDuration,
      receiveTimeout: AppConstants.timeoutDuration,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.apiKey}',
      },
    ));
  }

  late final Dio _dio;

  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic)? fromJson) async {
    try {
      final response = await _dio.get(endpoint);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}', statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResponse<T>> post<T>(String endpoint, Map<String, dynamic> data, T Function(dynamic)? fromJson) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error('Network error: ${e.message}', statusCode: e.response?.statusCode);
    }
  }
}
