import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInEmailRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpEmailRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpEmailRequested({required this.name, required this.email, required this.password});
  @override
  List<Object?> get props => [name, email, password];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class OtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;
  const OtpVerifyRequested({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  const ResetPasswordRequested({required this.email, required this.otp, required this.newPassword});
  @override
  List<Object?> get props => [email, otp, newPassword];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}
