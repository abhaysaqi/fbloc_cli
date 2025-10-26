import '../../../core/utils/api_response.dart';
import '../model/auth_tokens.dart';
import '../model/user_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthTokens>> signInWithEmail({required String email, required String password});
  Future<ApiResponse<AuthTokens>> signUpWithEmail({required String name, required String email, required String password});
  Future<ApiResponse<String>> requestPasswordReset(String email);
  Future<ApiResponse<String>> verifyOtp({required String email, required String otp});
  Future<ApiResponse<String>> resetPassword({required String email, required String otp, required String newPassword});
  Future<ApiResponse<UserModel>> getCurrentUser();
  Future<void> logout();
}
