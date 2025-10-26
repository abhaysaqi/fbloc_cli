import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthCubitState());

  Future<void> signInWithEmail({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.signInWithEmail(email: email, password: password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(state.copyWith(isLoading: false, isAuthenticated: true, user: userResponse.data));
    } else {
      emit(state.copyWith(isLoading: false, error: response.message ?? 'Failed'));
    }
  }

  Future<void> signUpWithEmail({required String name, required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.signUpWithEmail(name: name, email: email, password: password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(state.copyWith(isLoading: false, isAuthenticated: true, user: userResponse.data));
    } else {
      emit(state.copyWith(isLoading: false, error: response.message ?? 'Failed'));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.requestPasswordReset(email);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.verifyOtp(email: email, otp: otp);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));
    final response = await _repository.resetPassword(email: email, otp: otp, newPassword: newPassword);
    emit(state.copyWith(isLoading: false, message: response.success ? response.data : null, error: response.success ? null : response.message));
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthCubitState());
  }

  Future<void> getCurrentUser() async {
    emit(state.copyWith(isLoading: true, error: null));
    final response = await _repository.getCurrentUser();
    emit(state.copyWith(isLoading: false, isAuthenticated: response.success, user: response.data));
  }
}
