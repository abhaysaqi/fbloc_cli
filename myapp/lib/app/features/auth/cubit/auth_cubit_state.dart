
import '../model/user_model.dart';

class AuthCubitState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final String? message;

  const AuthCubitState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.message,
  });

  AuthCubitState copyWith({bool? isLoading, bool? isAuthenticated, UserModel? user, String? error, String? message}) {
    return AuthCubitState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      message: message,
    );
  }


}
