import '../../../core/service/api_endpoints.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/service/api_service.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';
import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password}) async {
    try {
      final response = await _apiService.post(endpoint: ApiEndpoints.login, data: {'email': email, 'password': password});
      if (response.success && response.data != null) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password}) async {
    try {
      final response = await _apiService.post(endpoint: ApiEndpoints.register, data: {'name': name, 'email': email, 'password': password});
      if (response.success && response.data != null) {
        return ApiResponse.success(data: AuthTokens.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.post(endpoint: ApiEndpoints.forgotPassword, data: {'email': email});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _apiService.post(endpoint: ApiEndpoints.verifyOtp, data: {'email': email, 'otp': otp});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      final response = await _apiService.post(endpoint: ApiEndpoints.resetPassword, data: {'email': email, 'otp': otp, 'newPassword': newPassword});
      return response.success ? ApiResponse.success(data: response.message) : ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiService.get(endpoint: ApiEndpoints.profile);
      if (response.success && response.data != null) {
        return ApiResponse.success(data: UserModel.fromJson(response.data));
      }
      return ApiResponse.error(message: response.message);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    // Clear stored tokens
  }
}
