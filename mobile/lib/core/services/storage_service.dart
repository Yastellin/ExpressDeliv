import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'app_storage';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveTokens(String access, String refresh) async {
    await _box.put(_accessTokenKey, access);
    await _box.put(_refreshTokenKey, refresh);
  }

  static String? getAccessToken() => _box.get(_accessTokenKey);
  static String? getRefreshToken() => _box.get(_refreshTokenKey);
  static Future<void> clearTokens() async {
    await _box.delete(_accessTokenKey);
    await _box.delete(_refreshTokenKey);
    await _box.delete(_userKey);
  }

  static Future<void> saveUser(String userJson) async => await _box.put(_userKey, userJson);
  static String? getUser() => _box.get(_userKey);
}