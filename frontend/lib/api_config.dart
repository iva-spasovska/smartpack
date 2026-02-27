class ApiConfig {
  // Backend URL - change based on environment
  static const String baseUrl = 'http://127.0.0.1:8000';

  // API endpoints
  static const String loginUrl = '$baseUrl/api/auth/login/';
  static const String registerUrl = '$baseUrl/api/users/register/';
  static const String refreshUrl = '$baseUrl/api/auth/refresh/';
  static const String profileUrl = '$baseUrl/api/users/profile/';
  static const String tripsUrl = '$baseUrl/api/trips/';
  static const String weatherUrl = '$baseUrl/api/weather/';
  static const String packingUrl = '$baseUrl/api/packing/';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
}