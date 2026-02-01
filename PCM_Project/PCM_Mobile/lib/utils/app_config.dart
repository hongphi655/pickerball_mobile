// Configuration constants
class AppConfig {
  // API Configuration - CHANGE THIS TO YOUR API URL
  static const String apiBaseUrl = 'http://localhost:5001'; // or 10.0.2.2 for Android emulator
  static const String apiTimeout = '30'; // seconds

  // App Configuration
  static const String appName = 'PCM - CLB Pickleball';
  static const String appVersion = '1.0.0';

  // Demo Account credentials (bank account for deposit proof)
  static const String demoAccountNumber = '0123456789';
  static const String demoAccountBank = 'Techcombank';
  static const String demoAccountName = 'CLB Vợt Thủ Phố Núi';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 600);
  static const Duration longDuration = Duration(milliseconds: 1000);
}
