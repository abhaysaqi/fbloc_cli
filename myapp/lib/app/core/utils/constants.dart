class AppConstants {
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://reqres.in/api');
  static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: 'reqres-free-v1');
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
}
