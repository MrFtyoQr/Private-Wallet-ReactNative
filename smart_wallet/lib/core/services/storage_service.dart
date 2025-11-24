import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Secure storage for tokens
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  static Future<String?> readToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Secure storage for refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> readRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  static Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: 'refresh_token');
  }

  // Regular storage for non-sensitive data
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<String?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<void> saveSubscriptionType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_type', type);
  }

  static Future<String?> readSubscriptionType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('subscription_type');
  }

  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
