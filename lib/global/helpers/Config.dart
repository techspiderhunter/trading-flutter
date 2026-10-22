class Config {
  static const String razorpayKeyId = 'rzp_test_TVwuN2AwB8CVV5';
  /// Override for staging/local builds with:
  /// flutter run --dart-define=API_BASE_URL=https://your-api.example.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://moneyararesearch.in/',
  );


  // Other configuration constants
  static const int timeoutDuration = 60; // Timeout in seconds

  static const Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };


  static const staticKey = "2a12sgVW5E1dCNRzLRZJTySO3Oi3rbXTASPxrwYaQYkHax4qGd0AOgu";


}
