class ApiEndpoints {
  // Base URL from environment
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://reqres.in/api');

  // 🏠 Home Endpoints
  static const String homes = "$baseUrl/users";
  static String homeById(String id) => "$baseUrl/users/$id";

  // 👤 Auth Endpoints
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";

  // 📰 Example extra endpoint (if you add more features later)
  static const String categories = "$baseUrl/categories";
}
