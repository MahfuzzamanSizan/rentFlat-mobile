import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';

  // Tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  static Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  static Future<void> saveUserId(String id) => _storage.write(key: _keyUserId, value: id);
  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<void> saveUserRole(String role) => _storage.write(key: _keyUserRole, value: role);
  static Future<String?> getUserRole() => _storage.read(key: _keyUserRole);

  static Future<void> clearAll() => _storage.deleteAll();

  // SharedPrefs for non-sensitive data
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
}
