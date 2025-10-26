class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com';
  
  // Home endpoints
  static const String homes = '/homes';
  static String homeById(String id) => '/homes/$id';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
}
