import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../utils/api_response.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.timeoutDuration,
        receiveTimeout: AppConstants.timeoutDuration,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.apiKey}',
        },
      ),
    );
  }

  late final Dio _dio;

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.get(
        endpoint,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint, 
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
      return _wrapDioResponse<T>(res, fromJson);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  ApiResponse<T> _wrapDioResponse<T>(Response res, T Function(dynamic)? fromJson) {
    final ok = res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300;
    if (ok) {
      final raw = res.data;
      final parsed = fromJson != null ? fromJson(raw) : raw as T;
      return ApiResponse.success(
        data: parsed,
        message: res.statusMessage,
        statusCode: res.statusCode,
      );
    }
    return ApiResponse.error(
      message: res.statusMessage,
      statusCode: res.statusCode,
      data: res.data,
    );
  }
}
