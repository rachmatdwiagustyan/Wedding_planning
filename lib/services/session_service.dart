import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/pasangan_model.dart';
import 'dart:convert';

class SessionService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUser = 'auth_user_data';
  static const String _keyPasangan = 'auth_pasangan_data';
  static const String _keyBaseUrl = 'app_base_url';

  static Future<void> saveSession({
    required String token,
    required UserModel user,
    PasanganModel? pasangan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    if (pasangan != null) {
      await prefs.setString(_keyPasangan, jsonEncode(pasangan.toJson()));
    }
  }

  static Future<void> updatePasangan(PasanganModel pasangan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPasangan, jsonEncode(pasangan.toJson()));
  }

  static Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final userId = prefs.getInt(_keyUserId);
    return token != null && token.isNotEmpty && userId != null && userId > 0;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyUser);
    if (str != null && str.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return null;
  }

  static Future<PasanganModel?> getPasangan() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyPasangan);
    if (str != null && str.isNotEmpty) {
      try {
        return PasanganModel.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return null;
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyBaseUrl);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    return AppConstants.defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, url.trim());
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_keyBaseUrl);
    await prefs.clear();
    if (savedUrl != null) {
      await prefs.setString(_keyBaseUrl, savedUrl);
    }
  }
}
