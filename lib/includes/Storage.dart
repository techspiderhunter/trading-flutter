import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String introCompletedKey = 'intro_completed';
  static const String tokenKey = 'token';
  static const String authStatusKey = 'auth_status';
  static const String isVehicleKey = 'is_vehicle';
  static const String isRegisteredKey = 'is_registered';
  static const String nextStepKey = 'next_step';
  static const String userProfileKey = 'user_profile';
  static const String kycDataKey = 'kyc_data';
  static const String kycSubmittedStatusKey = 'kyc_submitted_status';
  static const String mitcDataKey = 'mitc_data';
  static const String customBaseUrlKey = 'custom_base_url';
  static const String notificationDeviceIdKey = 'notification_device_id';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> write(String key, String value) =>
      _prefs.setString(key, value);

  static String? read(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  static String? getToken() => read(tokenKey);

  static Future<bool> saveToken(String token) => write(tokenKey, token);

  static bool hasToken() {
    final token = getToken();
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> clearAuth() async {
    await remove(tokenKey);
    await remove(userProfileKey);
    await remove(kycDataKey);
    await remove(mitcDataKey);
    await remove(authStatusKey);
    await remove(kycSubmittedStatusKey);
  }
}
