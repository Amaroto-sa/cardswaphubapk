class AppConfig {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use your machine's local IP (e.g., 192.168.x.x) for physical device testing
  static const String baseUrl = 'https://cardswaphub.xyz/cardswaphubs/api';
  
  // App Identifiers
  static const String appName = 'CardSwapHub';
  static const String version = '1.0.0';
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyBiometricEnabled = 'biometric_enabled';
}
