import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<SignInEmailRequested>(_onSignInEmailRequested);
    on<SignUpEmailRequested>(_onSignUpEmailRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<OtpVerifyRequested>(_onOtpVerifyRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onSignInEmailRequested(SignInEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.signInWithEmail(email: event.email, password: event.password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user: userResponse.data));
    } else {
      emit(AuthError(response.message ?? 'Sign in failed'));
    }
  }

  Future<void> _onSignUpEmailRequested(SignUpEmailRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.signUpWithEmail(name: event.name, email: event.email, password: event.password);
    if (response.success) {
      final userResponse = await _repository.getCurrentUser();
      emit(AuthAuthenticated(user: userResponse.data));
    } else {
      emit(AuthError(response.message ?? 'Sign up failed'));
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.requestPasswordReset(event.email);
    emit(response.success ? PasswordResetEmailSent(response.data ?? 'OTP sent') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onOtpVerifyRequested(OtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.verifyOtp(email: event.email, otp: event.otp);
    emit(response.success ? OtpVerified(response.data ?? 'Verified') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.resetPassword(email: event.email, otp: event.otp, newPassword: event.newPassword);
    emit(response.success ? PasswordResetSuccess(response.data ?? 'Success') : AuthError(response.message ?? 'Failed'));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onGetCurrentUserRequested(GetCurrentUserRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final response = await _repository.getCurrentUser();
    emit(response.success && response.data != null ? AuthAuthenticated(user: response.data) : const AuthUnauthenticated());
  }
}
