import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  final SharedPreferences _prefs;

  PrefHelper(this._prefs);

  static const String _keyTheme = 'theme';
  static const String _keyUser = 'logged_user';
  static const String _keyToken = 'auth_token';

  String getTheme() {
    return _prefs.getString(_keyTheme) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    await _prefs.setString(_keyTheme, theme);
  }

  String? getUserJson() {
    return _prefs.getString(_keyUser);
  }

  Future<void> setUserJson(String userJson) async {
    await _prefs.setString(_keyUser, userJson);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyToken);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
