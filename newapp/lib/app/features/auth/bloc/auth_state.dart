import 'package:equatable/equatable.dart';

import '../model/user_model.dart';


abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel? user;
  const AuthAuthenticated({this.user});
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordResetEmailSent extends AuthState {
  final String message;
  const PasswordResetEmailSent(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpVerified extends AuthState {
  final String message;
  const OtpVerified(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccess extends AuthState {
  final String message;
  const PasswordResetSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
