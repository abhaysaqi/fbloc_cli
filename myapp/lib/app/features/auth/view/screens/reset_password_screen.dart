import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/route_names.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_cubit_state.dart';
import '../components/password_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(email: widget.email, otp: widget.otp, newPassword: _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: BlocConsumer<AuthCubit, AuthCubitState>(
        listener: (context, state) {
                    if (state.message != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
            Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.signIn, (route) => false);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final isLoading = state.isLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.lock_open, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 24),
                  Text('Create New Password', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter your new password', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  PasswordField(
                    controller: _passwordController,
                    label: 'New Password',
                    hintText: 'Enter new password',
                    validator: (v) => v == null || v.isEmpty ? 'Please enter new password' : v.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter new password',
                    validator: (v) => v == null || v.isEmpty ? 'Please confirm your password' : v != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleReset,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
